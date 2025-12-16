import 'user.dart';

class Friendship {
  final int id;
  final User requester;
  final User addressee;
  final String status;
  final DateTime createdAt;

  Friendship({
    required this.id,
    required this.requester,
    required this.addressee,
    required this.status,
    required this.createdAt,
  });

  factory Friendship.fromJson(Map<String, dynamic> json) {
    return Friendship(
      id: json['id'],
      requester: User.fromJson(json['user1'] ?? json['requester']),
      addressee: User.fromJson(json['user2'] ?? json['addressee']),
      status: json['status'] ?? 'PENDING',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }
}
