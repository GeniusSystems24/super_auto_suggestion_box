# Changelog

All notable changes to **super_auto_suggestion_box** are documented here. Format
follows [Keep a Changelog](https://keepachangelog.com/); versioning is
[SemVer](https://semver.org/).

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
