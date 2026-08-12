---
name: super-auto-suggestion-box
description: >
  Use the super_auto_suggestion_box Flutter package to build GeniusLink
  design-system typeahead / combobox inputs. Version 1.0.0 accepts raw T values
  and uses suggestionBuilder to derive AutoSuggestion metadata for rendering,
  search, filtering, selection, paging, recents, and inline create.
---

# Super Auto Suggestion Box - Agent Skill

Use `super_auto_suggestion_box` for GeniusLink `AutoSuggestionsBox<T>` fields:
local and remote sources, prefix/contains/words/fuzzy matching, shadow-hint
completion, single/multi-select, free text, progressive remote fallback,
server-side paging, recents, inline create, trailing metadata, record binding,
read-only/fixable states, validation, advanced search, and bare embedding.

## Install

```yaml
dependencies:
  super_auto_suggestion_box: ^1.0.0
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

## Required 1.0.0 Pattern

Public APIs use raw `T` values. Do not build `List<AutoSuggestion<T>>` as source
data. Create `AutoSuggestion<T>` only inside `suggestionBuilder` or custom
render-description helpers.

```dart
final accounts = ['1010', '1020', '4000'];

AutoSuggestion<String> accountSuggestion(
  List<String> items,
  int index,
  String code,
) => AutoSuggestion<String>(
  value: code,
  label: switch (code) {
    '1010' => 'Cash on Hand',
    '1020' => 'Bank - Operating',
    '4000' => 'Sales Revenue',
    _ => code,
  },
  description: 'Account $code',
  keywords: [code],
);

AutoSuggestionsBox<String>(
  items: accounts,
  suggestionBuilder: accountSuggestion,
  onSelected: (code) {},
);
```

## Sources

Built-in sources accept raw data/fetch configuration only. Provide
`suggestionBuilder` to `AutoSuggestionsBox`; it owns metadata conversion for
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
    return SuggestionsPage<String>(
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
final controller = AutoSuggestionsBoxController<String>(
  source: SuggestionSources.list<String>(accounts),
  initialValue: '1020',
  initialSelected: const ['1010'],
  initialRecents: const ['4000'],
  showRecents: true,
  onRecentsChanged: (codes) {},
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
AutoSuggestionsBox<String>(
  controller: controller,
  suggestionBuilder: accountSuggestion,
);
```

After the controller is attached to an `AutoSuggestionsBox`, use render-facing
accessors only when a UI needs metadata:

```dart
controller.suggestions;
controller.suggestionAt(0);
controller.highlightedSuggestion;
controller.selectedSuggestion;
```

Widget callbacks are raw:

```dart
AutoSuggestionsBox<String>(
  items: accounts,
  suggestionBuilder: accountSuggestion,
  multiSelect: true,
  initialSelected: const ['1010'],
  onSelected: (code) {},
  onSelectionChanged: (codes) {},
  onCreate: (query) async {
    final created = await api.createAccount(query);
    return created.code;
  },
  itemBuilder: (context, code, suggestion, highlighted) {
    return Text('${suggestion.label} ($code)');
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

- Passing `List<AutoSuggestion<T>>` to `items`, `initialItems`, fetch callbacks,
  `initialSelected`, `initialRecents`, or `onCreate`. Use raw `T` values.
- Omitting `suggestionBuilder` on `AutoSuggestionsBox`.
- Reading `controller.results` as suggestions. Use `controller.suggestions` or
  `controller.suggestionAt(index)` for metadata.
- Returning `AutoSuggestion<T>` from `onCreate`. Return the raw created item.
- Using `.async` for mostly-local data. Prefer `.remoteFallback`.
- Recreating a controller in `build` for pre-filled or fixed fields. Keep it in
  state and dispose it.
