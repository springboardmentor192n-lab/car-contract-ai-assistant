import 'package:flutter/material.dart';

class CarNewsCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String date;

  const CarNewsCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Text(
            date,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class CarNewsListItem extends StatelessWidget {
  final String title;
  final String source;

  const CarNewsListItem({super.key, required this.title, required this.source});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.article, color: Colors.white70, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                Text(
                  source,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
