import '../models/user.dart';
import '../models/drawing.dart';

class MockData {
  static const List<User> users = [
    User(email: 'user1@example.com', password: 'password123'),
    User(email: 'artist1@draw.com', password: 'drawpassword'),
    User(email: 'pencil@sketch.io', password: 'sketchy123'),
    User(email: 'admin@drawinglog.com', password: 'adminpassword'),
  ];

  static final List<Drawing> drawings = [
    Drawing(
      title: 'Ocean Sunset',
      description: 'A vibrant sunset over the Pacific Ocean.',
      colors: ['Orange', 'Purple', 'Deep Blue', 'Yellow'],
      mediums: ['Oil Paint', 'Canvas'],
      size: '18x24 inches',
      effort: 'High',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      timeSpent: const Duration(hours: 5, minutes: 30),
    ),
    Drawing(
      title: 'Forest Path',
      description: 'A misty path through an ancient pine forest.',
      colors: ['Green', 'Brown', 'Grey', 'Misty White'],
      mediums: ['Charcoal', 'Paper'],
      size: 'A4',
      effort: 'Medium',
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
      timeSpent: const Duration(hours: 2, minutes: 15),
    ),
  ];
}
