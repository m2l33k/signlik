class Lesson {
  final String id;
  final String title;
  final String description;
  int progress; // 0..100
  String difficulty;
  int signsCount;
  int durationMin;

  Lesson({
    required this.id,
    required this.title,
    required this.description,
    this.progress = 0,
    this.difficulty = 'Beginner',
    this.signsCount = 0,
    this.durationMin = 0,
  });

  factory Lesson.fromJson(Map<String, dynamic> j) => Lesson(
        id: j['id'].toString(),
        title: j['title'] ?? '',
        description: j['description'] ?? '',
        progress: j['progress'] ?? 0,
        difficulty: j['difficulty'] ?? 'Beginner',
        signsCount: j['signsCount'] ?? 0,
        durationMin: j['durationMin'] ?? 0,
      );
}
