import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:final_project/widgets/complex_prompt_generator_widget.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_database_mocks/firebase_database_mocks.dart';

void main() {
  testWidgets('Requirement 12: Complex prompt generator with independent buttons', (WidgetTester tester) async {
    final user = MockUser(uid: 'test_uid');
    final auth = MockFirebaseAuth(mockUser: user, signedIn: true);
    final database = MockFirebaseDatabase();

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ComplexPromptGeneratorWidget(
          auth: auth,
          database: database,
        ),
      ),
    ));
    await tester.pumpAndSettle();

    // Verify initial state
    expect(find.text('Mad Libs Drawing Prompt'), findsOneWidget);
    
    // Check RichText for placeholders
    final richTextFinder = find.byWidgetPredicate((widget) => 
      widget is RichText && widget.text.toPlainText().startsWith('Draw a ')
    );
    expect(richTextFinder, findsOneWidget);
    
    final RichText richText = tester.widget(richTextFinder);
    final String content = richText.text.toPlainText();
    expect(content.contains('...'), true);

    // Randomize Sub-topic
    await tester.tap(find.text('Sub-topic'));
    await tester.pumpAndSettle();
    
    // Randomize Noun
    await tester.tap(find.text('Noun'));
    await tester.pumpAndSettle();

    // Randomize Style
    await tester.tap(find.text('Style'));
    await tester.pumpAndSettle();

    // Randomize All
    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();

    // Verify no '...' remains
    final RichText finalRichText = tester.widget(richTextFinder);
    expect(finalRichText.text.toPlainText().contains('...'), false);
  });

  testWidgets('Regression Test: Complex prompt state persists in database', (WidgetTester tester) async {
    final user = MockUser(uid: 'complex_user');
    final auth = MockFirebaseAuth(mockUser: user, signedIn: true);
    final database = MockFirebaseDatabase();

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ComplexPromptGeneratorWidget(
          auth: auth,
          database: database,
        ),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();

    // Verify it saved to database
    final snapshot = await database.ref('users/complex_user/state/complexPrompt').get();
    expect(snapshot.exists, true);
    final data = snapshot.value as Map;
    expect(data['subTopic'], isNotNull);
    expect(data['noun'], isNotNull);
    expect(data['style'], isNotNull);
  });
}
