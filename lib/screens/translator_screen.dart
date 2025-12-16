import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../widgets/bottom_nav.dart';
import '../services/tts_service.dart';
import '../services/hand_tracker.dart';

class TranslatorCamera extends StatefulWidget {
  final HandTrackerService handTracker;

  const TranslatorCamera({super.key, required this.handTracker});

  @override
  State<TranslatorCamera> createState() => _TranslatorCameraState();
}

class _TranslatorCameraState extends State<TranslatorCamera> {
  @override
  Widget build(BuildContext context) {
    if (widget.handTracker.cameraController == null || 
        !widget.handTracker.cameraController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        CameraPreview(widget.handTracker.cameraController!),
        // Add overlay for landmarks if desired
      ],
    );
  }
}

class TranslatorScreen extends StatefulWidget {
  const TranslatorScreen({super.key});

  @override
  State<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen> {
  bool _detecting = false;
  String _detected = 'Translation will appear here...';
  late HandTrackerService _handTracker;
  Timer? _predictionTimer;

  @override
  void initState() {
    super.initState();
    _handTracker = HandTrackerService();
    _handTracker.initialize();
  }

  @override
  void dispose() {
    _predictionTimer?.cancel();
    _handTracker.dispose();
    super.dispose();
  }

  void _toggleDetect() {
    setState(() {
      _detecting = !_detecting;
      _detected = _detecting ? 'Detecting signs...' : 'Translation will appear here...';
    });

    if (_detecting) {
      // Start prediction loop
      _predictionTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) async {
        if (!_detecting) {
          timer.cancel();
          return;
        }

        final landmarks = _handTracker.currentLandmarks;
        if (landmarks != null && landmarks.length == 42) {
           try {
              final api = Provider.of<ApiService>(context, listen: false);
              final result = await api.predictSign(landmarks);
              
              if (mounted) {
                setState(() {
                  _detected = "${result['label']} (${(result['confidence'] * 100).toStringAsFixed(1)}%)";
                });
                
                // Save history if confidence is high
                if (result['confidence'] > 0.85) {
                   await api.saveGestureHistory(result['label'], result['confidence']);
                }
              }
           } catch (e) {
             debugPrint("Prediction error: $e");
           }
        }
      });
    } else {
      _predictionTimer?.cancel();
    }
  }

  void _speak() {
    TtsService.speak(_detected);
  }

  void _simulateIncoming() {
    setState(() {
      _detected = 'Simulated translated text: Hello!';
    });
  }

  void _navTap(int idx) {
    if (idx == 0) Navigator.pushReplacementNamed(context, '/home');
    if (idx == 2) Navigator.pushReplacementNamed(context, '/learning');
    if (idx == 3) Navigator.pushReplacementNamed(context, '/profile');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade700, Colors.purple.shade600],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Translator',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'TSL • Real-time translation',
                        style: TextStyle(color: Color(0xFFBBDEFB), fontSize: 12),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.history, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Camera + translation area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            ChangeNotifierProvider.value(
                              value: _handTracker,
                              child: Consumer<HandTrackerService>(
                                builder: (context, tracker, child) {
                                  if (tracker.error != null) {
                                    return Center(child: Text(tracker.error!));
                                  }
                                  return TranslatorCamera(handTracker: tracker);
                                },
                              ),
                            ),
                            if (_detecting)
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.blue.shade500, width: 4),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[850] : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue.shade200, width: 2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Detected Sign:',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _detected,
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Reactions UI
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.thumb_up_alt_outlined, size: 20),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Liked translation')));
                                  // Call API in real app: api.addReaction(messageId, 'LIKE');
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.favorite_border, size: 20),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Loved translation')));
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.sentiment_dissatisfied, size: 20),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marked as incorrect')));
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Buttons
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      backgroundColor: _detecting ? Colors.red : Colors.blue,
                    ),
                    onPressed: _toggleDetect,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_detecting ? Icons.stop_circle : Icons.play_arrow),
                        const SizedBox(width: 8),
                        Text(_detecting
                            ? 'Stop Detecting'
                            : 'Start Sign Detection'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: _simulateIncoming,
                    child: const Text('Simulate Received Translation'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _speak,
                    child: const Text('Speak'),
                  ),
                ],
              ),
            ),

            // Bottom Navigation
            BottomNav(currentIndex: 1, onTap: _navTap),
          ],
        ),
      ),
    );
  }
}
