# super_auto_suggestion_box

[![style: flutter_lints](https://img.shields.io/badge/style-flutter__lints-blue)](https://pub.dev/packages/flutter_lints)

`super_auto_suggestion_box` provides the GeniusLink `SuperAutoSuggestionsBox<T>`:
a themed typeahead / combobox with local and remote sources, fuzzy matching,
single- and multi-select, free-text entry, progressive remote fallback,
server-side paging, recents, inline create, shadow-hint completion, record
binding, read-only/fixable states, advanced search, validation, and bare
embedding.

Version `1.1.0` uses raw `T` values as the public data model. Callers pass raw
items and provide a `suggestionBuilder` only to describe how each item should be
rendered and searched.

Every `SuperAutoSuggestionsBox<T>` requires a
`SuperAutoSuggestionsSource<T>`. Use `SuggestionSources.list<T>(values)` for a
local collection. Initial multi-select values belong to
`SuperAutoSuggestionsController.initialSelected`; query, recents, and
multi-select configuration belong to the widget.

```dart
SuperAutoSuggestionsItem<T> suggestionBuilder(
  List<T> items,
  int index,
  T element,
)
```

`SuperAutoSuggestionsItem<T>` remains public because builders return it, but
callers no longer wrap every collection item, fetch result, selected item,
recent item, or created item in `SuperAutoSuggestionsItem<T>`.

## Setup

```yaml
dependencies:
  super_auto_suggestion_box: ^1.1.0
```

```dart
import 'package:super_auto_suggestion_box/super_auto_suggestion_box.dart';

final typography = SuperTextTheme();

MaterialApp(
  theme: SuperMaterialThemeData.light(
    textTheme: typography,
    primaryTextTheme: typography,
  ),
  darkTheme: SuperMaterialThemeData.dark(
    textTheme: typography,
    primaryTextTheme: typography,
  ),
);
```

## Basic Usage

```dart
final units = ['each', 'box', 'carton'];

SuperAutoSuggestionsItem<String> unitSuggestion(
  List<String> items,
  int index,
  String unit,
) => SuperAutoSuggestionsItem<String>(
  value: unit,
  titleText: unit,
);

final box = SuperAutoSuggestionsController<String>(
  allowFreeText: true,
);

SuperAutoSuggestionsBox<String>(
  controller: box,
  source: SuggestionSources.list<String>(units),
  suggestionBuilder: unitSuggestion,
  hintText: 'Type or pick...',
  onSelected: (unit) {
    // unit is the raw String.
  },
  onSubmitted: (raw) {
    // Free-text Enter.
  },
);
```

You can omit the controller, but the source remains required:

```dart
SuperAutoSuggestionsBox<String>(
  source: SuggestionSources.list<String>(units),
  suggestionBuilder: unitSuggestion,
  onSelected: (unit) {},
);
```

## Rich Rows

Keep domain data raw and derive row metadata in the builder:

```dart
final accounts = ['1010', '1020', '4000'];

SuperAutoSuggestionsItem<String> accountSuggestion(
  List<String> items,
  int index,
  String code,
) => SuperAutoSuggestionsItem<String>(
  value: code,
  titleText: switch (code) {
    '1010' => 'Cash on Hand',
    '1020' => 'Bank - Operating',
    '4000' => 'Sales Revenue',
    _ => code,
  },
  descriptionText: 'Account $code',
  trailingText: code == '1020' ? '285,120.50' : null,
  group: code.startsWith('1') ? 'Assets' : 'Income',
  iconData: Icons.account_balance_outlined,
  keywords: [code],
);
```

Custom rows receive both the raw item and the built suggestion:

```dart
SuperAutoSuggestionsBox<String>(
  source: SuggestionSources.list<String>(accounts),
  suggestionBuilder: accountSuggestion,
  itemBuilder: (context, code, suggestion, highlighted) {
    return Text('${suggestion.displayText} ($code)');
  },
);
```

For fully custom suggestion content, use the widget-based constructor:

```dart
SuperAutoSuggestionsItem<String>.build(
  value: '1020',
  title: const Text('Bank - Operating'),
  description: const Text('1020 - Current Assets'),
  trailing: const Chip(label: Text('Active')),
  icon: const Icon(Icons.account_balance_outlined),
);
```

Widget-built items use `value.toString()` as their searchable and committed
text. Supply `keywords` to add other search terms.

## Suggestion Sources

All built-in sources accept raw values and source-specific matching or fetch
configuration only. Pass `suggestionBuilder` to `SuperAutoSuggestionsBox`; it owns
the conversion to `SuperAutoSuggestionsItem<T>` for both widget-created and external
controllers.

```dart
final staticSource = SuggestionSources.list<String>(accounts);

final fuzzySource = SuggestionSources.fuzzy<String>(accounts);

final asyncSource = SuggestionSources.async<String>(
  (query) => api.searchAccounts(query), // Future<List<String>>
  initialItems: accounts.take(5).toList(),
);

final hybridSource = SuggestionSources.hybrid<String>(
  initialItems: accounts,
  fetch: (query) => api.searchAccounts(query), // Future<List<String>>
  remoteThreshold: 1,
  remoteMinChars: 2,
);

final remoteFallbackSource = SuggestionSources.remoteFallback<String>(
  initialItems: accounts,
  fetch: (query) => api.searchAccounts(query), // Future<List<String>>
  remoteThreshold: 5,
  remoteMinChars: 1,
);

final pagedSource = SuggestionSources.paged<String>(
  (query, page) async {
    final response = await api.searchAccountsPage(query, page);
    return SuperSuggestionsPage<String>(
      items: response.codes,
      hasMore: response.hasMore,
    );
  },
  resolveFrom: accounts,
);
```

`SuggestionSources.strings(values)` is still available for the simple
label-equals-value case. The source itself does not take a builder; the widget
owns the `suggestionBuilder`.

## Controller API

Controller selections, result lists, recents, and callbacks use raw values:

```dart
final controller = SuperAutoSuggestionsController<String>(
  initialValue: '1020',
  initialSelected: const ['1010'],
);

controller.selected;          // String?
controller.results;           // List<String>
controller.selectedItems;     // List<String>
controller.selectedValues;    // List<String>, compatibility alias
controller.recents;           // List<String>

controller.select('1010');
controller.toggleSelected('4000');
controller.setSelectedItems(['1010', '4000']);
controller.setRecents(['1020']);
controller.selectByValue('4000');
```

When using an external controller, provide the source and builder on the
widget. The controller owns interaction state, not suggestion data or row
presentation:

```dart
SuperAutoSuggestionsBox<String>(
  controller: controller,
  source: staticSource,
  suggestionBuilder: accountSuggestion,
  showRecents: true,
  initialRecents: const ['4000'],
  onRecentsChanged: (recentCodes) {},
);
```

After the controller is attached to an `SuperAutoSuggestionsBox`, UI metadata is
available through the render-facing accessors:

```dart
controller.suggestions;            // List<SuperAutoSuggestionsItem<String>>
controller.suggestionAt(0);        // SuperAutoSuggestionsItem<String>
controller.highlightedSuggestion;  // SuperAutoSuggestionsItem<String>?
controller.selectedSuggestion;     // SuperAutoSuggestionsItem<String>?
```

## Widget Callbacks

```dart
SuperAutoSuggestionsBox<String>(
  source: SuggestionSources.list<String>(accounts),
  suggestionBuilder: accountSuggestion,
  multiSelect: true,
  onSelected: (code) {},
  onSelectionChanged: (codes) {},
);
```

Inline create returns a raw value:

```dart
SuperAutoSuggestionsBox<String>(
  source: SuggestionSources.list<String>(vendors),
  suggestionBuilder: vendorSuggestion,
  onCreate: (query) async {
    final vendor = await api.createVendor(query);
    return vendor.id; // raw String
  },
  onSelected: (vendorId) {},
);
```

## ERP Input And Validation

`SuperAutoSuggestionsBox` forwards ERP-style text input controls and participates in
`FormState.save()` through `onSave`.

```dart
Form(
  key: formKey,
  child: SuperAutoSuggestionsBox<String>(
    source: SuggestionSources.list<String>(documentReferences),
    suggestionBuilder: documentSuggestion,
    decoration: const InputDecoration(
      labelText: 'Document Reference',
      helperText: 'Pick or type a document reference',
    ),
    keyboardType: TextInputType.text,
    inputFormatters: [
      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9-]')),
      LengthLimitingTextInputFormatter(16),
    ],
    textDirection: TextDirection.ltr,
    textInputAction: TextInputAction.done,
    showShadowHint: true,
    completeShadowHintOnTab: true,
    required: true,
    validator: (value) {
      if (value.trim().isEmpty) return null;
      final labels = [
        for (var i = 0; i < documentReferences.length; i++)
          documentSuggestion(documentReferences, i, documentReferences[i]).titleText,
      ];
      final ok = labels.contains(value);
      return ok ? null : 'Pick a document from the list';
    },
    onFieldSubmitted: (value) {},
    onSave: (value) {},
  ),
);
```

Validation errors surface through the suffix error badge tooltip, matching the
GeniusLink form-field convention.

## States And Embedding

- `disabled`: dims and blocks interaction.
- `readOnly`: blocks interaction but keeps full contrast for posted/review
  states.
- `allowFixed`: shows a lock/unlock action backed by `controller.isFixed`.
- `advancedSearch`: opens a larger search surface with `Ctrl`/`Cmd` + `F`.
- `bare`: removes outer chrome for table cells and compact host surfaces.
- `restoreOnBlur`: restores the last committed raw value when the user leaves
  without picking.

## Migration

See [`migration_1.0.0_to_1.1.0.md`](migration_1.0.0_to_1.1.0.md) for the
controller rename and widget-owned source migration. For the earlier raw-value
API migration, see
[`migration_0.14.0_to_1.0.0.md`](migration_0.14.0_to_1.0.0.md).
