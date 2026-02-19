
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/contract_service.dart';
import '../models/models.dart';

class NegotiationChatScreen extends StatefulWidget {
  final int contractId;
  const NegotiationChatScreen({super.key, required this.contractId});

  @override
  State<NegotiationChatScreen> createState() => _NegotiationChatScreenState();
}

class _NegotiationChatScreenState extends State<NegotiationChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<GlobalMessage> _messages = [];
  List<String> _suggestedQuestions = [
    "Is this APR negotiable?",
    "Are there any hidden fees?",
    "Can I remove the early termination fee?"
  ];
  bool _isLoading = false;

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(GlobalMessage(role: "user", content: text));
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final service = Provider.of<ContractService>(context, listen: false);
      final response = await service.chatWithAI(widget.contractId, text);

      if (response != null) {
        setState(() {
          _messages.add(GlobalMessage(role: "bot", content: response.response));
          _suggestedQuestions = response.suggestedQuestions;
          _isLoading = false;
        });
        _scrollToBottom();
        
        if (response.dealerEmailDraft != null) {
          _showEmailDraft(response.dealerEmailDraft!);
        }
      } else {
        setState(() {
          _messages.add(GlobalMessage(role: "bot", content: "Error connecting to AI assistant."));
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _messages.add(GlobalMessage(role: "bot", content: "Something went wrong: $e"));
        _isLoading = false;
      });
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

  void _showEmailDraft(String draft) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Dealer Email Draft", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
          child: SingleChildScrollView(
            child: Text(draft, style: GoogleFonts.inter(fontSize: 14)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close", style: GoogleFonts.inter(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Draft copied to clipboard!")));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Copy Draft"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: _messages.isEmpty ? _buildEmptyChat() : _buildMessageList(),
          ),
          _buildInputSection(),
        ],
      ),
    );
  }

  Widget _buildEmptyChat() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.indigo.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.auto_awesome, size: 48, color: Colors.indigo),
          ),
          const SizedBox(height: 24),
          Text(
            "Negotiation Assistant",
            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Ask me anything about your contract.",
            style: GoogleFonts.inter(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        final isUser = msg.role == "user";
        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isUser ? Colors.indigo : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isUser ? 16 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 16),
              ),
              boxShadow: [
                if (isUser)
                  BoxShadow(color: Colors.indigo.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))
              ],
            ),
            child: Text(
              msg.content,
              style: GoogleFonts.inter(
                color: isUser ? Colors.white : const Color(0xFF1E293B),
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        children: [
          if (_suggestedQuestions.isNotEmpty) _buildSuggestions(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: TextField(
                    controller: _controller,
                    style: GoogleFonts.inter(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: "Ask about your contract...",
                      hintStyle: GoogleFonts.inter(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _isLoading
                  ? const SizedBox(width: 48, height: 48, child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2)))
                  : IconButton.filled(
                      onPressed: () => _sendMessage(_controller.text),
                      icon: const Icon(Icons.send),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _suggestedQuestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) => ActionChip(
          onPressed: () => _sendMessage(_suggestedQuestions[index]),
          label: Text(
            _suggestedQuestions[index],
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          backgroundColor: Colors.white,
          side: BorderSide(color: Colors.indigo.withOpacity(0.2)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }
}

class GlobalMessage {
  final String role;
  final String content;
  GlobalMessage({required this.role, required this.content});
}
