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
}
