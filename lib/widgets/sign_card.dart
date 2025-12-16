import 'package:flutter/material.dart';
import '../models/sign.dart';

class SignCard extends StatelessWidget {
  final Sign sign;
  final bool isFavorite;
  final VoidCallback? onPlay;
  final VoidCallback? onToggleFavorite;

  const SignCard({
    super.key, 
    required this.sign, 
    this.isFavorite = false,
    this.onPlay, 
    this.onToggleFavorite
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.blue.shade50, Colors.purple.shade50]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Icon(Icons.play_circle_outline, color: Colors.blue[600], size: 32)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(sign.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                IconButton(
                  onPressed: onToggleFavorite,
                  icon: Icon(isFavorite ? Icons.star : Icons.star_border, color: isFavorite ? Colors.amber : Colors.grey),
                ),
              ]),
              const SizedBox(height: 6),
              Text(sign.description, style: const TextStyle(color: Colors.grey), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              Wrap(spacing: 8, children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                  child: Text(sign.category, style: TextStyle(color: Colors.blue.shade700, fontSize: 12)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(8)),
                  child: Text(sign.difficultyLevel, style: TextStyle(color: Colors.purple.shade700, fontSize: 12)),
                ),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}
