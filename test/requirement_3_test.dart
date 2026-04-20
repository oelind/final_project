import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:final_project/goal_setup_screen.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  testWidgets('Requirement 3: Store notification preferences', (WidgetTester tester) async {
    // Increase size to avoid off-screen issues
    tester.view.physicalSize = const Size(1200, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final user = MockUser(uid: 'test_uid');
    final mockAuth = MockFirebaseAuth(mockUser: user, signedIn: true);
    final mockFirestore = FakeFirebaseFirestore();

    await tester.pumpWidget(MaterialApp(home: GoalSetupScreen(auth: mockAuth, firestore: mockFirestore)));
    await tester.pumpAndSettle();

    final switchFinder = find.byType(Switch);
    expect(switchFinder, findsOneWidget);

    // Toggle on
    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '5');
    
    final saveButton = find.text('Save & Continue');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();
    
    expect(find.text('Goal Saved'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    final doc = await mockFirestore.collection('users').doc('test_uid').get();
    expect(doc.data()!['settings']['wantNotifications'], true);
  });
}
