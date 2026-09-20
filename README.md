# super_auto_suggestion_box

[![style: flutter_lints](https://img.shields.io/badge/style-flutter__lints-blue)](https://pub.dev/packages/flutter_lints)

`super_auto_suggestion_box` provides the GeniusLink `SuperAutoSuggestionsBox<T>`:
a themed typeahead / combobox with local and remote sources, fuzzy matching,
single- and multi-select, free-text entry, progressive remote fallback,
server-side paging, recents, inline create, shadow-hint completion, record
binding, read-only/fixable states, advanced search, validation, and bare
embedding.

Version `1.6.0` introduces `SuperAutoSuggestionBuilder<T>` with the active
`BuildContext` as its first argument. Builders can now derive suggestion-row
presentation from Theme, localization, MediaQuery, and other inherited values
while sources and controllers continue to work with raw `T` values.
Every `SuperAutoSuggestionsBox<T>` requires a
`SuperAutoSuggestionsSource<T>`. Use `SuperAutoSuggestionSources.list<T>(values)` for a
local collection. Initial multi-select values belong to
`SuperAutoSuggestionsController.initialSelected`; query, recents, and
multi-select configuration belong to the widget.

```dart
SuperAutoSuggestionsItem<T> suggestionBuilder(
  BuildContext context,
  List<T> items,
  int index,
  T element,
)
```

`SuperAutoSuggestionsItem<T>` remains public because builders return it, but
callers no longer wrap every collection item, fetch result, selected item,
recent item, or created item in `SuperAutoSuggestionsItem<T>`.

## Suggestion Builder Context

Version `1.6.0` renames `AutoSuggestionBuilder<T>` to
`SuperAutoSuggestionBuilder<T>` and adds the active `BuildContext` as the first
argument.

```dart
SuperAutoSuggestionsItem<T> suggestionBuilder(
  BuildContext context,
  List<T> items,
  int index,
  T element,
)
```

The context belongs to the active `SuperAutoSuggestionsBox`, so builders may
safely use inherited presentation values such as `Theme.of(context)`,
localization, `MediaQuery`, and GeniusLink theme extensions.

```dart
SuperAutoSuggestionsItem<String> accountSuggestion(
  BuildContext context,
  List<String> items,
  int index,
  String code,
) {
  final colors = Theme.of(context).colorScheme;

  return SuperAutoSuggestionsItem<String>(
    value: code,
    titleText: code,
    icon: Icon(Icons.account_balance_outlined, color: colors.primary),
  );
}
```

For migration details, see
[`migration_1.5.0_to_1.6.0.md`](migration_1.5.0_to_1.6.0.md).

## Setup

```yaml
dependencies:
  super_auto_suggestion_box: ^1.6.0
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
        SuperAutoSuggestionLocalization.delegate,
      ],
  supportedLocales:
      SuperAutoSuggestionLocalization.delegate.supportedLocales,
);
```

## Basic Usage

```dart
final units = ['each', 'box', 'carton'];

SuperAutoSuggestionsItem<String> unitSuggestion(
  BuildContext context,
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
  BuildContext context,
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

Custom supporting widgets now use the same constructor. `titleText` remains the
canonical searchable and committed title:

```dart
SuperAutoSuggestionsItem<String>(
  value: '1020',
  titleText: 'Bank - Operating',
  description: const Text('1020 - Current Assets'),
  trailing: const Chip(label: Text('Active')),
  icon: const Icon(Icons.account_balance_outlined),
);
```

`descriptionText`, `trailingText`, and `iconData` remain available when custom
widgets are not needed. Suggestions can also carry an optional
`Stream? enabledSnapshot` alongside the immediate `enabled` boolean.

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

## Presentation Widget Names

The canonical public presentation/widget types now all use the `Super` prefix:
`SuperAutoSuggestionsBoxThemeData`, `SuperAutoSuggestionsBoxFocusedStyle`,
`SuperAutoSuggestionsHighlight`, and `SuperAutoSuggestionsPanel<T>`.
Deprecated typedefs preserve the 1.2.x names during migration.

## Suggestion Presentation And Modes

Use `mode` to control how suggestions are presented:

```dart
SuperAutoSuggestionsBox<String>(
  source: SuperAutoSuggestionSources.list<String>(accounts),
  suggestionBuilder: accountSuggestion,
  mode: SuperAutoSuggestionsMode.textBox,
);
```

The available modes are:

- `SuperAutoSuggestionsMode.textBox`: editable text box with an anchored
  suggestions overlay.
- `SuperAutoSuggestionsMode.advanceView`: field-like launcher that opens the
  Advanced Search View.
- `SuperAutoSuggestionsMode.both`: editable text box plus access to Advanced
  Search.

When `mode` is omitted, desktop platforms default to `textBox`, while Android,
iOS, and Fuchsia default to `advanceView`.

For example, to expose both the normal field interaction and Advanced Search:

```dart
SuperAutoSuggestionsBox<String>(
  source: SuperAutoSuggestionSources.list<String>(accounts),
  suggestionBuilder: accountSuggestion,
  mode: SuperAutoSuggestionsMode.both,
);
```

The deprecated `advancedSearch` constructor field was removed in `1.5.1`.
Use `mode` instead.

### Keyboard-safe layout

On mobile, suggestion surfaces calculate their maximum height from the actually
visible viewport. The area covered by the software keyboard is excluded, so
suggestions do not extend behind the keyboard.

When available vertical space becomes small, the results area flexes and
scrolls inside the remaining space instead of overflowing the panel. Fixed
actions, including the create action, remain visible.

For pages that contain a scrollable parent around a `textBox` suggestions
field, avoid dismissing keyboard focus on every drag when the suggestions must
remain open while scrolling. For example:

```dart
SingleChildScrollView(
  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
  child: SuperAutoSuggestionsBox<String>(
    source: SuperAutoSuggestionSources.list<String>(accounts),
    suggestionBuilder: accountSuggestion,
    mode: SuperAutoSuggestionsMode.textBox,
  ),
);
```

`ScrollViewKeyboardDismissBehavior.onDrag` dismisses the keyboard and removes
focus from the field. A text-box suggestions overlay closes on blur by design.

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

## Create Action

Provide `onCreate` when users may create a new value from the current query.
The callback returns the newly created raw value:

```dart
SuperAutoSuggestionsBox<String>(
  source: SuperAutoSuggestionSources.list<String>(vendors),
  suggestionBuilder: vendorSuggestion,
  onCreate: (query) async {
    final vendor = await api.createVendor(query);
    return vendor.id;
  },
  onSelectionChanged: (vendorIds) {},
);
```

In `1.5.1`, the create action:

- appears before suggestion rows rather than after them;
- uses `ColorScheme.primary` and `ColorScheme.onPrimary` for strong visibility
  across light and dark themes;
- uses a larger touch target on mobile;
- remains visible while the results area flexes or scrolls;
- is also shown in Advanced Search when `onCreate` is non-null, the query is
  non-empty, and no suggestions match.

An Advanced Search example with creation enabled:

```dart
SuperAutoSuggestionsBox<String>(
  source: SuperAutoSuggestionSources.list<String>(projects),
  suggestionBuilder: projectSuggestion,
  mode: SuperAutoSuggestionsMode.both,
  onCreate: (query) async {
    final project = await createProject(query);
    return project.id;
  },
  onSelectionChanged: (projectIds) {},
);
```

## ERP Input And Validation

`SuperAutoSuggestionsBox<T>` participates in an enclosing `Form` through
`FormField<T>`. Its validator receives the selected raw `T?`, not the query
text. Keep a controller when form submission needs to read the selected value.
When `autovalidateMode` is omitted, the box inherits the nearest
`Form.autovalidateMode` before falling back to `AutovalidateMode.disabled`.

```dart
final documentController = SuperAutoSuggestionsController<String>();

Form(
  key: formKey,
  autovalidateMode: AutovalidateMode.onUserInteraction,
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

Use `validationPosition` to choose where validation appears:
`ValidationPosition.suffixIcon` shows the error badge in the field suffix,
`ValidationPosition.underBox` shows error text under the box, and
`ValidationPosition.labelTrailing` shows the error badge at the end of the
label row. When omitted, the box uses `SuperFormField.validationPosition`; when
that is also null, mobile defaults to under-box text and larger screens default
to label-trailing badges.

Use `helpIcon` to add a custom help affordance at the end of the label row:

```dart
SuperAutoSuggestionsBox<String>(
  source: SuperAutoSuggestionSources.list<String>(accounts),
  suggestionBuilder: accountSuggestion,
  decoration: const InputDecoration(labelText: 'Posting account'),
  helpIcon: const Tooltip(
    message: 'Used by journal posting and reports.',
    child: Icon(Icons.help_outline_rounded, size: 18),
  ),
);
```

For keyboard traversal, a single-select field with
`textInputAction: TextInputAction.next` moves focus to the next focusable field
immediately after an item is selected. Multi-select fields keep focus in the
current suggestions field.

## States And Embedding

- `disabled`: dims and blocks interaction.
- `readOnly`: blocks interaction but keeps full contrast for posted/review
  states.
- `allowFixed`: shows a lock/unlock action backed by `controller.isFixed`.
- `mode`: controls text-box, Advanced Search, and combined suggestion
  presentation through `SuperAutoSuggestionsMode`.
- `bare`: removes outer chrome for table cells and compact host surfaces.
- `restoreOnBlur`: restores the last committed raw value when the user leaves
  without picking.

## Migration

Version `1.5.1` removes the deprecated `label`, `leading`, `hint`, and
`advancedSearch` constructor fields.

Use `decoration` for input label, leading icon, and hint configuration:

```dart
SuperAutoSuggestionsBox<String>(
  source: SuperAutoSuggestionSources.list<String>(accounts),
  suggestionBuilder: accountSuggestion,
  decoration: const InputDecoration(
    labelText: 'Account',
    hintText: 'Search accounts',
    prefixIcon: Icon(Icons.account_balance_outlined),
  ),
);
```

Replace the removed `advancedSearch` field with `mode`:

```dart
// Before:
// advancedSearch: true,

// 1.5.1:
mode: SuperAutoSuggestionsMode.both,
```

For earlier API changes, see
[`migration_1.1.0_to_1.2.0.md`](migration_1.1.0_to_1.2.0.md),
[`migration_1.0.0_to_1.1.0.md`](migration_1.0.0_to_1.1.0.md), and
[`migration_0.14.0_to_1.0.0.md`](migration_0.14.0_to_1.0.0.md).

## Localization

The package ships English and Arabic translations using `flutter_localizations`,
`intl`, and generated `intl_utils` delegates. Register the package helpers on
your app:

```dart
MaterialApp(
  localizationsDelegates: const [
        // ...
        SuperAutoSuggestionLocalization.delegate,
      ],
  supportedLocales:
      SuperAutoSuggestionLocalization.delegate.supportedLocales,
)
```

Built-in package strings such as the required-field message, loading/search
states, Recent group label, inline-create text, fixed/unfixed tooltips, and
Advanced Search chrome follow the active locale. Explicit custom strings passed
to the widget continue to take precedence. Registration is optional: when no
`SuperAutoSuggestionLocalization` is available in the widget tree, package
widgets fall back to the built-in English localization.
