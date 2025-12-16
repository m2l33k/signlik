import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class SpeechButtonWidget extends StatefulWidget {
  final String text;
  final bool disabled;

  const SpeechButtonWidget({
    super.key,
    required this.text,
    this.disabled = false,
  });

  @override
  State<SpeechButtonWidget> createState() => _SpeechButtonWidgetState();
}

class _SpeechButtonWidgetState extends State<SpeechButtonWidget> {
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _initializeTts();
  }

  Future<void> _initializeTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    _tts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
      });
    });
  }

  Future<void> _speak() async {
    if (widget.text.isEmpty || widget.disabled) return;

    setState(() {
      _isSpeaking = true;
    });

    await _tts.speak(widget.text);
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: widget.disabled || _isSpeaking ? null : _speak,
      icon: _isSpeaking
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.volume_up),
      label: Text(_isSpeaking ? 'Speaking...' : 'Speak'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        minimumSize: const Size(200, 48),
      ),
    );
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}

