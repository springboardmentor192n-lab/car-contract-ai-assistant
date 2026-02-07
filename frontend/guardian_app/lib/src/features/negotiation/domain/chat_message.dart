import 'package:flutter/material.dart';

@immutable
class ChatMessage {
  final String id;
  final String text;
  final DateTime createdAt;
  final String authorId;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.authorId,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      text: json['text'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      authorId: json['authorId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'authorId': authorId,
    };
  }
}