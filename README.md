# super_auto_suggestion_box

[![style: flutter_lints](https://img.shields.io/badge/style-flutter__lints-blue)](https://pub.dev/packages/flutter_lints)

`super_auto_suggestion_box` provides the GeniusLink `SuperAutoSuggestionsBox<T>`:
a themed typeahead / combobox with local and remote sources, fuzzy matching,
single- and multi-select, free-text entry, progressive remote fallback,
server-side paging, recents, inline create, shadow-hint completion, record
binding, read-only/fixable states, advanced search, validation, and bare
embedding.

Version `1.2.0` keeps raw `T` values as the public data model and integrates
`SuperAutoSuggestionsBox<T>` with Flutter forms through `FormField<T>`. The
validator receives the selected raw `T?`, and `onSelectionChanged` is the
selection callback for both select and de-select operations.

Every `SuperAutoSuggestionsBox<T>` requires a
`SuperAutoSuggestionsSource<T>`. Use `SuperAutoSuggestionSources.list<T>(values)` for a
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
  super_auto_suggestion_box: ^1.2.0
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
  localizationsDelegates: const [
        // ...
        SuperAutoSuggestionsTranslation.delegate,
      ],
  supportedLocales:
      SuperAutoSuggestionsTranslation.delegate.supportedLocales,
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
  source: SuperAutoSuggestionSources.list<String>(units),
  suggestionBuilder: unitSuggestion,
  hintText: 'Type or pick...',
  onSelectionChanged: (selected) {
    final unit = selected.isEmpty ? null : selected.last;
    // unit is the selected raw String?, or null after de-selection.
  },
);
```

You can omit the controller, but the source remains required:

```dart
SuperAutoSuggestionsBox<String>(
  source: SuperAutoSuggestionSources.list<String>(units),
  suggestionBuilder: unitSuggestion,
  onSelectionChanged: (selected) {},
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
  source: SuperAutoSuggestionSources.list<String>(accounts),
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
final staticSource = SuperAutoSuggestionSources.list<String>(accounts);

final fuzzySource = SuperAutoSuggestionSources.fuzzy<String>(accounts);

final asyncSource = SuperAutoSuggestionSources.async<String>(
  (query) => api.searchAccounts(query), // Future<List<String>>
  initialItems: accounts.take(5).toList(),
);

final hybridSource = SuperAutoSuggestionSources.hybrid<String>(
  initialItems: accounts,
  fetch: (query) => api.searchAccounts(query), // Future<List<String>>
  remoteThreshold: 1,
  remoteMinChars: 2,
);

final remoteFallbackSource = SuperAutoSuggestionSources.remoteFallback<String>(
  initialItems: accounts,
  fetch: (query) => api.searchAccounts(query), // Future<List<String>>
  remoteThreshold: 5,
  remoteMinChars: 1,
);

final pagedSource = SuperAutoSuggestionSources.paged<String>(
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

`SuperAutoSuggestionSources.strings(values)` is still available for the simple
label-equals-value case. The source itself does not take a builder; the widget
owns the `suggestionBuilder`.

### Concrete Source Classes

The factory methods above return these public implementations:

| Factory | Concrete source |
| --- | --- |
| `list` / `strings` / `fuzzy` | `SuperAutoListSuggestionsSource<T>` |
| `async` | `SuperAutoAsyncSuggestionsSource<T>` |
| `hybrid` | `SuperAutoHybridSuggestionsSource<T>` |
| `remoteFallback` | `SuperAutoRemoteFallbackSuggestionsSource<T>` |
| `paged` | `SuperAutoPagedSuggestionsSource<T>` |

Prefer `SuperAutoSuggestionSources` for normal construction. Instantiate a
concrete source directly only when its public source-specific API is needed.
The pre-1.2.0 concrete class names are no longer canonical.

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

## Selection Callback

`onSelectionChanged` fires after every selection mutation. Single-select emits
`[item]` on selection and `[]` on de-selection; multi-select emits the complete
selected list.

```dart
SuperAutoSuggestionsBox<String>(
  source: SuperAutoSuggestionSources.list<String>(accounts),
  suggestionBuilder: accountSuggestion,
  multiSelect: true,
  onSelectionChanged: (codes) {},
);
```

Inline create returns a raw value:

```dart
SuperAutoSuggestionsBox<String>(
  source: SuperAutoSuggestionSources.list<String>(vendors),
  suggestionBuilder: vendorSuggestion,
  onCreate: (query) async {
    final vendor = await api.createVendor(query);
    return vendor.id; // raw String
  },
  onSelectionChanged: (vendorIds) {},
);
```

## ERP Input And Validation

`SuperAutoSuggestionsBox<T>` participates in an enclosing `Form` through
`FormField<T>`. Its validator receives the selected raw `T?`, not the query
text. Keep a controller when form submission needs to read the selected value.

```dart
final documentController = SuperAutoSuggestionsController<String>();

Form(
  key: formKey,
  child: SuperAutoSuggestionsBox<String>(
    controller: documentController,
    source: SuperAutoSuggestionSources.list<String>(documentReferences),
    suggestionBuilder: documentSuggestion,
    decoration: const InputDecoration(
      labelText: 'Document Reference',
      helperText: 'Pick a document reference',
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
      if (value == null) return null; // `required` handles the empty selection.
      return documentReferences.contains(value)
          ? null
          : 'Pick a document from the list';
    },
    onSelectionChanged: (selected) {},
  ),
);

if (formKey.currentState!.validate()) {
  final savedDocumentReference = documentController.selected;
}
```

Validation errors surface through the suffix error badge tooltip, matching the
GeniusLink form-field convention. For direct form-field access, controller
`formFieldKey` is now `GlobalKey<FormFieldState<T>>?`.

For keyboard traversal, a single-select field with
`textInputAction: TextInputAction.next` moves focus to the next focusable field
immediately after an item is selected. Multi-select fields keep focus in the
current suggestions field.

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

See [`migration_1.1.0_to_1.2.0.md`](migration_1.1.0_to_1.2.0.md) for the generic
validator, `FormField<T>` integration, removed callbacks, source-name
migrations, localization, `TextInputAction.next`, and
`onSelectionChanged` behavior. For earlier migrations, see
[`migration_1.0.0_to_1.1.0.md`](migration_1.0.0_to_1.1.0.md) and
[`migration_0.14.0_to_1.0.0.md`](migration_0.14.0_to_1.0.0.md).

## Localization

The package ships English and Arabic translations using `flutter_localizations`,
`intl`, and generated `intl_utils` delegates. Register the package helpers on
your app:

```dart
MaterialApp(
  localizationsDelegates: const [
        // ...
        SuperAutoSuggestionsTranslation.delegate,
      ],
  supportedLocales:
      SuperAutoSuggestionsTranslation.delegate.supportedLocales,
)
```

Built-in package strings such as the required-field message, loading/search
states, Recent group label, inline-create text, fixed/unfixed tooltips, and
Advanced Search chrome follow the active locale. Explicit custom strings passed
to the widget continue to take precedence. Registration is optional: when no
`SuperAutoSuggestionsTranslation` is available in the widget tree, package
widgets fall back to the built-in English localization.
