import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:final_project/app.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  testWidgets('Verify drawing log entries persist after app "restart"', (WidgetTester tester) async {
    // 1. Setup persistent mock instances
    final mockFirestore = FakeFirebaseFirestore();
    final user = MockUser(
      isAnonymous: false,
      uid: 'persistent_user_id',
      email: 'persistent@example.com',
    );
    final mockAuth = MockFirebaseAuth(mockUser: user, signedIn: true);

    // 2. "First Run": Add a drawing log
    await tester.pumpWidget(DrawingLogApp(
      auth: mockAuth, 
      firestore: mockFirestore,
      initialPrompts: ['Test Prompt'],
    ));
    await tester.pumpAndSettle();

    // Verify we are on Home Screen
    expect(find.text('Drawing Log'), findsOneWidget);

    // Add a drawing
    final fabFinder = find.byType(FloatingActionButton);
    await tester.tap(fabFinder);
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Title (Optional)'), 'Persistent Entry');
    await tester.enterText(find.widgetWithText(TextFormField, 'Time Spent (Minutes)'), '60');
    
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Verify it's visible
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Persistent Entry'), findsOneWidget);

    // 3. "Shutdown": Clear the widget tree
    await tester.pumpWidget(Container());
    await tester.pumpAndSettle();

    // 4. "Restart": Rebuild the app with the same mockFirestore instance
    // Note: We use the same mockFirestore but a "new" app instance
    await tester.pumpWidget(DrawingLogApp(
      auth: mockAuth, 
      firestore: mockFirestore,
      initialPrompts: ['Test Prompt'],
    ));
    await tester.pumpAndSettle();

    // 5. Verify data is still there
    // The LoginPage should auto-navigate because user is still signed in
    await tester.pumpAndSettle();
    
    // Extra pump for StreamBuilder
    await tester.pump(const Duration(milliseconds: 100));
    
    expect(find.text('Persistent Entry'), findsOneWidget);
    
    // 6. Double-check directly in Firestore
    final drawings = await mockFirestore
        .collection('drawings')
        .where('userId', isEqualTo: 'persistent_user_id')
        .get();
    expect(drawings.docs.length, 1);
    expect(drawings.docs.first['title'], 'Persistent Entry');
  });
}
