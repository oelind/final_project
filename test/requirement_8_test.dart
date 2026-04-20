import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:final_project/widgets/drawing_log_dialog.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  testWidgets('Requirement 8: Real-time log entry with timer', (WidgetTester tester) async {
    final user = MockUser(uid: 'test_uid');
    final mockAuth = MockFirebaseAuth(mockUser: user, signedIn: true);
    final mockFirestore = FakeFirebaseFirestore();

    await tester.pumpWidget(MaterialApp(home: DrawingLogDialog(auth: mockAuth, firestore: mockFirestore)));
    await tester.pumpAndSettle();

    final timerButtonFinder = find.byIcon(Icons.play_arrow);
    expect(timerButtonFinder, findsOneWidget);

    // Start timer
    await tester.tap(timerButtonFinder);
    await tester.pump(const Duration(seconds: 2));

    expect(find.byIcon(Icons.stop), findsOneWidget);
    // After 2 seconds, minutes should be > 0 in the text field if updating frequently, 
    // but the implementation updates per second: _timeController.text = (_secondsElapsed / 60.0).toStringAsFixed(1);
    // So 2 seconds / 60 = 0.033... fixed(1) is 0.0.
    
    await tester.pump(const Duration(seconds: 60)); // 62 seconds total
    expect(find.text('1.0'), findsOneWidget); // 60/60 = 1.0

    // Stop timer
    await tester.tap(find.byIcon(Icons.stop));
    await tester.pump();

    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
  });
}
