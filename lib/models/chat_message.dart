import 'user.dart';
import 'reaction.dart';

class ChatMessage {
  final int? id;
  final String content;
  final String type;
  final DateTime timestamp;
  final User sender;
  final User receiver;
  final bool isRead;
  List<Reaction> reactions; // Made mutable for UI updates

  String get senderEmail => sender.email;
  String get senderName => sender.name;

  ChatMessage({
    this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    required this.sender,
    required this.receiver,
    this.isRead = false,
    this.reactions = const [],
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      content: json['content'] ?? '',
      type: json['type'] ?? 'TEXT',
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : DateTime.now(),
      sender: User.fromJson(json['sender']),
      receiver: User.fromJson(json['receiver']),
      isRead: json['isRead'] ?? false,
      reactions: (json['reactions'] as List<dynamic>?)
              ?.map((e) => Reaction.fromJson(e))
              .toList() ??
          [],
    );
  }
}
