# Changelog

All notable changes to **super_auto_suggestion_box** are documented here. Format
follows [Keep a Changelog](https://keepachangelog.com/); versioning is
[SemVer](https://semver.org/).

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
