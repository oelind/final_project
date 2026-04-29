import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_database_mocks/firebase_database_mocks.dart';

void main() {
  test('Requirement 11: User data stored in Realtime Database', () async {
    final mockDatabase = MockFirebaseDatabase();
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

  test('Requirement 11: Drawing data stored in Realtime Database under user node', () async {
    final mockDatabase = MockFirebaseDatabase();
    const uid = 'user_123';
    
    await mockDatabase.ref('users/$uid/drawings').push().set({
      'userId': uid,
      'title': 'Firebase Artwork',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    final snapshot = await mockDatabase.ref('users/$uid/drawings').get();
    expect(snapshot.exists, true);
    final data = snapshot.value as Map;
    expect(data.length, 1);
    expect(data.values.first['title'], 'Firebase Artwork');
  });
}
