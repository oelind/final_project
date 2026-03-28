import 'package:cloud_firestore/cloud_firestore.dart';

class Drawing {
  final String title;
  final String description;
  final List<String> colors;
  final List<String> mediums;
  final String size;
  final String effort;
  final DateTime timestamp;
  final Duration timeSpent;

  const Drawing({
    required this.title,
    required this.description,
    required this.colors,
    required this.mediums,
    required this.size,
    required this.effort,
    required this.timestamp,
    required this.timeSpent,
  });

  factory Drawing.fromFirestore(Map<String, dynamic> data) {
    return Drawing(
      title: data['title'] ?? 'Untitled',
      description: data['description'] ?? '',
      colors: List<String>.from(data['colors'] ?? []),
      mediums: List<String>.from(data['mediums'] ?? []),
      size: data['size'] ?? '',
      effort: data['effort'] ?? 'Medium',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      timeSpent: Duration(minutes: data['timeSpentMinutes'] ?? 0),
    );
  }
}
