import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ContractChatView extends StatefulWidget {
  final Map<String, dynamic>? contractData;

  const ContractChatView({super.key, this.contractData});

  @override
  State<ContractChatView> createState() => _ContractChatViewState();
}

class _ContractChatViewState extends State<ContractChatView> {
  final TextEditingController controller = TextEditingController();
  final List<Map<String, String>> messages = [];
  bool loading = false;

  Future<void> sendMessage() async {
    final question = controller.text.trim();
    if (question.isEmpty) return;

    setState(() {
      messages.add({"role": "user", "text": question});
      loading = true;
    });

    controller.clear();

    try {
      final answer = await ApiService.chatWithContract(
        slaData: widget.contractData ?? {},
        question: question,
      );

      setState(() {
        messages.add({"role": "ai", "text": answer});
      });
    } catch (_) {
      setState(() {
        messages.add({
          "role": "ai",
          "text": "Sorry, I couldn't process that question.",
        });
      });
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI Contract Assistant")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (_, i) {
                final msg = messages[i];
                final isUser = msg["role"] == "user";

                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFF1E3A8A) : Colors.white12,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      msg["text"]!,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: "Ask about this contract...",
                    ),
                  ),
                ),
                loading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: CircularProgressIndicator(),
                      )
                    : IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: sendMessage,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
