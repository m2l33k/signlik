import 'dart:convert';
import '../models/sign.dart';
import '../models/lesson.dart';
import '../models/message.dart';
import '../models/user.dart';

// Example signs (can be extended)
const String _signsJson = '''
[
  {"id":"s1","word":"Hello","description":"Wave your hand near the head.","category":"Greetings","difficulty":"Beginner","favorite":false},
  {"id":"s2","word":"Thank you","description":"Touch chin then move hand forward.","category":"Gratitude","difficulty":"Beginner","favorite":false},
  {"id":"s3","word":"Yes","description":"Make a fist and nod it.","category":"Responses","difficulty":"Beginner","favorite":false},
  {"id":"s4","word":"No","description":"Index and middle touch thumb.","category":"Responses","difficulty":"Beginner","favorite":false},
  {"id":"s5","word":"Help","description":"Fist on open palm and raise.","category":"Emergency","difficulty":"Intermediate","favorite":false}
]
''';

// Example lessons
const String _lessonsJson = '''
[
  {"id":"L1","title":"Greetings & Introductions","description":"Learn essential greetings and how to introduce yourself.","progress":100,"difficulty":"Beginner","signsCount":8,"durationMin":10},
  {"id":"L2","title":"Everyday Courtesy","description":"Please, thank you, sorry and polite gestures.","progress":60,"difficulty":"Beginner","signsCount":6,"durationMin":12},
  {"id":"L3","title":"Responses & Emotions","description":"Yes, No, Love, Feelings.","progress":0,"difficulty":"Intermediate","signsCount":5,"durationMin":8},
  {"id":"L4","title":"Emergency Signs","description":"Help, Stop, Danger and more.","progress":0,"difficulty":"Intermediate","signsCount":4,"durationMin":6},
  {"id":"L5","title":"Relationships","description":"Family & friend-related gestures.","progress":0,"difficulty":"Advanced","signsCount":7,"durationMin":9},
  {"id":"L6","title":"Review & Practice","description":"Mixed review of previous lessons in a challenge format.","progress":33,"difficulty":"Mixed","signsCount":10,"durationMin":15}
]
''';

// Example messages
const String _messagesJson = '''
[
  {"id":"m1","type":"sign","original":"(s1)","translation":"Hello","timestamp":"2025-11-11T10:00:00Z"},
  {"id":"m2","type":"text","original":"How are you?","translation":"(s7)","timestamp":"2025-11-11T10:02:00Z"}
]
''';

const String _userJson = '''
{
  "id":"u1","name":"John Doe","email":"john.doe@email.com","initials":"JD",
  "level":3,"translations":127,"minutesUsed":342,"streak":7,"preferredLanguage":"TSL"
}
''';

List<Sign> loadSigns() {
  final List<dynamic> arr = jsonDecode(_signsJson);
  return arr.map((e) => Sign.fromJson(Map<String, dynamic>.from(e))).toList();
}

List<Lesson> loadLessons() {
  final List<dynamic> arr = jsonDecode(_lessonsJson);
  return arr.map((e) => Lesson.fromJson(Map<String, dynamic>.from(e))).toList();
}

List<Message> loadMessages() {
  final List<dynamic> arr = jsonDecode(_messagesJson);
  return arr.map((e) => Message.fromJson(Map<String, dynamic>.from(e))).toList();
}

User loadUser() {
  return User.fromJson(jsonDecode(_userJson));
}
