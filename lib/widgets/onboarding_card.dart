import 'package:flutter/material.dart';

class OnboardingCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const OnboardingCard({super.key, required this.title, required this.description, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [color.withOpacity(.9), color.withOpacity(.6)])),
        child: Center(child: Icon(icon, color: Colors.white, size: 48)),
      ),
      const SizedBox(height: 24),
      Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
      const SizedBox(height: 12),
      Text(description, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
    ]);
  }
}
