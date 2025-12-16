import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/hand_tracker.dart';

class CameraPreviewWidget extends StatelessWidget {
  const CameraPreviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HandTrackerService>(
      builder: (context, handTracker, _) {
        final controller = handTracker.cameraController;
        
        if (controller == null || !controller.value.isInitialized) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Stack(
          children: [
            // Camera preview
            SizedBox.expand(
              child: CameraPreview(controller),
            ),
            
            // Overlay to show hand detection status
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
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
                          : 'No Hand',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

