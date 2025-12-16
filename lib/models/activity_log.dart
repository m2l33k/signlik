class ActivityLog {
  final int id;
  final String action;
  final String description;
  final DateTime timestamp;

  ActivityLog({
    required this.id,
    required this.action,
    required this.description,
    required this.timestamp,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id'],
      action: json['action'] ?? '',
      description: json['description'] ?? '',
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : DateTime.now(),
    );
  }
}
