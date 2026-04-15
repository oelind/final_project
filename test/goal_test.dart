import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:final_project/app.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  testWidgets('Verify goal creation and saving from settings button', (WidgetTester tester) async {
    final mockFirestore = FakeFirebaseFirestore();
    final user = MockUser(
      isAnonymous: false,
      uid: 'test_user_id',
      email: 'test@example.com',
    );
    final mockAuth = MockFirebaseAuth(mockUser: user, signedIn: true);

    // Build the app
    await tester.pumpWidget(DrawingLogApp(
      auth: mockAuth, 
      firestore: mockFirestore,
      initialPrompts: ['Test Prompt'],
    ));
    await tester.pumpAndSettle();

    // 1. Open settings and select Edit Goal
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    
    await tester.tap(find.text('Edit Goal'));
    await tester.pumpAndSettle();

    // Verify we are on Goal Setup Screen
    expect(find.text('Goal & Notifications'), findsOneWidget);

    // 2. Enter a goal
    await tester.enterText(find.byType(TextField).first, '10.5');
    
    // 3. Tap Save & Continue
    await tester.tap(find.text('Save & Continue'));
    await tester.pumpAndSettle();

    // 4. Verify Success Pop-up (Requirement 12)
    expect(find.text('Goal Saved'), findsOneWidget);
    expect(find.textContaining('You were able to successfully create a goal that was saved!'), findsOneWidget);

    // 5. Tap OK on the pop-up
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // 6. Verify we are back on Home Screen (Requirement 12)
    expect(find.text('Drawing Log'), findsOneWidget);

    // 7. Verify Firestore data
    final userDoc = await mockFirestore.collection('users').doc('test_user_id').get();
    expect(userDoc.exists, true);
    final settings = userDoc.data()?['settings'];
    expect(settings['timeGoal'], 10.5);
  });
}
