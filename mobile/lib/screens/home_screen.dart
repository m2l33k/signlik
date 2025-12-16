import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/hand_tracker.dart';
import '../services/gesture_classifier.dart';
import '../services/api_service.dart';
import '../widgets/camera_preview_widget.dart';
import '../widgets/gesture_output_widget.dart';
import '../widgets/speech_button_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _predictionTimer;
  bool _autoSpeak = true;
  String? _lastSpokenWord;
  final ApiService _apiService = ApiService();
  bool _saveToHistory = true;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    final handTracker = context.read<HandTrackerService>();
    final gestureClassifier = context.read<GestureClassifierService>();

    await handTracker.initialize();
    await gestureClassifier.initialize();

    // Start prediction loop
    _startPredictionLoop();
  }

  void _startPredictionLoop() {
    _predictionTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final handTracker = context.read<HandTrackerService>();
      final gestureClassifier = context.read<GestureClassifierService>();

      if (handTracker.landmarks != null) {
        gestureClassifier.predictGesture(handTracker.landmarks);
        
        // Save to history if enabled
        if (_saveToHistory && gestureClassifier.currentGesture != null) {
          _saveGestureToHistory(gestureClassifier.currentGesture!, 
                               gestureClassifier.currentConfidence);
        }
      }
    });
  }

  Future<void> _saveGestureToHistory(String gesture, double confidence) async {
    try {
      // Only save if gesture changed to avoid duplicates
      if (gesture != _lastSpokenWord) {
        await _apiService.saveGestureHistory(gesture, confidence);
        _lastSpokenWord = gesture;
      }
    } catch (e) {
      // Silently fail - offline mode is supported
      debugPrint('Failed to save gesture history: $e');
    }
  }

  @override
  void dispose() {
    _predictionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gesture AI'),
        actions: [
          Consumer<HandTrackerService>(
            builder: (context, handTracker, _) {
              return Consumer<GestureClassifierService>(
                builder: (context, classifier, _) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        _buildStatusBadge(
                          'Hands',
                          handTracker.isInitialized ? 'Ready' : 'Error',
                          handTracker.isInitialized,
                        ),
                        const SizedBox(width: 8),
                        _buildStatusBadge(
                          'Model',
                          classifier.status,
                          classifier.isLoaded,
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          IconButton(
            icon: Icon(_autoSpeak ? Icons.volume_up : Icons.volume_off),
            onPressed: () {
              setState(() {
                _autoSpeak = !_autoSpeak;
              });
            },
            tooltip: _autoSpeak ? 'Disable auto-speak' : 'Enable auto-speak',
          ),
        ],
      ),
      body: Column(
        children: [
          // Gesture output display
          Expanded(
            flex: 1,
            child: Consumer<GestureClassifierService>(
              builder: (context, classifier, _) {
                return GestureOutputWidget(
                  gesture: classifier.currentGesture,
                  confidence: classifier.currentConfidence,
                );
              },
            ),
          ),

          // Camera preview
          Expanded(
            flex: 3,
            child: Consumer<HandTrackerService>(
              builder: (context, handTracker, _) {
                if (!handTracker.isInitialized) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (handTracker.error != null)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              handTracker.error!,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ElevatedButton(
                          onPressed: () => handTracker.initialize(),
                          child: const Text('Initialize Camera'),
                        ),
                      ],
                    ),
                  );
                }

                return const CameraPreviewWidget();
              },
            ),
          ),

          // Controls
          Expanded(
            flex: 1,
            child: Consumer<GestureClassifierService>(
              builder: (context, classifier, _) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SpeechButtonWidget(
                        text: classifier.currentGesture ?? '',
                        disabled: classifier.currentGesture == null,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try gestures: Hello, Yes, No, Thanks, Help',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String label, String status, bool isGood) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isGood ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$label: $status',
        style: TextStyle(
          fontSize: 12,
          color: isGood ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
