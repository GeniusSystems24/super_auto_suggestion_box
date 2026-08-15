---
name: super-auto-suggestion-box
description: >
  Use the super_auto_suggestion_box Flutter package to build GeniusLink
  design-system typeahead / combobox inputs. Version 1.1.0 accepts raw T values
  and uses suggestionBuilder to derive SuperAutoSuggestionsItem metadata for
  rendering, search, filtering, selection, paging, recents, and inline create.
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
  super_auto_suggestion_box: ^1.1.0
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

## Required 1.1.0 Pattern

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
  source: SuggestionSources.list<String>(accounts),
  suggestionBuilder: accountSuggestion,
  onSelected: (code) {},
);
```

Use `SuperAutoSuggestionsItem.build` instead when title, description, trailing,
or icon content must be a custom widget. Widget-built rows fall back to
`value.toString()` for searchable/committed text, so add `keywords` for any
additional matching terms.

## Sources

Built-in sources accept raw data/fetch configuration only. Provide
`suggestionBuilder` to `SuperAutoSuggestionsBox`; it owns metadata conversion for
both widget-created and external controllers:

```dart
SuggestionSources.list<String>(accounts);

SuggestionSources.async<String>(
  (query) => api.searchAccounts(query), // Future<List<String>>
  initialItems: accounts.take(5).toList(),
);

SuggestionSources.hybrid<String>(
  initialItems: accounts,
  fetch: (query) => api.searchAccounts(query),
);

SuggestionSources.remoteFallback<String>(
  initialItems: accounts,
  fetch: (query) => api.searchAccounts(query),
);

SuggestionSources.paged<String>(
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

Use `SuggestionSources.strings(values)` only when the raw string is also the
label. The source still receives no builder.

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
  source: SuggestionSources.list<String>(accounts),
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

Widget callbacks are raw:

```dart
SuperAutoSuggestionsBox<String>(
  source: SuggestionSources.list<String>(accounts),
  suggestionBuilder: accountSuggestion,
  multiSelect: true,
  onSelected: (code) {},
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
- Validation uses `required`, `validator`, `forceError`, and `onValidity`; errors
  surface through the suffix badge tooltip.
- Use `decoration: InputDecoration(labelText:, helperText:, hintText:,
  prefixIcon:)` for field copy and iconography. Legacy `label`, `hint`, and
  `leading` remain deprecated.
- `readOnly` keeps contrast while blocking edits. `disabled` dims and blocks.
- `allowFixed` exposes `controller.isFixed`; fixed fields block controller and
  user mutations without dimming.
- `showShadowHint` and `completeShadowHintOnTab` remain enabled by default.

## Common Mistakes

- Passing `List<SuperAutoSuggestionsItem<T>>` to source `initialItems`, fetch
  callbacks, controller `initialSelected`, widget `initialRecents`, or
  `onCreate`. Use raw `T` values.
- Omitting the required `source` on `SuperAutoSuggestionsBox`. Wrap local data
  with `SuggestionSources.list<T>(values)`.
- Omitting `suggestionBuilder` on `SuperAutoSuggestionsBox`.
- Reading `controller.results` as suggestions. Use `controller.suggestions` or
  `controller.suggestionAt(index)` for metadata.
- Returning `SuperAutoSuggestionsItem<T>` from `onCreate`. Return the raw created item.
- Using `.async` for mostly-local data. Prefer `.remoteFallback`.
- Recreating a controller in `build` for pre-filled or fixed fields. Keep it in
  state and dispose it.
