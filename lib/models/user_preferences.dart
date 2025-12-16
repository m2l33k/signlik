class UserPreferences {
  final int? id;
  final String language;
  final String theme;
  final bool notificationsEnabled;
  final bool emailNotifications;
  final bool pushNotifications;
  final bool autoPlayMedia;
  final bool showOnlineStatus;
  final bool allowFriendRequests;
  final bool messageSoundEnabled;

  UserPreferences({
    this.id,
    this.language = 'en',
    this.theme = 'light',
    this.notificationsEnabled = true,
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.autoPlayMedia = false,
    this.showOnlineStatus = true,
    this.allowFriendRequests = true,
    this.messageSoundEnabled = true,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      id: json['id'],
      language: json['language'] ?? 'en',
      theme: json['theme'] ?? 'light',
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      emailNotifications: json['emailNotifications'] ?? true,
      pushNotifications: json['pushNotifications'] ?? true,
      autoPlayMedia: json['autoPlayMedia'] ?? false,
      showOnlineStatus: json['showOnlineStatus'] ?? true,
      allowFriendRequests: json['allowFriendRequests'] ?? true,
      messageSoundEnabled: json['messageSoundEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'language': language,
      'theme': theme,
      'notificationsEnabled': notificationsEnabled,
      'emailNotifications': emailNotifications,
      'pushNotifications': pushNotifications,
      'autoPlayMedia': autoPlayMedia,
      'showOnlineStatus': showOnlineStatus,
      'allowFriendRequests': allowFriendRequests,
      'messageSoundEnabled': messageSoundEnabled,
    };
  }
}
