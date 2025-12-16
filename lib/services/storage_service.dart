import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _onboardKey = 'onboarded';
  static const _signsKey = 'signs';

  static Future<bool> isOnboarded() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(_onboardKey) ?? false;
  }

  static Future<void> setOnboarded([bool v = true]) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_onboardKey, v);
  }

  static Future<void> saveSignsJson(List<Map<String, dynamic>> signs) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_signsKey, jsonEncode(signs));
  }

  static Future<List<Map<String, dynamic>>> loadSignsJson() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_signsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return List<Map<String, dynamic>>.from(list);
  }
}
