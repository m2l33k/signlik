import 'package:flutter/material.dart';
import '../services/gesture_mapper.dart';
import 'package:cached_network_image/cached_network_image.dart';

class GestureDisplayWidget extends StatefulWidget {
  final String text;
  final bool showGestures;

  const GestureDisplayWidget({
    super.key,
    required this.text,
    this.showGestures = true,
  });

  @override
  State<GestureDisplayWidget> createState() => _GestureDisplayWidgetState();
}

class _GestureDisplayWidgetState extends State<GestureDisplayWidget> {
  List<String> _gestures = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGestures();
  }

  @override
  void didUpdateWidget(GestureDisplayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _loadGestures();
    }
  }

  Future<void> _loadGestures() async {
    if (!widget.showGestures || widget.text.isEmpty) {
      setState(() {
        _gestures = [];
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final mapper = await GestureMapper.getInstance();
      final gestures = mapper.textToGestures(widget.text);
      setState(() {
        _gestures = gestures;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _gestures = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showGestures || _gestures.isEmpty) {
      return const SizedBox.shrink();
    }

    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: SizedBox(
          height: 40,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gestures:',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _gestures.map((gesture) {
              return _GestureImage(gestureSign: gesture);
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _GestureImage extends StatelessWidget {
  final String gestureSign;

  const _GestureImage({required this.gestureSign});

  @override
  Widget build(BuildContext context) {
    // Try to load gesture image from assets
    // Format: assets/gestures/{gesture_sign}.png
    final imagePath = 'assets/gestures/$gestureSign.png';
    
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback: show gesture name
            return Center(
              child: Text(
                gestureSign.length > 4
                    ? gestureSign.substring(0, 4)
                    : gestureSign,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            );
          },
        ),
      ),
    );
  }
}

