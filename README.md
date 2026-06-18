# super_auto_suggestion_box

[![style: flutter_lints](https://img.shields.io/badge/style-flutter__lints-blue)](https://pub.dev/packages/flutter_lints)

A **GeniusLink design-system** Flutter package shipping the **`AutoSuggestionsBox`** —
a typeahead / combobox field with local + remote sources, prefix / contains / fuzzy
matching, single- and multi-select, free-text entry, a local-first progressive
`remoteFallback` source, an advanced-search overlay, and a `bare` embedding mode.

It also carries the shared GeniusLink **core** foundation (theme tokens,
`ThemeExtension`s, text styles, and a few design-system widgets) the box is built on.
The companion [`super_table_field`](../super_table_field) package depends on this one
and re-exports it, so a `SuperTable`'s `combo` columns are edited through the real
`AutoSuggestionsBox`.

Light + dark themes, full LTR + RTL.

## Features

- ✅ **Typeahead / combobox** — `AutoSuggestionsBox<T>` driven by an
  `AutoSuggestionsBoxController<T>`.
- ✅ **Matching strategies** — prefix, contains, and fuzzy ranking.
- ✅ **Single- & multi-select**, **free-text entry** (`allowFreeText`), grouped results.
- ✅ **Suggestion sources** — `SuggestionSources.list / .strings / .fuzzy / .async /
  .remoteFallback` (local-first progressive).
- ✅ **Advanced-search overlay** — opens on `Ctrl`/`⌘`+`F` (`advancedSearch: true`).
- ✅ **Restore-on-blur** and **caret-anchored query** matching.
- ✅ **`bare` embedding mode** — drop the box into a cell or compact toolbar.

## Getting started

Add the dependency:

```yaml
dependencies:
  super_auto_suggestion_box:
    path: ../super_auto_suggestion_box   # or a git / hosted ref
```

Register the `ThemeExtension`s on your `ThemeData`:

```dart
import 'package:super_auto_suggestion_box/super_auto_suggestion_box.dart';

MaterialApp(
  theme: ThemeData(
    brightness: Brightness.light,
    extensions: const [SuperThemeData.light, AutoSuggestionsBoxThemeData.light],
  ),
  darkTheme: ThemeData(
    brightness: Brightness.dark,
    extensions: const [SuperThemeData.dark, AutoSuggestionsBoxThemeData.dark],
  ),
);
```

> **Fonts** — the design system uses Manrope (display), Inter (body), JetBrains Mono
> (numerics) and Noto Naskh Arabic. Drop the `.ttf` files under `assets/fonts/` and
> uncomment the `fonts:` block in `pubspec.yaml`; otherwise platform defaults are used.

## Usage

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

- `SuggestionSources.list(...)` / `.strings(...)` — static, in-memory.
- `SuggestionSources.fuzzy(...)` — fuzzy-ranked matching.
- `SuggestionSources.async(...)` — debounced purely-remote search.
- `SuggestionSources.remoteFallback(...)` — local-first progressive: shows local
  matches instantly and only calls `fetch` when local matches are
  `remoteThreshold` or fewer, merging remote rows (de-duplicated) behind a
  *loading more* indicator (`controller.isLoadingMore`).

### Behaviour to know

- **Advanced search**: `advancedSearch: true` opens a modal search surface on
  `Ctrl`/`⌘`+`F`; customise via `advancedSearchBuilder`.
- **Restore on blur**: leaving without picking reverts unconfirmed typing to the
  last committed value (unless none); disable with `restoreOnBlur: false`.
- **Caret-anchored query**: matching uses text from the start up to the caret
  (`controller.effectiveQuery`), so mid-string edits filter on the relevant prefix.

### Embedding (`bare` mode)

Set `bare: true`, pass a `fieldHeight`, and provide `onEscape` / `onTabNext` /
`onTabPrev` when you place the box inside a cell or compact toolbar — this is exactly
how `super_table_field` embeds it for `combo` columns.

## Example

A runnable gallery lives in `example/`:

```bash
cd example
flutter run
```

## Architecture

Clean Architecture, MVC-aligned, split per feature. `AutoSuggestionsBoxController`
is a `ChangeNotifier` that owns all state and domain logic; the widget observes it
and forwards intents; entities and usecases (matching, querying) are plain Dart.
Shared tokens/widgets live in `lib/src/core/`. Import the single barrel:

```dart
import 'package:super_auto_suggestion_box/super_auto_suggestion_box.dart';
```

## License

Internal GeniusLink design-system package.
