import 'package:flutter_test/flutter_test.dart';
import 'package:final_project/app.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_database_mocks/firebase_database_mocks.dart';
import 'package:firebase_database/firebase_database.dart';

void main() {
  testWidgets('Login screen smoke test', (WidgetTester tester) async {
    final mockAuth = MockFirebaseAuth();
    final mockDatabase = MockFirebaseDatabase.instance;
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(DrawingLogApp(
      auth: mockAuth,
      database: mockDatabase,
    ));

    // Verify that the login screen is shown.
    expect(find.text('DrawingLog Login'), findsOneWidget);
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
