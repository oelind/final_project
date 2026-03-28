import 'package:flutter_test/flutter_test.dart';
import 'package:final_project/app.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  testWidgets('Login screen smoke test', (WidgetTester tester) async {
    final mockAuth = MockFirebaseAuth();
    final fakeFirestore = FakeFirebaseFirestore();
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(DrawingLogApp(
      auth: mockAuth,
      firestore: fakeFirestore,
    ));

    // Verify that the login screen is shown.
    expect(find.text('DrawingLog Login'), findsOneWidget);
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
