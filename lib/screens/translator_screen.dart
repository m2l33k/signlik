import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../widgets/bottom_nav.dart';
import '../services/camera_mock.dart';
import '../services/tts_service.dart';

class TranslatorCamera extends StatefulWidget {
  const TranslatorCamera({super.key});

  @override
  State<TranslatorCamera> createState() => _TranslatorCameraState();
}

class _TranslatorCameraState extends State<TranslatorCamera> {
  List<CameraDescription> cameras = [];
  CameraController? controller;
  int selectedCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    initCameras();
  }

  Future<void> initCameras() async {
    cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      controller =
          CameraController(cameras[selectedCameraIndex], ResolutionPreset.high);
      await controller!.initialize();
      if (mounted) setState(() {});
    }
  }

  void switchCamera() async {
    if (cameras.isEmpty) return;
    selectedCameraIndex = (selectedCameraIndex + 1) % cameras.length;
    controller =
        CameraController(cameras[selectedCameraIndex], ResolutionPreset.high);
    await controller!.initialize();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        CameraPreview(controller!),
        Positioned(
          top: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: switchCamera,
            mini: true,
            backgroundColor: Colors.black54,
            child: const Icon(Icons.cameraswitch, color: Colors.white),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
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

  void _toggleDetect() {
    setState(() {
      _detecting = !_detecting;
      _detected = _detecting ? 'Detecting signs...' : 'Translation will appear here...';
    });

    if (_detecting) {
      Future.delayed(const Duration(milliseconds: 900), () async {
        if (!_detecting) return;
        final res = CameraMock.simulateDetection();
        setState(() {
          _detected = res;
        });
        
        // Log detection
        try {
          final api = Provider.of<ApiService>(context, listen: false);
          await api.saveGestureHistory(res, 0.95); // High confidence for mock
        } catch (e) {
          print('Failed to log gesture: $e');
        }
      });
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
                children: const [
                  Column(
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
                  Icon(Icons.history, color: Colors.white),
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
                            const TranslatorCamera(),
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
