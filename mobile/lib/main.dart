import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/conversations_screen.dart';
import 'services/chat_service.dart';
import 'services/gesture_classifier.dart';
import 'services/hand_tracker.dart';

void main() {
  runApp(const GestureAIApp());
}

class GestureAIApp extends StatelessWidget {
  const GestureAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatService()),
        ChangeNotifierProvider(create: (_) => HandTrackerService()),
        ChangeNotifierProvider(create: (_) => GestureClassifierService()),
      ],
      child: MaterialApp(
        title: 'TSL Chat',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const ConversationsScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

