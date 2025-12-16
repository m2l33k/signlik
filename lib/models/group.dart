import 'user.dart';

class Group {
  final int? id;
  final String name;
  final String description;
  final User? creator;
  final DateTime createdAt;
  final bool isActive;

  Group({
    this.id,
    required this.name,
    this.description = '',
    this.creator,
    required this.createdAt,
    this.isActive = true,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      creator: json['creator'] != null ? User.fromJson(json['creator']) : null,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      isActive: json['isActive'] ?? true,
    );
  }
}
