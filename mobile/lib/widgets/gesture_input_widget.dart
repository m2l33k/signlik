import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/hand_tracker.dart';
import '../services/gesture_classifier.dart';

class GestureInputWidget extends StatefulWidget {
  final Function(String gestureSign, double confidence) onGestureRecognized;

  const GestureInputWidget({
    super.key,
    required this.onGestureRecognized,
  });

  @override
  State<GestureInputWidget> createState() => _GestureInputWidgetState();
}

class _GestureInputWidgetState extends State<GestureInputWidget> {
  String? _currentGesture;
  double _currentConfidence = 0.0;
  bool _isRecording = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      color: Colors.black,
      child: Column(
        children: [
          // Status bar
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.black87,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Consumer<HandTrackerService>(
                  builder: (context, handTracker, _) {
                    return Row(
                      children: [
                        Icon(
                          handTracker.landmarks != null
                              ? Icons.hand_gesture
                              : Icons.hand_gesture_outlined,
                          color: handTracker.landmarks != null
                              ? Colors.green
                              : Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          handTracker.landmarks != null
                              ? 'Hand Detected'
                              : 'Show your hand',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    );
                  },
                ),
                Consumer<GestureClassifierService>(
                  builder: (context, classifier, _) {
                    if (classifier.currentGesture != null) {
                      _currentGesture = classifier.currentGesture;
                      _currentConfidence = classifier.currentConfidence;
                    }
                    return Text(
                      classifier.currentGesture ?? 'No gesture',
                      style: TextStyle(
                        color: classifier.currentGesture != null
                            ? Colors.green
                            : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Camera preview
          Expanded(
            child: Consumer<HandTrackerService>(
              builder: (context, handTracker, _) {
                if (!handTracker.isInitialized) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                return Stack(
                  children: [
                    // Camera preview would go here
                    // For now, show a placeholder
                    Container(
                      color: Colors.grey[900],
                      child: const Center(
                        child: Icon(
                          Icons.camera_alt,
                          size: 64,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Controls
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.black87,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Current gesture display
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _currentGesture ?? 'No gesture',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_currentConfidence > 0)
                          Text(
                            '${(_currentConfidence * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Send button
                ElevatedButton.icon(
                  onPressed: _currentGesture != null && _currentConfidence > 0.5
                      ? () {
                          widget.onGestureRecognized(
                            _currentGesture!,
                            _currentConfidence,
                          );
                          setState(() {
                            _currentGesture = null;
                            _currentConfidence = 0.0;
                          });
                        }
                      : null,
                  icon: const Icon(Icons.send),
                  label: const Text('Send'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

