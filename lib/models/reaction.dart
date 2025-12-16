class Reaction {
  final int id;
  final String userEmail;
  final String reaction;
  final DateTime timestamp;

  Reaction({
    required this.id,
    required this.userEmail,
    required this.reaction,
    required this.timestamp,
  });

  factory Reaction.fromJson(Map<String, dynamic> json) {
    // Backend returns 'user' object with 'email' field
    String email = '';
    if (json['user'] != null && json['user'] is Map) {
      email = json['user']['email'] ?? '';
    } else if (json['userEmail'] != null) {
      email = json['userEmail'];
    }

    return Reaction(
      id: json['id'],
      userEmail: email,
      reaction: json['reaction'] ?? '',
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : DateTime.now(),
    );
  }
}
