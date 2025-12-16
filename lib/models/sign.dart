class Sign {
  final int? id;
  final String name;
  final String description;
  final String videoUrl;
  final String? signedVideoUrl;
  final String? thumbnailUrl;
  final String? signedThumbnailUrl;
  final String category;
  final String difficultyLevel;
  final int viewCount;
  final String? createdBy;
  bool favorite;

  String get word => name;
  String get difficulty => difficultyLevel;

  Sign({
    this.id,
    required this.name,
    this.description = '',
    required this.videoUrl,
    this.signedVideoUrl,
    this.thumbnailUrl,
    this.signedThumbnailUrl,
    this.category = 'General',
    this.difficultyLevel = 'Beginner',
    this.viewCount = 0,
    this.createdBy,
    this.favorite = false,
  });

  factory Sign.fromJson(Map<String, dynamic> json) {
    return Sign(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      signedVideoUrl: json['signedVideoUrl'],
      thumbnailUrl: json['thumbnailUrl'],
      signedThumbnailUrl: json['signedThumbnailUrl'],
      category: json['category'] ?? 'General',
      difficultyLevel: json['difficultyLevel'] ?? 'Beginner',
      viewCount: json['viewCount'] ?? 0,
      createdBy: json['createdBy'],
    );
  }
}
