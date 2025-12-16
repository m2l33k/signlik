class User {
  final String id;
  final String name; // Mapped to 'username' from backend
  final String email;
  final String initials;
  final String role;
  int level;
  int translations;
  int minutesUsed;
  int streak;
  String preferredLanguage;
  String? profilePictureUrl;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.initials,
    this.role = 'USER',
    this.level = 1,
    this.translations = 0,
    this.minutesUsed = 0,
    this.streak = 0,
    this.preferredLanguage = 'TSL',
    this.profilePictureUrl,
  });

  String get username => name;

  factory User.fromJson(Map<String, dynamic> j) => User(
        id: j['id']?.toString() ?? 'u1',
        name: j['username'] ?? j['name'] ?? 'John Doe', // Backend uses 'username'
        email: j['email'] ?? 'john@example.com',
        initials: j['initials'] ?? (j['username'] != null && j['username'].isNotEmpty ? j['username'].substring(0, 1).toUpperCase() : 'JD'),
        role: j['role'] ?? 'USER',
        level: j['level'] ?? 1,
        translations: j['translations'] ?? 0,
        minutesUsed: j['minutesUsed'] ?? 0,
        streak: j['streak'] ?? 0,
        preferredLanguage: j['preferredLanguage'] ?? 'TSL',
        profilePictureUrl: j['profilePictureUrl'] ?? j['avatarUrl'],
      );
}
