import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_auto_suggestion_box/super_auto_suggestion_box.dart';

void main() {
  testWidgets('forwards ERP input configuration and participates in Form.save', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    String? savedValue;
    String? submittedValue;
    var tapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: AutoSuggestionsBox<String>(
              items: const [
                AutoSuggestion(value: '1234', label: '1234'),
              ],
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.end,
              textInputAction: TextInputAction.done,
              keyboardAppearance: Brightness.dark,
              autocorrect: false,
              enableSuggestions: false,
              enableIMEPersonalizedLearning: false,
              maxLength: 8,
              onTap: () => tapCount++,
              onFieldSubmitted: (value) => submittedValue = value,
              onSave: (value) => savedValue = value,
            ),
          ),
        ),
      ),
    );

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.keyboardType, TextInputType.number);
    expect(textField.textDirection, TextDirection.ltr);
    expect(textField.textAlign, TextAlign.end);
    expect(textField.textInputAction, TextInputAction.done);
    expect(textField.maxLength, 8);

    await tester.tap(find.byType(TextField));
    await tester.enterText(find.byType(TextField), '1234');
    expect(tapCount, 1);

    formKey.currentState!.save();
    expect(savedValue, '1234');

    tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(submittedValue, '1234');
  });

  testWidgets('shows highlighted prefix remainder as a visual shadow hint', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    String? savedValue;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: AutoSuggestionsBox<String>(
              items: const [
                AutoSuggestion(value: 'INV-1042', label: 'INV-1042'),
                AutoSuggestion(value: 'INV-1100', label: 'INV-1100'),
              ],
              textDirection: TextDirection.ltr,
              onSave: (value) => savedValue = value,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'INV-1');
    await tester.pump();

    final editable = tester.widget<EditableText>(find.byType(EditableText));
    final context = tester.element(find.byType(EditableText));
    final span = editable.controller.buildTextSpan(
      context: context,
      style: editable.style,
      withComposing: false,
    );

    expect(editable.controller.text, 'INV-1');
    expect(span.toPlainText(), 'INV-1042');
    expect((span.children!.last as TextSpan).text, '042');

    formKey.currentState!.save();
    expect(savedValue, 'INV-1');

    await tester.enterText(find.byType(TextField), 'INV-1042');
    await tester.pump();
    final exactSpan = editable.controller.buildTextSpan(
      context: context,
      style: editable.style,
      withComposing: false,
    );
    expect(exactSpan.toPlainText(), 'INV-1042');
  });

  testWidgets('keeps an external text controller synchronized with shadow text', (
    tester,
  ) async {
    final textController = TextEditingController();
    final controller = AutoSuggestionsBoxController<String>(
      source: SuggestionSources.list<String>(const [
        AutoSuggestion(value: 'ACC-1000', label: 'ACC-1000'),
      ]),
      textController: textController,
    );
    addTearDown(() {
      controller.dispose();
      textController.dispose();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AutoSuggestionsBox<String>(controller: controller),
        ),
      ),
    );

    await tester.tap(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'ACC-1');
    await tester.pump();

    final editable = tester.widget<EditableText>(find.byType(EditableText));
    final span = editable.controller.buildTextSpan(
      context: tester.element(find.byType(EditableText)),
      style: editable.style,
      withComposing: false,
    );

    expect(textController.text, 'ACC-1');
    expect(span.toPlainText(), 'ACC-1000');
  });

  testWidgets('can disable the visual shadow hint', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AutoSuggestionsBox<String>(
            items: [
              AutoSuggestion(value: 'INV-1042', label: 'INV-1042'),
            ],
            showShadowHint: false,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'INV-1');
    await tester.pump();

    final editable = tester.widget<EditableText>(find.byType(EditableText));
    final span = editable.controller.buildTextSpan(
      context: tester.element(find.byType(EditableText)),
      style: editable.style,
      withComposing: false,
    );
    expect(span.toPlainText(), 'INV-1');
  });
}
