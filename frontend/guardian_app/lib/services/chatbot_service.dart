// lib/services/chatbot_service.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/api_providers.dart';

/// Represents a message in the chatbot conversation.
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser, required this.timestamp});
}

/// A service to handle chatbot logic, including generating context-aware responses.
class ChatbotService {
  final Ref ref;

  ChatbotService(this.ref);

  // Connect to backend API
  Future<String> getResponse(String userMessage) async {
    final apiService = ref.read(apiServiceProvider);
    
    try {
      final response = await apiService.post('/chat', data: {
        'message': userMessage,
      });
      
      if (response.containsKey('response')) {
        return response['response'] as String;
      } else {
        return "I received an empty response from the AI.";
      }
    } catch (e) {
      return "Error: Could not connect to the AI service. Please try again later. ($e)";
    }
  }
}