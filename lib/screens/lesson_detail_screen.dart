import 'package:flutter/material.dart';
import '../models/sign.dart';
import '../widgets/sign_card.dart';
import '../widgets/video_player_widget.dart';

class LessonDetailScreen extends StatefulWidget {
  final String category;
  final List<Sign> signs;

  const LessonDetailScreen({
    super.key,
    required this.category,
    required this.signs,
  });

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  late PageController _controller;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentIndex < widget.signs.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Finished
      Navigator.pop(context, true); // Return true to indicate completion
    }
  }

  void _playSign(Sign s) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              color: Colors.black,
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 300),
              child: s.videoUrl.isNotEmpty 
                  ? VideoPlayerWidget(url: s.videoUrl)
                  : const Center(child: Text('No video available', style: TextStyle(color: Colors.white))),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: (_currentIndex + 1) / widget.signs.length,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          Expanded(
            child: PageView.builder(
              controller: _controller,
              physics: const NeverScrollableScrollPhysics(), // Disable swipe to force interaction? Or allow it.
              // Let's allow swipe for now, or maybe restrict it.
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: widget.signs.length,
              itemBuilder: (context, index) {
                final sign = widget.signs[index];
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sign ${index + 1} of ${widget.signs.length}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 20),
                        // Reuse SignCard but maybe make it bigger or specialized
                        Expanded(
                          child: SignCard(
                            sign: sign,
                            onPlay: () => _playSign(sign),
                            onToggleFavorite: () {
                              // Toggle favorite logic
                              setState(() {
                                sign.favorite = !sign.favorite;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _next,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            backgroundColor: Colors.blue.shade700,
                          ),
                          child: Text(
                            index == widget.signs.length - 1 ? "Finish Lesson" : "Next Sign",
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
