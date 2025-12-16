import 'package:flutter/material.dart';
import '../widgets/onboarding_card.dart';
import '../services/storage_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  final slides = [
    {'title': 'Welcome to SignLik', 'desc': 'Learn and translate sign language in real-time.', 'icon': Icons.handshake, 'color': Colors.blue},
    {'title': 'Real-time translation', 'desc': 'Translate voice and sign to each other instantly.', 'icon': Icons.volume_up, 'color': Colors.purple},
    {'title': 'Learn & Practice', 'desc': 'Structured lessons, practice sets and achievements.', 'icon': Icons.menu_book, 'color': Colors.green},
  ];

  void _next() async {
    if (_index < slides.length - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      await StorageService.setOnboarded(true);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void _skip() async {
    await StorageService.setOnboarded(true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 448),
            child: Column(children: [
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: slides.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (_, i) {
                    final s = slides[i];
                    return Padding(padding: const EdgeInsets.all(24.0), child: OnboardingCard(title: s['title'] as String, description: s['desc'] as String, icon: s['icon'] as IconData, color: s['color'] as Color));
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(slides.length, (i) {
                    final active = i == _index;
                    return AnimatedContainer(duration: const Duration(milliseconds: 300), margin: const EdgeInsets.symmetric(horizontal: 6), width: active ? 32 : 8, height: 8, decoration: BoxDecoration(color: active ? Colors.blue[600] : Colors.grey[300], borderRadius: BorderRadius.circular(8)));
                  })),
                  const SizedBox(height: 12),
                  Row(children: [
                    if (_index < slides.length - 1) Expanded(child: OutlinedButton(onPressed: _skip, child: const Text('Skip'))),
                    if (_index < slides.length - 1) const SizedBox(width: 12),
                    Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: _index == 0 ? Colors.blue : _index == 1 ? Colors.purple : Colors.green), onPressed: _next, child: Text(_index < slides.length - 1 ? 'Next' : 'Get Started'))),
                  ]),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
