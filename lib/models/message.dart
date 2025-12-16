class Message {
  final String id;
  final String type; // 'sign'|'voice'|'text'
  final String original;
  final String translation;
  final String timestamp;

  Message({
    required this.id,
    required this.type,
    required this.original,
    required this.translation,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> j) => Message(
        id: j['id'] ?? '',
        type: j['type'] ?? 'text',
        original: j['original'] ?? '',
        translation: j['translation'] ?? '',
        timestamp: j['timestamp'] ?? '',
      );
}
