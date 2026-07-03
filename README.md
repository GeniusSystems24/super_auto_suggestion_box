# super_auto_suggestion_box

[![style: flutter_lints](https://img.shields.io/badge/style-flutter__lints-blue)](https://pub.dev/packages/flutter_lints)

A **GeniusLink design-system** Flutter package shipping the **`AutoSuggestionsBox`** —
a typeahead / combobox field with local + remote sources, prefix / contains / words /
fuzzy-ranked matching, single- and multi-select, free-text entry, a local-first
progressive `remoteFallback` source, **server-side paged infinite-scroll**,
**recently-used** suggestions, **inline create**, a **trailing meta column**,
**record binding + read-only** mode, an advanced-search overlay, and a `bare`
embedding mode.

It also carries the shared GeniusLink **core** foundation (theme tokens,
`ThemeExtension`s, text styles, and a few design-system widgets) the box is built on.
The companion [`super_table_field`](../super_table_field) package depends on this one
and re-exports it, so a `SuperTable`'s `combo` columns are edited through the real
`AutoSuggestionsBox`.

Light + dark themes, full LTR + RTL.

## Features

- ✅ **Typeahead / combobox** — `AutoSuggestionsBox<T>` driven by an
  `AutoSuggestionsBoxController<T>`.
- ✅ **Consistent field design** — same height, layout and states as the
  `super_form_field` inputs (uppercase label, 42/36 px density, 4 px frame,
  focused-fill + danger-halo).
- ✅ **Validation** — `required` + a custom `validator`; errors surface through a
  suffix **error badge** tooltip (never inline), gated on touch / `forceError`,
  reported via `onValidity`.
- ✅ **`disabled`** state and a per-field `theme` override.
- ✅ **Themeable focused state** — `AutoSuggestionsBoxFocusedStyle` (`fillColor`,
  `border`, `fontStyle`, `cursorColor`, `shadow`).
- ✅ **Matching strategies** — prefix, contains, words, and **fuzzy (ranked by
  match quality)**.
- ✅ **Single- & multi-select**, **free-text entry** (`allowFreeText`), grouped results.
- ✅ **Recently-used** — recent picks pin to a *Recent* section when the field is
  empty (`showRecents`, `maxRecents`, `initialRecents`, `onRecentsChanged`).
- ✅ **Inline create** — a *＋ Create “…”* action for missing master data (`onCreate`).
- ✅ **Trailing meta column** — `AutoSuggestion.trailing` shows a right-aligned
  mono value (balance / qty / price) so rows read as code · name · amount.
- ✅ **Record binding + read-only** — `controller.selectByValue(id)` and a
  `readOnly` view state.
- ✅ **Suggestion sources** — `SuggestionSources.list / .strings / .fuzzy / .async /
  .hybrid / .remoteFallback / .paged` (paged = infinite scroll for large data).
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

### Validation (`required` · `validator`)

Errors surface through a suffix **error badge** (hover / long-press for the
tooltip) — never inline, matching `super_form_field`. Validation is silent until
the field is first blurred (or `forceError: true`); `onValidity` reports the
current error on every change.

```dart
AutoSuggestionsBox<String>(
  items: accounts,
  label: 'Debit Account',
  required: true,                       // red * on the label + "required" rule
  requiredMessage: 'Choose an account', // optional custom copy
  hint: 'Pick an account from the chart',
  validator: (value) {
    if (value.trim().isEmpty) return null;        // `required` handles empty
    final ok = accounts.any((a) => a.label == value);
    return ok ? null : 'Pick an account from the list';
  },
  onValidity: (error) => setState(() => _error = error),
);
```

### Disabled

```dart
AutoSuggestionsBox<String>(
  controller: lockedController, // pre-filled
  label: 'Reconciliation Account',
  disabled: true, // dimmed, no typing, no overlay, no errors
);
```

### Per-field theme + focused style

Assign a theme directly to one box (overriding the ambient extension), and
customise the focused state with `AutoSuggestionsBoxFocusedStyle` — any field you
leave null falls back to the resting token.

```dart
AutoSuggestionsBox<String>(
  items: accounts,
  label: 'Ledger Account',
  theme: AutoSuggestionsBoxThemeData.of(context).copyWith(
    focusedStyle: const AutoSuggestionsBoxFocusedStyle(
      fillColor: Color(0x141DB88A),
      border: BorderSide(color: Color(0xFF1DB88A), width: 1.6),
      fontStyle: TextStyle(fontWeight: FontWeight.w600),
      cursorColor: Color(0xFF1DB88A),
    ),
  ),
);
```

Set the default focused style for **every** box by baking it into the theme
extension you register on `ThemeData` (via `.copyWith(focusedStyle: …)`).

### Suggestion sources

- `SuggestionSources.list(...)` / `.strings(...)` — static, in-memory.
- `SuggestionSources.fuzzy(...)` — fuzzy-ranked matching (ordered by match quality).
- `SuggestionSources.async(...)` — debounced purely-remote search.
- `SuggestionSources.hybrid(...)` — single-phase local-first: filters the local
  set and, when matches are thin, fetches once and merges (behind the field spinner).
- `SuggestionSources.remoteFallback(...)` — local-first **progressive**: shows local
  matches instantly and only calls `fetch` when local matches are
  `remoteThreshold` or fewer, merging remote rows (de-duplicated) behind a
  *loading more* indicator (`controller.isLoadingMore`).
- `SuggestionSources.paged(fetch)` — **infinite scroll** for large master data:
  returns one `SuggestionsPage(items, hasMore)` per `(query, page)`; the overlay
  loads page 0 and appends the next page as you scroll near the bottom
  (`controller.hasMore` / `isLoadingPage` / `loadNextPage()`).

### ERP features (0.7.0)

**Recently-used** — pin recent picks to a *Recent* section on the empty field
(build the controller yourself to enable it):

```dart
final box = AutoSuggestionsBoxController<String>(
  source: SuggestionSources.list<String>(accounts),
  showRecents: true,
  maxRecents: 5,
  initialRecents: savedRecents,               // restore from disk
  onRecentsChanged: (r) => persist(r),        // persist on change
);
AutoSuggestionsBox<String>(controller: box, label: 'Account');
```

**Inline create** — offer a *＋ Create “…”* action for missing master data
(Enter triggers it before a free-text submit; async-aware):

```dart
AutoSuggestionsBox<String>(
  items: vendors,
  onCreate: (query) async {
    final created = await api.createVendor(query);   // POST
    return AutoSuggestion(value: created.id, label: created.name);
  },
);
```

**Trailing meta column** — a right-aligned tabular-mono value (code · name · amount):

```dart
AutoSuggestion(value: '1020', label: 'Bank — Operating',
    description: '1020 · Assets', trailing: '285,120.50');
```

**Record binding + read-only** — resolve a stored id to its row, and a view state:

```dart
box.selectByValue('4000');                    // bind a record's stored code
AutoSuggestionsBox<String>(controller: box, readOnly: posted); // view mode
```

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
