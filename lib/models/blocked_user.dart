import 'user.dart';

class BlockedUser {
  final int id;
  final User user;
  final User blockedUser;
  final DateTime blockedAt;
  final String? reason;

  BlockedUser({
    required this.id,
    required this.user,
    required this.blockedUser,
    required this.blockedAt,
    this.reason,
  });

  factory BlockedUser.fromJson(Map<String, dynamic> json) {
    return BlockedUser(
      id: json['id'],
      user: User.fromJson(json['user']),
      blockedUser: User.fromJson(json['blockedUser']),
      blockedAt: json['blockedAt'] != null 
          ? DateTime.parse(json['blockedAt']) 
          : DateTime.now(),
      reason: json['reason'],
    );
  }
}
