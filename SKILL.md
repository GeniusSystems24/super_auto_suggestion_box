---
name: super-auto-suggestion-box
description: >
  Use the super_auto_suggestion_box Flutter package to build GeniusLink
  design-system typeahead / combobox inputs — AutoSuggestionsBox: local + remote
  suggestion sources, prefix/contains/fuzzy matching, single- and multi-select,
  free-text entry, a local-first progressive remoteFallback source, an
  advanced-search overlay, and a bare embedding mode. Apply when a Flutter app
  needs a themed (light/dark, LTR/RTL) typeahead/autocomplete field, or an
  embeddable pick-or-type combobox. This package also carries the shared
  GeniusLink core theme foundation; the super_table_field package depends on it.
---

# Super Auto Suggestion Box — Agent Skill

`super_auto_suggestion_box` ships the GeniusLink `AutoSuggestionsBox` typeahead and
the shared **core** design-system foundation it is built on. The companion
`super_table_field` package depends on this one and re-exports it (its `combo`
columns are edited through this box).

## When to use

- A standalone typeahead / combobox / autocomplete field in the GeniusLink visual
  language (dark-first ERP / accounting screens, bilingual English + Arabic).
- An embeddable pick-or-type combobox inside a cell or compact toolbar.

Do **not** hand-roll a `DropdownButton`-based combobox or a custom autocomplete —
use this component so theme, keyboard model, and RTL come for free. If you need a
data grid too, use `super_table_field` (which re-exports this package).

## Install & setup

```yaml
dependencies:
  super_auto_suggestion_box: ^x.x.x # lastest version in pub.dev
```

```dart
import 'package:super_auto_suggestion_box/super_auto_suggestion_box.dart';
```

Register the theme extensions on your `ThemeData` (without them colors fall back to
defaults):

```dart
theme: ThemeData(
  brightness: Brightness.light,
  extensions: [SuperThemeData.light, AutoSuggestionsBoxThemeData.light],
),
darkTheme: ThemeData(
  brightness: Brightness.dark,
  extensions: [SuperThemeData.dark, AutoSuggestionsBoxThemeData.dark],
),
```

## AutoSuggestionsBox

```dart
final box = AutoSuggestionsBoxController<String>(
  source: SuggestionSources.list<String>([
    AutoSuggestion(value: 'each', label: 'each'),
    AutoSuggestion(value: 'box',  label: 'box'),
  ]),
  allowFreeText: true,   // false = pick-only
  multiSelect: false,
);

AutoSuggestionsBox<String>(
  controller: box,
  hintText: 'Type or pick…',
  onSelected: (s) => /* s.value, s.label */,
  onSubmitted: (raw) => /* free-text Enter */,
);
```

### Suggestion sources

`SuggestionSources.list(...)` / `.strings(...)` (static), `.fuzzy(...)`
(fuzzy-ranked), `.async(...)` (debounced remote), and `.remoteFallback(...)`
(local-first progressive). Prefer **`remoteFallback`** for “mostly local,
occasionally remote” data: it shows local matches instantly and only calls `fetch`
when local matches ≤ `remoteThreshold`, merging remote rows in behind a *loading
more* indicator (`controller.isLoadingMore`). Use `.async` for purely-remote search.

### Behaviour to know

- **Advanced search**: `advancedSearch: true` opens a modal search surface on
  `Ctrl`/`⌘`+`F` (override with `advancedSearchBuilder`).
- **Restore on blur**: leaving without picking reverts unconfirmed typing to the
  last committed value (unless none); disable with `restoreOnBlur: false`.
- **Caret-anchored query**: matching uses text from the start to the caret
  (`controller.effectiveQuery`).

### Embedding (`bare` mode)

Set `bare: true`, pass a `fieldHeight`, and provide `onEscape` / `onTabNext` /
`onTabPrev` when you place the box inside a cell or compact toolbar (this is exactly
how `super_table_field` embeds it).

## Architecture (when extending)

Clean Architecture per feature under `lib/src/features/auto_suggestion_box/`:
`data/` (datasources, models) · `domain/` (entities, usecases — pure Dart) ·
`presentation/` (`controllers/` = Model/state as `ChangeNotifier`, `widgets/` +
`pages/` = View). Shared tokens/widgets live in `lib/src/core/`. Keep the controller
widget-free.

## Common mistakes

- Forgetting to register `AutoSuggestionsBoxThemeData` → the overlay looks
  unstyled. Register both extensions (`SuperThemeData` + `AutoSuggestionsBoxThemeData`).
- Using `.async` for mostly-local data → prefer `.remoteFallback` so local matches
  show instantly.
- Expecting free text with `allowFreeText: false` (pick-only) — set it `true` to
  accept typed values on Enter.
