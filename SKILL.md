---
name: super-auto-suggestion-box
description: >
  Use the super_auto_suggestion_box Flutter package to build GeniusLink
  design-system typeahead / combobox inputs. Version 1.3.1 uses raw T values,
  FormField<T>-based validation over the selected T?, and onSelectionChanged
  for select/de-select notifications while suggestionBuilder derives row metadata.
---

# Super Auto Suggestion Box - Agent Skill

Use `super_auto_suggestion_box` for GeniusLink
`SuperAutoSuggestionsBox<T>` fields: local and remote sources,
prefix/contains/words/fuzzy matching, shadow-hint completion,
single/multi-select, free text, progressive remote fallback, server-side
paging, recents, inline create, trailing metadata, record binding,
read-only/fixable states, validation, advanced search, and bare embedding.

## Install

```yaml
dependencies:
  super_auto_suggestion_box: ^1.3.1
```

```dart
import 'package:super_auto_suggestion_box/super_auto_suggestion_box.dart';
```

Use `super_core >=3.3.0` with explicit `SuperTextTheme` values:

```dart
final typography = SuperTextTheme();

theme: SuperMaterialThemeData.light(
  textTheme: typography,
  primaryTextTheme: typography,
),
darkTheme: SuperMaterialThemeData.dark(
  textTheme: typography,
  primaryTextTheme: typography,
),
```

## Required 1.3.1 Pattern

Public APIs use raw `T` values. Do not build
`List<SuperAutoSuggestionsItem<T>>` as source data. Create
`SuperAutoSuggestionsItem<T>` only inside `suggestionBuilder` or custom
render-description helpers.

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
  keywords: [code],
);

SuperAutoSuggestionsBox<String>(
  source: SuperAutoSuggestionSources.list<String>(accounts),
  suggestionBuilder: accountSuggestion,
  onSelectionChanged: (codes) {},
);
```

Use the normal `SuperAutoSuggestionsItem<T>(...)` constructor for every row.
`titleText` is the canonical searchable/committed title. `description`, `trailing`,
and `icon` accept custom widgets directly; `descriptionText`, `trailingText`,
and `iconData` remain available for metadata-only rows. `enabledSnapshot` is an
optional `Stream?` field alongside the immediate `enabled` boolean.

## 1.3.0 Presentation Names

Use the canonical `Super`-prefixed widget classes:
`SuperAutoSuggestionsBoxThemeData`, `SuperAutoSuggestionsBoxFocusedStyle`,
`SuperAutoSuggestionsHighlight`, and `SuperAutoSuggestionsPanel<T>`.
The pre-1.3.0 names remain only as deprecated typedefs.

## 1.3.1 Advanced Search and form-field foundation

- Desktop Advanced Search uses a dialog.
- Android, iOS, and Fuchsia use an edge-to-edge modal bottom sheet.
- Do not show keyboard-shortcut descriptions on mobile.
- Advanced Search must display `SuperAutoSuggestionsItem.group` headings using
  the same adjacency rule as the inline overlay.
- Reuse `super_form_field`'s `FieldShell`, `ErrorBadge`, and `FieldIconButton`;
  do not recreate those components locally.

## Sources

Built-in sources accept raw data/fetch configuration only. Provide
`suggestionBuilder` to `SuperAutoSuggestionsBox`; it owns metadata conversion for
both widget-created and external controllers:

```dart
SuperAutoSuggestionSources.list<String>(accounts);

SuperAutoSuggestionSources.async<String>(
  (query) => api.searchAccounts(query), // Future<List<String>>
  initialItems: accounts.take(5).toList(),
);

SuperAutoSuggestionSources.hybrid<String>(
  initialItems: accounts,
  fetch: (query) => api.searchAccounts(query),
);

SuperAutoSuggestionSources.remoteFallback<String>(
  initialItems: accounts,
  fetch: (query) => api.searchAccounts(query),
);

SuperAutoSuggestionSources.paged<String>(
  (query, page) async {
    final result = await api.searchAccountsPage(query, page);
    return SuperSuggestionsPage<String>(
      items: result.codes,
      hasMore: result.hasMore,
    );
  },
  resolveFrom: accounts,
);
```

Use `SuperAutoSuggestionSources.strings(values)` only when the raw string is also the
label. The source still receives no builder.

When direct source construction is required, use the canonical 1.2.0 class
names:

- `SuperAutoListSuggestionsSource<T>`
- `SuperAutoAsyncSuggestionsSource<T>`
- `SuperAutoHybridSuggestionsSource<T>`
- `SuperAutoRemoteFallbackSuggestionsSource<T>`
- `SuperAutoPagedSuggestionsSource<T>`

Prefer the `SuperAutoSuggestionSources` factories for ordinary usage.

## Controller And Callbacks

Controller state is raw:

```dart
final controller = SuperAutoSuggestionsController<String>(
  initialValue: '1020',
  initialSelected: const ['1010'],
);

controller.results;           // List<String>
controller.selected;          // String?
controller.selectedItems;     // List<String>
controller.selectedValues;    // List<String>
controller.recents;           // List<String>

controller.select('1010');
controller.toggleSelected('4000');
controller.selectByValue('1020');
```

Pass the builder on the widget when rendering that controller:

```dart
SuperAutoSuggestionsBox<String>(
  controller: controller,
  source: SuperAutoSuggestionSources.list<String>(accounts),
  suggestionBuilder: accountSuggestion,
  initialRecents: const ['4000'],
  showRecents: true,
  onRecentsChanged: (codes) {},
);
```

After the controller is attached to a `SuperAutoSuggestionsBox`, use
render-facing accessors only when a UI needs metadata:

```dart
controller.suggestions;
controller.suggestionAt(0);
controller.highlightedSuggestion;
controller.selectedSuggestion;
```

Selection callbacks are raw. `onSelectionChanged` is authoritative for both
select and de-select operations; single-select emits `[item]` or `[]`, while
multi-select emits the full selected list:

```dart
SuperAutoSuggestionsBox<String>(
  source: SuperAutoSuggestionSources.list<String>(accounts),
  suggestionBuilder: accountSuggestion,
  multiSelect: true,
  onSelectionChanged: (codes) {},
  onCreate: (query) async {
    final created = await api.createAccount(query);
    return created.code;
  },
  itemBuilder: (context, code, suggestion, highlighted) {
    return Text('${suggestion.displayText} ($code)');
  },
);
```

## Behavior Notes

- Use `remoteFallback` for mostly-local data so local rows appear immediately
  while the remote fetch appends behind the loading-more indicator.
- Use `paged` when a single response would be too large.
- Validation uses an outer `FormField<T>`. `validator` receives the selected
  raw `T?`; `required` and `forceError` continue to participate
  in the package validation flow. Errors surface through the suffix badge tooltip.
- `controller.formFieldKey` is `GlobalKey<FormFieldState<T>>?`. Read selected
  values from controller state when a host form is submitted.
- Use `decoration: InputDecoration(labelText:, helperText:, hintText:,
  prefixIcon:)` for field copy and iconography. Legacy `label`, `hint`, and
  `leading` remain deprecated.
- `readOnly` keeps contrast while blocking edits. `disabled` dims and blocks.
- `allowFixed` exposes `controller.isFixed`; fixed fields block controller and
  user mutations without dimming.
- `showShadowHint` and `completeShadowHintOnTab` remain enabled by default.
- In single-select mode, `textInputAction: TextInputAction.next` advances
  focus to the next focusable field after an item is selected. Multi-select
  keeps focus in the suggestions field.

## Common Mistakes

- Passing `List<SuperAutoSuggestionsItem<T>>` to source `initialItems`, fetch
  callbacks, controller `initialSelected`, widget `initialRecents`, or
  `onCreate`. Use raw `T` values.
- Omitting the required `source` on `SuperAutoSuggestionsBox`. Wrap local data
  with `SuperAutoSuggestionSources.list<T>(values)`.
- Omitting `suggestionBuilder` on `SuperAutoSuggestionsBox`.
- Reading `controller.results` as suggestions. Use `controller.suggestions` or
  `controller.suggestionAt(index)` for metadata.
- Returning `SuperAutoSuggestionsItem<T>` from `onCreate`. Return the raw created item.
- Using `.async` for mostly-local data. Prefer `.remoteFallback`.
- Using pre-1.2.0 concrete source class names. Use the `SuperAuto...SuggestionsSource` names above; use `SuperAutoSuggestionSources` for factory construction.
- Recreating a controller in `build` for pre-filled or fixed fields. Keep it in
  state and dispose it.
- Using removed 1.1.0 callbacks (`onChanged`, `onSubmitted`, `onSelected`,
  `onFieldSubmitted`, `onEditingComplete`, `onSave`, or `onValidity`). Use
  controller state/listeners for query state, `onSelectionChanged` for
  selection state, and Flutter `Form` validation for validity.
- Writing a validator for `String` query text. In 1.2.0 the validator receives
  the selected raw `T?`.

## Localization

Register `SuperAutoSuggestionsTranslation.localizationsDelegates` and `SuperAutoSuggestionsTranslation.supportedLocales` on the app's `MaterialApp`. Built-in strings are available in English and Arabic. Registration is optional: if `SuperAutoSuggestionsTranslation` is absent from the widget tree, package widgets use English by default.
