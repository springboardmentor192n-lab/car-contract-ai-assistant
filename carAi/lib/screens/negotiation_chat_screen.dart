import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../models/contract_analysis_response.dart';
import '../services/api_service.dart';

class Message {
  final String id;
  final String role; // 'user' or 'assistant'
  final String content;
  final List<String>? suggestions;
  final NegotiationMessage? negotiationMessage;

  Message({
    required this.id,
    required this.role,
    required this.content,
    this.suggestions,
    this.negotiationMessage,
  });
}

class NegotiationMessage {
  final String title;
  final String body;

  NegotiationMessage({required this.title, required this.body});
}



class NegotiationChatScreen extends StatefulWidget {
  final String contractId;
  final ContractAnalysisResponse? initialData;

  const NegotiationChatScreen({
    super.key,
    required this.contractId,
    this.initialData,
  });

  @override
  State<NegotiationChatScreen> createState() => _NegotiationChatScreenState();
}

class _NegotiationChatScreenState extends State<NegotiationChatScreen> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool isTyping = false;
  String? copiedMessageId;
  
  late final List<Message> messages;

  @override
  void initState() {
    super.initState();
    _initializeMessages();
  }

  void _initializeMessages() {
    final initialContent = widget.initialData?.aiSummary.isNotEmpty == true
        ? 'I\'ve analyzed your lease contract. Here is a summary:\n\n${widget.initialData!.aiSummary}\n\nHow would you like to proceed with negotiation?'
        : 'I\'ve analyzed your lease. Based on market data, checking the Money Factor and Fees is a good start. How can I help?';
    
    messages = [
      Message(
        id: '1',
        role: 'assistant',
        content: initialContent,
        suggestions: [
          'Draft an email to lower the interest rate',
          'Ask about the acquisition fee',
          'What is a fair monthly payment?',
        ],
      ),
    ];
  }

  Future<void> _sendMessage([String? content]) async {
    final text = content ?? _controller.text.trim();
    if (text.isEmpty) return;

    if (widget.initialData?.clauses == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No contract data available to negotiate.')),
      );
      return;
    }

    setState(() {
      messages.add(Message(
        id: DateTime.now().toString(),
        role: 'user',
        content: text,
      ));
      isTyping = true;
      _controller.clear();
    });
    
    _scrollToBottom();

    try {
      final response = await ApiService().negotiate(
        widget.initialData!.clauses, 
        text
      );

      if (!mounted) return;

      final advice = response['negotiation_advice'] as String? ?? 'I apologize, but I couldn\'t generate specific advice for that.';
      final emailDraft = response['email_draft'] as Map<String, dynamic>?;
      final suggestions = (response['suggestions'] as List<dynamic>?)?.map((e) => e.toString()).toList();

      NegotiationMessage? negotiationMsg;
      if (emailDraft != null) {
        negotiationMsg = NegotiationMessage(
          title: emailDraft['title'] ?? 'Draft Email',
          body: emailDraft['body'] ?? '',
        );
      }

      setState(() {
        isTyping = false;
        messages.add(Message(
          id: DateTime.now().toString(),
          role: 'assistant',
          content: advice,
          negotiationMessage: negotiationMsg,
          suggestions: suggestions,
        ));
      });
      _scrollToBottom();

    } catch (e) {
      if (!mounted) return;
      setState(() {
        isTyping = false;
        messages.add(Message(
          id: DateTime.now().toString(),
          role: 'assistant',
          content: 'Sorry, I encountered an error connecting to the negotiation assistant. Please try again.',
        ));
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _copyToClipboard(String text, String messageId) {
    Clipboard.setData(ClipboardData(text: text));
    setState(() => copiedMessageId = messageId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Message copied to clipboard')),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => copiedMessageId = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Column(
          children: [
            const Text('Negotiation Assistant'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.auto_awesome, size: 12, color: AppColors.purple),
                const SizedBox(width: 4),
                Text('Using contract & VIN analysis', style: AppTextStyles.xs.copyWith(color: AppColors.purple)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildContextBanner(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length + (isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length) {
                  return _TypingIndicator();
                }
                
                final message = messages[index];
                if (message.role == 'assistant') {
                  return _buildAssistantMessage(message);
                } else {
                  return _buildUserMessage(message);
                }
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildContextBanner() {
    if (widget.initialData == null) return const SizedBox.shrink();

    final data = widget.initialData!;
    final vehicleName = data.vehicleInfo != null
        ? '${data.vehicleInfo!['ModelYear']} ${data.vehicleInfo!['Make']} ${data.vehicleInfo!['Model']}'
        : data.filename;
    
    final monthly = data.contractDetails?['monthly_payment'] ?? 'N/A';
    final term = data.contractDetails?['lease_term_months'] ?? 'N/A';
    final score = data.fairness.round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.blue50, AppColors.green50]),
        border: Border(bottom: BorderSide(color: argsOrNull(AppColors.border))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.description, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(vehicleName, style: AppTextStyles.sm.copyWith(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4,
                  children: [
                    Text('\$$monthly/mo · $term mo', style: AppTextStyles.xs),
                    const Text('·', style: TextStyle(color: Colors.grey)),
                    Text('Fairness: $score/100', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Workaround for color null safety issue if needed, though AppColors defines static const
  Color argsOrNull(Color c) => c; 

  Widget _buildAssistantMessage(Message message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.primary, AppColors.success]),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome, size: 16, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message.content, style: AppTextStyles.sm.copyWith(height: 1.5)),
                if (message.negotiationMessage != null) ...[
                  const SizedBox(height: 12),
                  _buildNegotiationMessageCard(message.negotiationMessage!, message.id),
                ],
                if (message.suggestions != null) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: message.suggestions!.map((s) => 
                      ActionChip(
                        label: Text(s, style: AppTextStyles.xs),
                        onPressed: () => _sendMessage(s),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(color: AppColors.border),
                        ),
                      )
                    ).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNegotiationMessageCard(NegotiationMessage msg, String msgId) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
        gradient: const LinearGradient(colors: [Colors.white, AppColors.green50]),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: AppColors.green50,
            child: Row(
              children: [
                const Icon(Icons.lightbulb, size: 16, color: AppColors.success),
                const SizedBox(width: 8),
                Text('Ready to Send: ${msg.title}', style: AppTextStyles.xs.copyWith(color: AppColors.success, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(msg.body, style: AppTextStyles.sm.copyWith(height: 1.4)),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _copyToClipboard(msg.body, msgId),
                  icon: Icon(copiedMessageId == msgId ? Icons.check : Icons.copy, size: 16),
                  label: Text(copiedMessageId == msgId ? 'Copied' : 'Copy Message'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 40),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserMessage(Message message) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(bottom: 24),
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(4),
          ),
        ),
        child: Text(message.content, style: AppTextStyles.sm.copyWith(color: Colors.white)),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Ask about negotiation strategies...',
                    hintStyle: AppTextStyles.sm.copyWith(color: AppColors.mutedForeground),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onSubmitted: _sendMessage,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _sendMessage(),
                icon: const Icon(Icons.send, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'AI can make mistakes. Verify important information.',
            style: AppTextStyles.xs.copyWith(color: AppColors.mutedForeground, fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  @override
  _TypingIndicatorState createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.primary, AppColors.success]),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome, size: 16, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Dot(animation: _controller, delay: 0),
                const SizedBox(width: 4),
                _Dot(animation: _controller, delay: 0.2),
                const SizedBox(width: 4),
                _Dot(animation: _controller, delay: 0.4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final AnimationController animation;
  final double delay;

  const _Dot({required this.animation, required this.delay});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final double t = (animation.value - delay).abs() % 1.0;
        final double opacity = t < 0.5 ? t * 2 : (1.0 - t) * 2;
        return Opacity(
          opacity: 0.3 + (opacity * 0.7),
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
