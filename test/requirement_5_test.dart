import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:final_project/home_screen.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_database_mocks/firebase_database_mocks.dart';
import 'package:final_project/widgets/drawing_log_dialog.dart';

void main() {
  testWidgets('Requirement 5: Home screen displays "Record first entry" when empty', (WidgetTester tester) async {
    final user = MockUser(uid: 'test_uid');
    final mockAuth = MockFirebaseAuth(mockUser: user, signedIn: true);
    final mockDatabase = MockFirebaseDatabase.instance;

    await tester.pumpWidget(MaterialApp(home: HomeScreen(auth: mockAuth, database: mockDatabase)));
    await tester.pumpAndSettle();

    expect(find.text('No drawings logged yet.'), findsOneWidget);
    expect(find.text('Record your first entry'), findsOneWidget);

    await tester.tap(find.text('Record your first entry'));
    await tester.pumpAndSettle();

    expect(find.byType(DrawingLogDialog), findsOneWidget);
    expect(find.text('Log Your Drawing'), findsOneWidget);
  });

  testWidgets('Requirement 5: Log dialog fields and save button', (WidgetTester tester) async {
    final user = MockUser(uid: 'test_uid');
    final mockAuth = MockFirebaseAuth(mockUser: user, signedIn: true);
    final mockDatabase = MockFirebaseDatabase.instance;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: DrawingLogDialog(auth: mockAuth, database: mockDatabase),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextFormField, 'Title (Optional)'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Time Spent (Minutes)'), findsOneWidget);
    expect(find.text('Effort Level'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
  });
}
