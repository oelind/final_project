import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:final_project/widgets/prompt_generator_widget.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_database_mocks/firebase_database_mocks.dart';
import 'package:firebase_database/firebase_database.dart';

void main() {
  testWidgets('PromptGeneratorWidget should load and generate random prompts', (WidgetTester tester) async {
    final auth = MockFirebaseAuth();
    final FirebaseDatabase database = MockFirebaseDatabase();

    // Build the widget
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: PromptGeneratorWidget(
          initialPrompts: const ['Apple', 'Banana', 'Cat'],
          auth: auth,
          database: database,
        ),
      ),
    ));

    // Initially shows loading or the initial text
    // Note: rootBundle.loadString might not work perfectly in simple widget tests 
    // without proper asset mocking, but let's see.
    
    await tester.pumpAndSettle();

    // Verify initial state
    expect(find.text('Drawing Prompt Generator'), findsOneWidget);
    expect(find.text('Tap the button to generate a prompt!'), findsOneWidget);
    expect(find.text('Generate Random Prompt'), findsOneWidget);

    // Tap the button
    await tester.tap(find.text('Generate Random Prompt'));
    await tester.pump();

    // The text should change from the initial one
    expect(find.text('Tap the button to generate a prompt!'), findsNothing);
    
    // There should be some text in the prompt area (it will be random so we just check it's there)
    // We can check for any text that is NOT the initial text and NOT the button/header text.
    final textWidgets = tester.widgetList<Text>(find.byType(Text));
    bool foundRandomPrompt = false;
    for (var widget in textWidgets) {
      if (widget.data != 'Drawing Prompt Generator' && 
          widget.data != 'Generate Random Prompt' &&
          widget.data != 'Tap the button to generate a prompt!') {
        foundRandomPrompt = true;
        break;
      }
    }
    expect(foundRandomPrompt, true);
  });

  testWidgets('Regression Test: Generate multiple prompts consecutively', (WidgetTester tester) async {
    final auth = MockFirebaseAuth();
    final FirebaseDatabase database = MockFirebaseDatabase();

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: PromptGeneratorWidget(
          initialPrompts: const ['P1', 'P2', 'P3'],
          auth: auth,
          database: database,
        ),
      ),
    ));
    await tester.pumpAndSettle();

    for (int i = 0; i < 5; i++) {
      await tester.tap(find.text('Generate Random Prompt'));
      await tester.pump();
      // No crashes
    }
    expect(find.text('Drawing Prompt Generator'), findsOneWidget);
  });
}
