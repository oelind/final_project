import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:final_project/app.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_database_mocks/firebase_database_mocks.dart';
import 'package:firebase_database/firebase_database.dart';

void main() {
  testWidgets('Successful login navigates to home screen', (WidgetTester tester) async {
    final user = MockUser(
      isAnonymous: false,
      uid: 'test_uid',
      email: 'user1@example.com',
    );
    final mockAuth = MockFirebaseAuth(mockUser: user);
    final FirebaseDatabase mockDatabase = MockFirebaseDatabase();
    
    await tester.pumpWidget(DrawingLogApp(
      auth: mockAuth,
      database: mockDatabase,
    ));

    await tester.enterText(find.widgetWithText(TextField, 'Email'), 'user1@example.com');
    await tester.enterText(find.widgetWithText(TextField, 'Password'), 'password123');

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('Drawing Log'), findsOneWidget);
  });
}
