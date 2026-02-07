// lib/providers/chatbot_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/chatbot_service.dart';

/// Represents the state of the chatbot UI and conversation.
class ChatbotState {
  final bool isOpen;
  final List<ChatMessage> messages;
  final bool isTyping;

  ChatbotState({
    this.isOpen = false,
    this.messages = const [],
    this.isTyping = false,
  });

  ChatbotState copyWith({
    bool? isOpen,
    List<ChatMessage>? messages,
    bool? isTyping,
  }) {
    return ChatbotState(
      isOpen: isOpen ?? this.isOpen,
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}

/// A StateNotifier to manage the chatbot's state and interactions.
class ChatbotNotifier extends StateNotifier<ChatbotState> {
  final ChatbotService _chatbotService;

  ChatbotNotifier(this._chatbotService) : super(ChatbotState());

  void toggleChatbotVisibility() {
    state = state.copyWith(isOpen: !state.isOpen);
  }

  void setChatbotVisibility(bool visible) {
    state = state.copyWith(isOpen: visible);
  }

  Future<void> sendMessage(String text) async {
    // Add user message to history
    state = state.copyWith(
      messages: [...state.messages, ChatMessage(text: text, isUser: true, timestamp: DateTime.now())],
      isTyping: true,
    );

    try {
      // Get AI response, service now has access to other providers via Reader
      final aiResponse = await _chatbotService.getResponse(text);

      // Add AI response to history
      state = state.copyWith(
        messages: [...state.messages, ChatMessage(text: aiResponse, isUser: false, timestamp: DateTime.now())],
        isTyping: false,
      );
    } catch (e) {
      // Handle error
      state = state.copyWith(
        messages: [...state.messages, ChatMessage(text: 'Error: Could not get a response.', isUser: false, timestamp: DateTime.now())],
        isTyping: false,
      );
    }
  }

  void clearChat() {
    state = state.copyWith(messages: []);
  }
}

/// Provider for ChatbotService.
final chatbotServiceProvider = Provider<ChatbotService>((ref) {
  return ChatbotService(ref); // Pass the ref object directly
});

/// StateNotifierProvider for managing chatbot state.
final chatbotProvider = StateNotifierProvider<ChatbotNotifier, ChatbotState>((ref) {
  final chatbotService = ref.watch(chatbotServiceProvider);
  return ChatbotNotifier(chatbotService);
});