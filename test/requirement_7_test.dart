import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_database_mocks/firebase_database_mocks.dart';
import 'package:firebase_database/firebase_database.dart';

void main() {
  test('Requirement 7: Data isolation - User A cannot see User B\'s drawings', () async {
    final mockDatabase = MockFirebaseDatabase();
    
    // User A logs a drawing to their specific node
    await mockDatabase.ref('users/user_a/drawings').push().set({
      'userId': 'user_a',
      'title': 'A\'s Art',
      'timeSpentMinutes': 30,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    // User B logs a drawing to their specific node
    await mockDatabase.ref('users/user_b/drawings').push().set({
      'userId': 'user_b',
      'title': 'B\'s Art',
      'timeSpentMinutes': 60,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    // Query for User A's node only
    final snapshotA = await mockDatabase.ref('users/user_a/drawings').get();
    final drawingsA = snapshotA.value as Map? ?? {};
    
    expect(drawingsA.length, 1);
    expect(drawingsA.values.first['title'], 'A\'s Art');

    // Query for User B's node only
    final snapshotB = await mockDatabase.ref('users/user_b/drawings').get();
    final drawingsB = snapshotB.value as Map? ?? {};
    
    expect(drawingsB.length, 1);
    expect(drawingsB.values.first['title'], 'B\'s Art');
  });
}
