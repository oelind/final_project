import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:final_project/main.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  testWidgets('Successful login navigates to home screen', (WidgetTester tester) async {
    final user = MockUser(
      isAnonymous: false,
      uid: 'test_uid',
      email: 'user1@example.com',
    );
    final mockAuth = MockFirebaseAuth(mockUser: user);
    final fakeFirestore = FakeFirebaseFirestore();
    
    await tester.pumpWidget(DrawingLogApp(
      auth: mockAuth,
      firestore: fakeFirestore,
    ));

    await tester.enterText(find.widgetWithText(TextField, 'Email'), 'user1@example.com');
    await tester.enterText(find.widgetWithText(TextField, 'Password'), 'password123');

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('Drawing Log'), findsOneWidget);
  });
}
