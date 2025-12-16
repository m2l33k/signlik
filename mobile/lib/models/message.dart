class Message {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;
  final bool isMe;
  final MessageType type;
  final String? gestureSign; // TSL sign name if message came from gesture
  final double? gestureConfidence;

  Message({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    required this.isMe,
    this.type = MessageType.text,
    this.gestureSign,
    this.gestureConfidence,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? '',
      text: json['text'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      isMe: json['isMe'] ?? false,
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${json['type']}',
        orElse: () => MessageType.text,
      ),
      gestureSign: json['gestureSign'],
      gestureConfidence: json['gestureConfidence']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'isMe': isMe,
      'type': type.toString().split('.').last,
      'gestureSign': gestureSign,
      'gestureConfidence': gestureConfidence,
    };
  }
}

enum MessageType {
  text,
  gesture,
  system,
}

