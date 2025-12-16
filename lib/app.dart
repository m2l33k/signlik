import 'package:flutter/material.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/translator_screen.dart';
import 'screens/dictionary_screen.dart';
import 'screens/learning_screen.dart';
import 'screens/profile_screen.dart';
import 'services/storage_service.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool? _onboarded;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _onboarded = await StorageService.isOnboarded();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Use system theme (adaptive)
    return MaterialApp(
      title: 'SignLik',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        useMaterial3: false,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(primary: Colors.blueAccent),
        useMaterial3: false,
      ),
      themeMode: ThemeMode.system,
      initialRoute: _onboarded == true ? '/home' : '/onboarding',
      routes: {
        '/onboarding': (_) => const OnboardingScreen(),
        '/home': (_) => const HomeScreen(),
        '/translator': (_) => const TranslatorScreen(),
        '/dictionary': (_) => const DictionaryScreen(),
        '/learning': (_) => const LearningScreen(),
        '/profile': (_) => const ProfileScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
