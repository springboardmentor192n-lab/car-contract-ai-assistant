
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardian_app/src/features/negotiation/domain/chat_message.dart';

final chatProvider = StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  return ChatNotifier();
});

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  ChatNotifier() : super([]);

  void addMessage(ChatMessage message) {
    state = [...state, message];
  }
}
