import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:final_project/app.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_database_mocks/firebase_database_mocks.dart';
import 'package:firebase_database/firebase_database.dart';

void main() {
  testWidgets('Verify drawing log entries persist after app "restart"', (WidgetTester tester) async {
    // 1. Setup persistent mock instances
    final FirebaseDatabase mockDatabase = MockFirebaseDatabase.instance;
    final user = MockUser(
      isAnonymous: false,
      uid: 'persistent_user_id',
      email: 'persistent@example.com',
    );
    final mockAuth = MockFirebaseAuth(mockUser: user, signedIn: true);

    // 2. "First Run": Add a drawing log
    await tester.pumpWidget(DrawingLogApp(
      auth: mockAuth, 
      database: mockDatabase,
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
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Persistent Entry'), findsOneWidget);

    // 3. "Shutdown": Clear the widget tree
    await tester.pumpWidget(Container());
    await tester.pumpAndSettle();

    // 4. "Restart": Rebuild the app with the same mockDatabase instance
    // Note: We use the same mockDatabase but a "new" app instance
    await tester.pumpWidget(DrawingLogApp(
      auth: mockAuth, 
      database: mockDatabase,
      initialPrompts: ['Test Prompt'],
    ));
    await tester.pumpAndSettle();

    // 5. Verify data is still there
    // The LoginPage should auto-navigate because user is still signed in
    await tester.pumpAndSettle();
    
    // Extra pump for StreamBuilder
    await tester.pump(const Duration(milliseconds: 500));
    
    expect(find.text('Persistent Entry'), findsOneWidget);
    
    // 6. Double-check directly in Database
    final snapshot = await mockDatabase.ref('drawings').get();
    final allDrawings = snapshot.value as Map? ?? {};
    final drawings = Map.from(allDrawings)..removeWhere((k, v) => v['userId'] != 'persistent_user_id');
    expect(drawings.length, 1);
    expect(drawings.values.first['title'], 'Persistent Entry');
  });
}
