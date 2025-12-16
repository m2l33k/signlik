import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Maps text to TSL gesture signs
class GestureMapper {
  static GestureMapper? _instance;
  Map<String, String> _wordToGesture = {};
  Map<String, String> _letterToGesture = {};
  bool _isLoaded = false;

  GestureMapper._();

  static Future<GestureMapper> getInstance() async {
    _instance ??= GestureMapper._();
    if (!_instance!._isLoaded) {
      await _instance!._loadMappings();
    }
    return _instance!;
  }

  Future<void> _loadMappings() async {
    try {
      // Load word-to-gesture mappings
      final wordMappingData = await rootBundle.loadString('assets/tsl_word_mappings.json');
      _wordToGesture = Map<String, String>.from(jsonDecode(wordMappingData));
      
      // Load letter-to-gesture mappings (A-Z)
      final letterMappingData = await rootBundle.loadString('assets/tsl_letter_mappings.json');
      _letterToGesture = Map<String, String>.from(jsonDecode(letterMappingData));
      
      _isLoaded = true;
      debugPrint('Gesture mappings loaded successfully');
    } catch (e) {
      debugPrint('Error loading gesture mappings: $e');
      // Use default mappings
      _createDefaultMappings();
      _isLoaded = true;
    }
  }

  void _createDefaultMappings() {
    // Default word mappings (Tunisian Sign Language)
    _wordToGesture = {
      'hello': 'hello',
      'hi': 'hello',
      'goodbye': 'goodbye',
      'bye': 'goodbye',
      'thank you': 'thank_you',
      'thanks': 'thank_you',
      'please': 'please',
      'sorry': 'sorry',
      'yes': 'yes',
      'no': 'no',
      'maybe': 'maybe',
      'ok': 'ok',
      'okay': 'ok',
      'help': 'help',
      'mother': 'mother',
      'father': 'father',
      'brother': 'brother',
      'sister': 'sister',
      'family': 'family',
      'water': 'water',
      'food': 'food',
      'eat': 'eat',
      'drink': 'drink',
      'sleep': 'sleep',
      'house': 'house',
      'school': 'school',
      'work': 'work',
      'home': 'home',
      'friend': 'friend',
      'today': 'today',
      'tomorrow': 'tomorrow',
      'yesterday': 'yesterday',
      'morning': 'morning',
      'evening': 'evening',
      'what': 'what',
      'where': 'where',
      'when': 'when',
      'why': 'why',
      'how': 'how',
      'who': 'who',
      'go': 'go',
      'come': 'come',
      'see': 'see',
      'hear': 'hear',
      'speak': 'speak',
      'read': 'read',
      'write': 'write',
      'learn': 'learn',
      'teach': 'teach',
      'understand': 'understand',
      'good': 'good',
      'bad': 'bad',
      'happy': 'happy',
      'sad': 'sad',
      'love': 'love',
      'like': 'like',
      'want': 'want',
      'need': 'need',
    };

    // Letter mappings (A-Z to TSL alphabet)
    _letterToGesture = {
      'a': 'a', 'b': 'b', 'c': 'c', 'd': 'd', 'e': 'e',
      'f': 'f', 'g': 'g', 'h': 'h', 'i': 'i', 'j': 'j',
      'k': 'k', 'l': 'l', 'm': 'm', 'n': 'n', 'o': 'o',
      'p': 'p', 'q': 'q', 'r': 'r', 's': 's', 't': 't',
      'u': 'u', 'v': 'v', 'w': 'w', 'x': 'x', 'y': 'y',
      'z': 'z',
    };
  }

  /// Convert text to list of gesture signs
  /// Returns list of gesture sign names
  List<String> textToGestures(String text) {
    if (!_isLoaded) {
      _createDefaultMappings();
    }

    final words = text.toLowerCase().split(RegExp(r'\s+'));
    final gestures = <String>[];

    for (final word in words) {
      // Remove punctuation
      final cleanWord = word.replaceAll(RegExp(r'[^\w]'), '');
      
      if (cleanWord.isEmpty) continue;

      // Try word mapping first
      if (_wordToGesture.containsKey(cleanWord)) {
        gestures.add(_wordToGesture[cleanWord]!);
      } else {
        // Fallback to letter-by-letter spelling
        for (final letter in cleanWord.split('')) {
          if (_letterToGesture.containsKey(letter)) {
            gestures.add(_letterToGesture[letter]!);
          }
        }
      }
    }

    return gestures;
  }

  /// Get gesture sign for a single word
  String? getGestureForWord(String word) {
    if (!_isLoaded) {
      _createDefaultMappings();
    }
    return _wordToGesture[word.toLowerCase()];
  }

  /// Get gesture sign for a single letter
  String? getGestureForLetter(String letter) {
    if (!_isLoaded) {
      _createDefaultMappings();
    }
    return _letterToGesture[letter.toLowerCase()];
  }
}

