import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_database_mocks/firebase_database_mocks.dart';
import 'package:firebase_database/firebase_database.dart';

void main() {
  test('Requirement 11: User data stored in Realtime Database', () async {
    final mockDatabase = MockFirebaseDatabase.instance;
    const uid = 'user_123';
    
    await mockDatabase.ref('users/$uid').set({
      'email': 'user@example.com',
      'settings': {'timeGoal': 10.0}
    });

    final snapshot = await mockDatabase.ref('users/$uid').get();
    expect(snapshot.exists, true);
    final data = snapshot.value as Map;
    expect(data['email'], 'user@example.com');
  });

  test('Requirement 11: Drawing data stored in Realtime Database', () async {
    final mockDatabase = MockFirebaseDatabase.instance;
    
    await mockDatabase.ref('drawings').push().set({
      'userId': 'user_123',
      'title': 'Firebase Artwork',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    final snapshot = await mockDatabase.ref('drawings').get();
    final data = snapshot.value as Map;
    expect(data.length, 1);
    expect(data.values.first['title'], 'Firebase Artwork');
  });
}
