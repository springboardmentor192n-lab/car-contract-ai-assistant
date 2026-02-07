// frontend/guardian_app/lib/models/chat_message.dart
class ChatMessage {
  final String id;
  final String threadId;
  final String senderType; // 'user' or 'ai'
  final String messageContent;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.threadId,
    required this.senderType,
    required this.messageContent,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      threadId: json['thread_id'],
      senderType: json['sender_type'],
      messageContent: json['message_content'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
