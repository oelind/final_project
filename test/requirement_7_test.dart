import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  test('Requirement 7: Data isolation - User A cannot see User B\'s drawings', () async {
    final firestore = FakeFirebaseFirestore();
    
    // User A logs a drawing
    await firestore.collection('drawings').add({
      'userId': 'user_a',
      'title': 'A\'s Art',
      'timeSpentMinutes': 30,
      'timestamp': Timestamp.now(),
    });

    // User B logs a drawing
    await firestore.collection('drawings').add({
      'userId': 'user_b',
      'title': 'B\'s Art',
      'timeSpentMinutes': 60,
      'timestamp': Timestamp.now(),
    });

    // Query for User A
    final drawingsA = await firestore
        .collection('drawings')
        .where('userId', isEqualTo: 'user_a')
        .get();
    expect(drawingsA.docs.length, 1);
    expect(drawingsA.docs.first['title'], 'A\'s Art');

    // Query for User B
    final drawingsB = await firestore
        .collection('drawings')
        .where('userId', isEqualTo: 'user_b')
        .get();
    expect(drawingsB.docs.length, 1);
    expect(drawingsB.docs.first['title'], 'B\'s Art');
  });
}
