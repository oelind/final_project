import '../models/user.dart';

class MockData {
  static const List<User> users = [
    User(email: 'user1@example.com', password: 'password123'),
    User(email: 'artist1@draw.com', password: 'drawpassword'),
    User(email: 'pencil@sketch.io', password: 'sketchy123'),
    User(email: 'admin@drawinglog.com', password: 'adminpassword'),
  ];
}
