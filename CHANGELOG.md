# Changelog

All notable changes to **super_auto_suggestion_box** are documented here. Format
follows [Keep a Changelog](https://keepachangelog.com/); versioning is
[SemVer](https://semver.org/).

## [0.8.0] — 2026-07-16

### Added

- **`AutoSuggestionsBoxThemeData.fromMaterialTheme(SuperMaterialThemeData)`** — derives the
  component theme directly from a `SuperMaterialThemeData`, reading palette-,
  brightness- and device-mode-aware tokens from its registered
  `SuperThemeData` instead of duplicating hard-coded light/dark hex.
- ``AutoSuggestionsBoxThemeData.of(context)`` now prefers this bridge: it returns an explicitly registered
  `AutoSuggestionsBoxThemeData` extension when present, otherwise derives from the ambient
  `SuperMaterialThemeData`, and only falls back to the built-in preset when
  neither is available.

### Changed

- Upgraded to **super_core 1.1.0** (`SuperMaterialThemeData` is now a
  `ThemeData` subclass with responsive `SuperDeviceMode` tokens). Minimum
  raised to `dart >=3.8.0`, `flutter >=3.32.0`.

---

## [0.7.1] — 2026-07-14

### Changed

- Upgraded to **super_core 1.0.0**. No source changes required — all
  `AutoSuggestionsBoxThemeData` surfaces are read via `SuperThemeData.of(context)`,
  which is now registered automatically by `SuperMaterialThemeData`. Palette
  switching and light/dark mode work without any extra wiring:

  ```dart
  MaterialApp(
    theme:     SuperMaterialThemeData.light(palette: SuperPalette.purplePalette),
    darkTheme: SuperMaterialThemeData.dark(palette: SuperPalette.purplePalette),
    // AutoSuggestionsBox adapts automatically — no extra setup needed.
  );
  ```

- The `AutoSuggestionsBoxThemeData.of(context)` fallback chain now benefits from
  the richer palette-derived `SuperThemeData` registered by `SuperMaterialThemeData`,
  so the suggestion overlay and field chrome inherit the active palette's primary
  color via `Theme.of(context).colorScheme.primary`.

---

## [0.7.0] — 2026-07-04

Five ERP-focused capabilities, plus source/ranking fixes. All additions are
backwards-compatible — existing call sites (and the `super_table_field` combo
embedding) compile unchanged.

### Added

- **Recently-used suggestions.** With `showRecents: true` on the controller the
  most-recently-committed rows pin to a **Recent** section at the top of the
  overlay while the field is empty — the biggest data-entry accelerator in an ERP
  (the same accounts / vendors / items get re-picked). Tunables: `maxRecents`,
  `initialRecents`, `recentsGroupLabel`, `onRecentsChanged` (persist & restore),
  plus `controller.recents` / `setRecents` / `clearRecents`.
- **Inline create.** `onCreate: (query) => FutureOr<AutoSuggestion?>` surfaces a
  **“＋ Create …”** action at the foot of the overlay (and takes Enter ahead of a
  free-text submit) when the typed value matches no row — add a missing vendor /
  item / account without leaving the field. Async-aware (a spinner shows while it
  resolves); `createLabelBuilder` customises the label.
- **Server-side pagination / infinite scroll.** `SuggestionSources.paged(fetch)`
  serves one `SuggestionsPage(items, hasMore)` per `(query, page)`; the overlay
  loads page 0 and appends the next page as you scroll near the bottom, behind a
  *loading more…* row. Drives huge master data (thousands of SKUs). Controller
  adds `isPaged` / `hasMore` / `isLoadingPage` / `loadNextPage()`.
- **Trailing meta column.** `AutoSuggestion.trailing` renders a right-aligned,
  tabular-mono value (balance / on-hand qty / unit price / status) so a lookup
  reads like a mini-table: code · name · amount.
- **Record binding + read-only view mode.** `controller.selectByValue(value)`
  resolves a stored id back to its full row (via the source’s new `resolve`) and
  commits it — for a form bound to a record. `readOnly: true` shows the committed
  value at full contrast but blocks typing, the overlay and the clear/chevron
  affordances (the “posted / review” state; unlike `disabled` it isn’t dimmed).

### Fixed

- **`SuggestionSources.fuzzy(...)`** now exists (it was documented but missing);
  it is the ranked shorthand for `list(items, match: fuzzy)`.
- **Fuzzy results are ranked by match quality** — a new subsequence scorer
  rewards consecutive runs and word-boundary hits, so loose queries surface the
  best match first (previously fuzzy hits kept arbitrary order).
- **`SuggestionSources.hybrid(...)`** now returns the single-phase
  `HybridSuggestionsSource` it documents (it previously constructed the
  progressive fallback source, leaving `HybridSuggestionsSource` as dead code).
  `remoteFallback` remains the progressive variant.

## [0.6.0] — 2026-07-01

### Added

- **`required`** — marks the field mandatory: appends a red `*` to the `label`
  and adds an implicit *“this field is required”* validator (customise the copy
  with `requiredMessage`). In multi-select it fails while nothing is chosen.
- **`validator`** — a synchronous `String? Function(String value)`. Its message
  (or the required message) surfaces through a suffix **error badge** with a
  hover / long-press tooltip — never inline, matching the `super_form_field`
  rule. Validation is silent until the field is first blurred (touched) or
  `forceError: true`; `onValidity` reports the current error on every change.
- **`disabled`** — dims the field to 55 %, blocks typing and opening the
  overlay, and suppresses validation. Takes precedence over `enabled`.
- **Field-level `theme`** — assign an `AutoSuggestionsBoxThemeData` directly to a
  single box, overriding the ambient extension without touching app-wide theming.
- **`AutoSuggestionsBoxFocusedStyle`** + **`focusedStyle`** on
  `AutoSuggestionsBoxThemeData` — customise the focused state: `fillColor`,
  `border` (color + width), `fontStyle`, `cursorColor`, and a focus-halo `shadow`.
  Each field is optional and falls back to the resting token.
- **`density`** (`FieldDensity.comfortable` / `.compact`) and a `hint` line
  beneath the control (hidden whenever an error shows).

### Changed

- **Field design now matches `super_form_field`.** The control is rebuilt on the
  shared field foundation: 42 px comfortable / 36 px compact height, 4 px radius,
  a 1.4 px animated frame, uppercase label with required asterisk, focused-fill +
  danger-halo states, and the suffix error badge. Existing single- / multi-select,
  free-text, grouped, remote-fallback and advanced-search behaviour is unchanged.

## [0.5.0] — 2026-06-18

### Changed

- **Split out of `super_table_field` into its own package.** The
  `AutoSuggestionsBox` typeahead — together with the shared GeniusLink **core**
  foundation (theme tokens, `ThemeExtension`s, text styles, design-system
  widgets) it is built on — now lives here. `super_table_field` (also `0.5.0`)
  depends on this package and re-exports it, so existing
  `import 'package:super_table_field/super_table_field.dart';` code keeps
  working unchanged.
- Import directly with
  `import 'package:super_auto_suggestion_box/super_auto_suggestion_box.dart';`
  when you only need the box (no table).

The component API is unchanged from `super_table_field` `0.4.0` — see the entries
below for what shipped while it was part of that package.

## [0.3.0] — 2026-06-17

### Added

- **`SuggestionSources.remoteFallback(...)`** — local-first progressive source:
  shows local matches instantly and fetches from a remote backend only when the
  local match count is `remoteThreshold` or fewer, merging results (de-duplicated)
  behind a **“loading more”** indicator. Backed by the `SuggestionsQueryResult`
  two-phase contract and the `isLoadingMore` controller flag.
- **Advanced Search overlay** — `advancedSearch: true` opens a modal search
  surface on `Ctrl`/`⌘`+`F`; customise via `advancedSearchBuilder`.
- **Restore-on-blur** — leaving the field without picking reverts unconfirmed
  typing to the last committed value (unless nothing was ever committed); toggle
  with `restoreOnBlur`.
- **Caret-anchored query** — matching uses the text from the start up to the
  caret (`effectiveQuery`), so mid-string edits filter on the relevant prefix.

## [0.1.0] — 2026-06-16

### Added

- **`AutoSuggestionsBox`** — typeahead/combobox with grouped results, prefix/
  contains/fuzzy matching, single- and multi-select, free-text entry, async +
  list + fuzzy suggestion sources, and a `bare` embedding mode.
- `SuperThemeData` and `AutoSuggestionsBoxThemeData` `ThemeExtension`s with
  light + dark variants; full LTR + RTL support.
- `README.md` and `SKILL.md` (agent usage guide).
