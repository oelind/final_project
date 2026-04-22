import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:final_project/app.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_database_mocks/firebase_database_mocks.dart';
import 'package:firebase_database/firebase_database.dart';

void main() {
  late MockFirebaseAuth mockAuth;
  late FirebaseDatabase mockDatabase;

  setUp(() {
    mockDatabase = MockFirebaseDatabase.instance;
  });

  testWidgets('Junior QA Test: Login with correct info works', (WidgetTester tester) async {
    final user = MockUser(uid: 'test_user', email: 'test@example.com');
    mockAuth = MockFirebaseAuth(mockUser: user);

    await tester.pumpWidget(DrawingLogApp(
      auth: mockAuth,
      database: mockDatabase,
    ));

    await tester.enterText(find.widgetWithText(TextField, 'Email'), 'test@example.com');
    await tester.enterText(find.widgetWithText(TextField, 'Password'), 'password123');
    await tester.tap(find.text('Login'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Check if we reached the home screen
    expect(find.text('Drawing Log'), findsOneWidget);
  });

  testWidgets('Junior QA Test: Empty email or password shows warning', (WidgetTester tester) async {
    mockAuth = MockFirebaseAuth();

    await tester.pumpWidget(DrawingLogApp(
      auth: mockAuth,
      database: mockDatabase,
    ));

    // Leave fields empty and tap login
    await tester.tap(find.text('Login'));
    await tester.pump();

    // Check for the warning message
    expect(find.text('Please enter both your email and your password.'), findsOneWidget);
  });

  testWidgets('Junior QA Test: Login fails with unknown user', (WidgetTester tester) async {
    mockAuth = MockFirebaseAuth(); // No user added to it

    await tester.pumpWidget(DrawingLogApp(
      auth: mockAuth,
      database: mockDatabase,
    ));

    await tester.enterText(find.widgetWithText(TextField, 'Email'), 'unknown@example.com');
    await tester.enterText(find.widgetWithText(TextField, 'Password'), 'pass');
    await tester.tap(find.text('Login'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Now we expect a login failure message
    expect(find.text('Login failed. Please check your credentials.'), findsOneWidget);
  });
}
