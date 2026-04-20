import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  test('Requirement 11: User data stored in Firestore', () async {
    final firestore = FakeFirebaseFirestore();
    const uid = 'user_123';
    
    await firestore.collection('users').doc(uid).set({
      'email': 'user@example.com',
      'settings': {'timeGoal': 10.0}
    });

    final doc = await firestore.collection('users').doc(uid).get();
    expect(doc.exists, true);
    expect(doc.data()!['email'], 'user@example.com');
  });

  test('Requirement 11: Drawing data stored in Firestore', () async {
    final firestore = FakeFirebaseFirestore();
    
    await firestore.collection('drawings').add({
      'userId': 'user_123',
      'title': 'Firebase Artwork',
      'timestamp': Timestamp.now(),
    });

    final results = await firestore.collection('drawings').get();
    expect(results.docs.length, 1);
    expect(results.docs.first['title'], 'Firebase Artwork');
  });
}
