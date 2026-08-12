import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_auto_suggestion_box/super_auto_suggestion_box.dart';

Widget _themedApp(Widget home) {
  final typography = SuperTextTheme();
  return MaterialApp(
    theme: SuperMaterialThemeData.light(
      textTheme: typography,
      primaryTextTheme: typography,
    ),
    home: home,
  );
}

AutoSuggestion<String> _suggestion(
  List<String> items,
  int index,
  String element,
) => AutoSuggestion<String>(
  value: element,
  label: element == 'A' ? 'Alpha' : element,
);

void main() {
  testWidgets('allowFixed toggles a compact label action and protects text', (
    tester,
  ) async {
    final focusNode = FocusNode();
    final formFieldKey = GlobalKey<FormFieldState<String>>();
    final controller = AutoSuggestionsBoxController<String>(
      source: SuggestionSources.list(const ['A']),
      focusNode: focusNode,
      formFieldKey: formFieldKey,
    );
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      _themedApp(
        Scaffold(
          body: AutoSuggestionsBox<String>(
            controller: controller,
            suggestionBuilder: _suggestion,
            decoration: const InputDecoration(
              labelText: 'Account',
              helperText: 'Choose an account',
              prefixIcon: Icon(Icons.account_balance_outlined),
            ),
            allowFixed: true,
          ),
        ),
      ),
    );

    // ignore: invalid_use_of_protected_member
    expect(focusNode.hasListeners, isTrue);
    expect(formFieldKey.currentState, isNotNull);
    expect(find.text('ACCOUNT'), findsOneWidget);
    expect(find.text('Choose an account'), findsOneWidget);
    expect(find.byIcon(Icons.account_balance_outlined), findsOneWidget);
    expect(find.byIcon(Icons.lock_open_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.lock_open_rounded));
    await tester.pump();
    expect(controller.isFixed.value, isTrue);
    expect(find.byIcon(Icons.lock_rounded), findsOneWidget);

    controller.setText('blocked');
    controller.clear();
    expect(controller.text.text, isEmpty);

    await tester.tap(find.byIcon(Icons.lock_rounded));
    controller.setText('editable');
    expect(controller.text.text, 'editable');
  });

  testWidgets(
    'forwards ERP input configuration and participates in Form.save',
    (tester) async {
      final formKey = GlobalKey<FormState>();
      String? savedValue;
      String? submittedValue;
      var tapCount = 0;

      await tester.pumpWidget(
        _themedApp(
          Scaffold(
            body: Form(
              key: formKey,
              child: AutoSuggestionsBox<String>(
                items: const ['1234'],
                suggestionBuilder: _suggestion,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(submittedValue, '1234');
    },
  );

  testWidgets('shows highlighted prefix remainder as a visual shadow hint', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    String? savedValue;

    await tester.pumpWidget(
      _themedApp(
        Scaffold(
          body: Form(
            key: formKey,
            child: AutoSuggestionsBox<String>(
              items: const ['INV-1042', 'INV-1100'],
              suggestionBuilder: _suggestion,
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

  testWidgets(
    'keeps an external text controller synchronized with shadow text',
    (tester) async {
      final textController = TextEditingController();
      final controller = AutoSuggestionsBoxController<String>(
        source: SuggestionSources.list<String>(const ['ACC-1000']),
        textController: textController,
      );
      addTearDown(() {
        controller.dispose();
        textController.dispose();
      });

      await tester.pumpWidget(
        _themedApp(
          Scaffold(
            body: AutoSuggestionsBox<String>(
              controller: controller,
              suggestionBuilder: _suggestion,
            ),
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
    },
  );

  testWidgets('can disable the visual shadow hint', (tester) async {
    await tester.pumpWidget(
      _themedApp(
        const Scaffold(
          body: AutoSuggestionsBox<String>(
            items: ['INV-1042'],
            suggestionBuilder: _suggestion,
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

  testWidgets('Tab accepts the visible shadow hint before focus traversal', (
    tester,
  ) async {
    var tabNextCount = 0;
    var selectedCount = 0;

    await tester.pumpWidget(
      _themedApp(
        Scaffold(
          body: AutoSuggestionsBox<String>(
            items: const ['INV-1042', 'INV-1100'],
            suggestionBuilder: _suggestion,
            textDirection: TextDirection.ltr,
            onTabNext: () => tabNextCount++,
            onSelected: (_) => selectedCount++,
          ),
        ),
      ),
    );

    final suggestionField = find.byType(TextField);
    await tester.tap(suggestionField);
    await tester.enterText(suggestionField, 'INV-1');
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();

    final editable = tester.widget<EditableText>(find.byType(EditableText));
    expect(editable.controller.text, 'INV-1042');
    expect(tabNextCount, 0);
    expect(selectedCount, 0);

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(tabNextCount, 1);
  });

  testWidgets('can opt out of accepting shadow hints with Tab', (tester) async {
    await tester.pumpWidget(
      _themedApp(
        const Scaffold(
          body: AutoSuggestionsBox<String>(
            items: ['ACC-1000'],
            suggestionBuilder: _suggestion,
            completeShadowHintOnTab: false,
          ),
        ),
      ),
    );

    final field = find.byType(TextField);
    await tester.tap(field);
    await tester.enterText(field, 'ACC-1');
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();

    final editable = tester.widget<EditableText>(find.byType(EditableText));
    expect(editable.controller.text, 'ACC-1');
  });

  test('controller exposes raw initial, recents, and bound selections', () {
    final changedRecents = <List<String>>[];
    final controller = AutoSuggestionsBoxController<String>(
      source: SuggestionSources.list<String>(const ['A', 'B', 'C']),
      initialValue: 'A',
      showRecents: true,
      onRecentsChanged: (items) => changedRecents.add(items),
    );
    addTearDown(controller.dispose);

    expect(controller.selected, 'A');
    expect(controller.selectedSuggestion?.label, 'A');
    expect(controller.text.text, 'A');

    expect(controller.selectByValue('B'), 'B');
    expect(controller.selected, 'B');
    expect(controller.recents, ['B']);
    expect(changedRecents.single, ['B']);

    controller.setRecents(const ['C']);
    expect(controller.recents, ['C']);
  });

  test('controller multi-select collections use raw values', () {
    final controller = AutoSuggestionsBoxController<String>(
      source: SuggestionSources.list<String>(const ['A', 'B']),
      multiSelect: true,
      initialSelected: const ['A'],
    );
    addTearDown(controller.dispose);

    expect(controller.selectedItems, ['A']);
    expect(controller.selectedValues, ['A']);

    expect(controller.toggleSelected('B'), isTrue);
    expect(controller.selectedItems, ['A', 'B']);

    controller.removeSelectedValue('A');
    expect(controller.selectedItems, ['B']);

    controller.setSelectedItems(const ['A']);
    expect(controller.selectedItems, ['A']);
  });

  testWidgets('onSelected receives the picked raw value', (tester) async {
    String? selected;

    await tester.pumpWidget(
      _themedApp(
        Scaffold(
          body: AutoSuggestionsBox<String>(
            items: const ['A', 'B'],
            suggestionBuilder: _suggestion,
            onSelected: (value) => selected = value,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(TextField));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(selected, 'A');
  });

  testWidgets('onCreate returns and commits a raw value', (tester) async {
    String? selected;
    String? createQuery;

    await tester.pumpWidget(
      _themedApp(
        Scaffold(
          body: AutoSuggestionsBox<String>(
            items: const [],
            suggestionBuilder: _suggestion,
            onCreate: (query) async {
              createQuery = query;
              return 'created:$query';
            },
            onSelected: (value) => selected = value,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'North Tower');
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    await tester.pump();

    expect(createQuery, 'North Tower');
    expect(selected, 'created:North Tower');
  });
}
