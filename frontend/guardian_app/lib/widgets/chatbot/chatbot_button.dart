// lib/widgets/chatbot/chatbot_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/chatbot_provider.dart';

/// A floating action button that toggles the visibility of the chatbot UI.
class ChatbotButton extends ConsumerWidget {
  const ChatbotButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isChatbotOpen = ref.watch(chatbotProvider.select((state) => state.isOpen));

    return FloatingActionButton(
      onPressed: () {
        ref.read(chatbotProvider.notifier).toggleChatbotVisibility();
      },
      backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
      foregroundColor: Theme.of(context).colorScheme.onTertiaryContainer,
      child: Icon(isChatbotOpen ? Icons.close : Icons.chat_bubble_outline),
    );
  }
}