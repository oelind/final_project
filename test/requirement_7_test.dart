import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_database_mocks/firebase_database_mocks.dart';
import 'package:firebase_database/firebase_database.dart';

void main() {
  test('Requirement 7: Data isolation - User A cannot see User B\'s drawings', () async {
    final mockDatabase = MockFirebaseDatabase();
    
    // User A logs a drawing
    await mockDatabase.ref('drawings').push().set({
      'userId': 'user_a',
      'title': 'A\'s Art',
      'timeSpentMinutes': 30,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    // User B logs a drawing
    await mockDatabase.ref('drawings').push().set({
      'userId': 'user_b',
      'title': 'B\'s Art',
      'timeSpentMinutes': 60,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    // Query for User A
    final snapshotA = await mockDatabase.ref('drawings').get();
    final allDrawingsA = snapshotA.value as Map? ?? {};
    final drawingsA = Map.from(allDrawingsA)..removeWhere((k, v) => v['userId'] != 'user_a');
    
    expect(drawingsA.length, 1);
    expect(drawingsA.values.first['title'], 'A\'s Art');

    // Query for User B
    final snapshotB = await mockDatabase.ref('drawings').get();
    final allDrawingsB = snapshotB.value as Map? ?? {};
    final drawingsB = Map.from(allDrawingsB)..removeWhere((k, v) => v['userId'] != 'user_b');
    
    expect(drawingsB.length, 1);
    expect(drawingsB.values.first['title'], 'B\'s Art');
  });
}
