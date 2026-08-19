# Changelog

All notable changes to **super_auto_suggestion_box** are documented here. Format
follows [Keep a Changelog](https://keepachangelog.com/); versioning is
[SemVer](https://semver.org/).

## 1.3.1 - 2026-08-19

### Changed

- Added `super_form_field` as a direct dependency and reused its shared
  `FieldShell`, `ErrorBadge`, and `FieldIconButton` primitives.
- Removed duplicated private `_FieldLabel`, `_FixedButton`, `_ErrorBadge`, and
  `_IconBtn` implementations from `SuperAutoSuggestionsBox`.
- Mobile Advanced Search is now edge-to-edge inside its modal bottom sheet,
  without outer padding/margin.
- Mobile Advanced Search no longer shows desktop keyboard-shortcut
  descriptions.
- Advanced Search results now render `SuperAutoSuggestionsItem.group` headers
  with the same grouping rule and styling as the inline overlay menu.

### Documentation

- Added `migration_1.3.0_to_1.3.1.md`.
- Updated README, skill guidance, and example version labels for 1.3.1.

## 1.3.0 - 2026-08-19

### Added

- Added optional `description`, `trailing`, and `icon` widget fields directly
  to the default `SuperAutoSuggestionsItem<T>` constructor.
- Added `Stream? enabledSnapshot` to `SuperAutoSuggestionsItem<T>`.

### Changed

- **Breaking:** Removed `SuperAutoSuggestionsItem.build`.
- **Breaking:** Removed the custom suggestion `title` widget field. `titleText`
  is now the canonical searchable, display, and committed title.
- **Breaking:** Renamed the remaining public presentation/widget classes to
  `SuperAutoSuggestionsBoxFocusedStyle`, `SuperAutoSuggestionsBoxThemeData`,
  `SuperAutoSuggestionsHighlight`, and `SuperAutoSuggestionsPanel<T>`.
- Updated package docs and runnable example screens for the 1.3.0 API.

### Deprecated

- Added deprecated compatibility typedefs for
  `AutoSuggestionsBoxFocusedStyle`, `AutoSuggestionsBoxThemeData`,
  `AutoSuggestionsHighlight`, and `AutoSuggestionsPanel<T>`.

### Documentation

- Added `migration_1.2.0_to_1.3.0.md`.

## 1.2.0 - 2026-08-18

### Added

- Added English and Arabic package localization using `flutter_localizations`,
  `intl`, generated `intl_utils` delegates, and
  `SuperAutoSuggestionsLocalizations`.
- Added a safe localization resolver: when
  `SuperAutoSuggestionsLocalization` is not registered in the widget tree,
  package-owned strings use the built-in English localization.

### Changed

- **Breaking:** Renamed `AutoSuggestionsValidator` to
  `SuperAutoSuggestionsValidator<T>` and changed validation from query text to
  the selected raw value: `String? Function(T? value)`.
- **Breaking:** `SuperAutoSuggestionsBox<T>` now participates in Flutter forms
  through an outer `FormField<T>`. The widget validator is passed to
  `FormField.validator`, and controller form keys are typed as
  `GlobalKey<FormFieldState<T>>?`.
- **Breaking:** Removed the public callbacks `onChanged`, `onSubmitted`,
  `onSelected`, `onFieldSubmitted`, `onEditingComplete`, `onSave`, and
  `onValidity`.
- `onSelectionChanged` is now the authoritative selection callback. It fires on
  both select and de-select operations in single- and multi-select modes,
  including controller-driven selection changes.
- In single-select mode, `onSelectionChanged` receives `[item]` after selection
  and `[]` after de-selection. In multi-select mode it receives the complete
  selected list.
- Updated the runnable examples to use selection-driven callbacks and
  `FormState.validate()` plus controller state instead of the removed save and
  field-submission callbacks.

- **Breaking:** Renamed the concrete source implementations to
  `SuperAutoListSuggestionsSource<T>`,
  `SuperAutoAsyncSuggestionsSource<T>`,
  `SuperAutoHybridSuggestionsSource<T>`,
  `SuperAutoRemoteFallbackSuggestionsSource<T>`, and
  `SuperAutoPagedSuggestionsSource<T>`.
- Renamed the source factory namespace from `SuggestionSources` to
  `SuperAutoSuggestionSources`; `SuggestionSources` remains as a deprecated
  compatibility typedef.
- In single-select mode, selecting an item now advances focus when
  `textInputAction == TextInputAction.next`. Multi-select keeps focus in the
  current field. Built-in Advanced Search follows the same rule.

### Documentation

- Updated `README.md`, `SKILL.md`, and example documentation for the 1.2.0 form
  and selection API.
- Added `migration_1.1.0_to_1.2.0.md` with validator, form key, callback, and
  form-integration migration examples.
- Added comprehensive Dartdoc for every built-in source factory and the five
  concrete `SuperAuto...SuggestionsSource` classes, including behavior,
  caching, errors, thresholds, paging, parameters, and examples.

## 1.1.0 - 2026-08-15

### Changed

- Renamed `AutoSuggestionsBoxController<T>` to
  `SuperAutoSuggestionsController<T>`.
- Renamed `AutoSuggestionsBox<T>` to `SuperAutoSuggestionsBox<T>` and the
  suggestion row model to `SuperAutoSuggestionsItem<T>`.
- Renamed suggestion item display properties to `titleText`,
  `descriptionText`, `trailingText`, and `iconData`.
- Added `SuperAutoSuggestionsItem.build` for widget-based titles,
  descriptions, trailing content, and icons while retaining the default
  string-based constructor.
- Renamed `AutoSuggestionsSource<T>` to `SuperAutoSuggestionsSource<T>` and
  retained the old name as a deprecated compatibility typedef.
- Renamed `SuggestionsPage<T>` to `SuperSuggestionsPage<T>` and retained the
  old name as a deprecated compatibility typedef.
- Removed `source` and `suggestionBuilder` from the controller API. The widget
  now owns and internally binds both dependencies.
- Moved query timing, result limits, recents configuration, and multi-select
  configuration from `SuperAutoSuggestionsController` to
  `SuperAutoSuggestionsBox`.
- Made `SuperAutoSuggestionsBox.source` required and removed its `items` and
  `initialSelected` shorthands. Local lists now use `SuggestionSources.list`,
  while initial multi-selection is configured on the controller.
- Removed `initialText` from `SuperAutoSuggestionsController`; provide a
  pre-populated `TextEditingController` when initial free text is required.
- Updated the package documentation, skill, tests, and runnable example screens
  for the widget-owned source API.
- Added dedicated runnable gallery screens for string, list, fuzzy, async,
  hybrid, remote-fallback, and paged sources. Each screen demonstrates basic,
  externally controlled, multi-select, and recent-selection scenarios, and is
  maintained in its own example file.
- Aligned every source example screen with the main gallery's `SuperAppBar`,
  `SuperScaffold`, typography, spacing, markers, and `SuperSectionCard2` style.

### Deprecated

- Deprecated `AutoSuggestionsBoxController<T>` as a compatibility typedef for
  `SuperAutoSuggestionsController<T>`.
- Deprecated `AutoSuggestionsBox<T>` and `AutoSuggestions<T>` as compatibility
  typedefs for their new `Super`-prefixed names.
- Deprecated `AutoSuggestion<T>`, `AutoSuggestionsSource<T>`, and
  `SuggestionsPage<T>` in favor of `SuperAutoSuggestionsItem<T>`,
  `SuperAutoSuggestionsSource<T>`, and `SuperSuggestionsPage<T>`.

### Fixed

- Re-run suggestion matching when only the text-field caret changes. The active
  query is always the text from offset zero through the current caret position,
  including after mouse clicks, arrow keys, and programmatic cursor navigation.

### Documentation

- Added `migration_1.0.0_to_1.1.0.md` covering renamed types and fields,
  deprecated aliases, required source wiring, controller configuration moves,
  widget-built rows, paging, and initial-value migrations.

## 1.0.0 - 2026-08-12

### Changed

- **Breaking:** Migrated the public API to raw `T` values. Callers now pass raw
  items, initial selections, recents, created values, and fetch results instead
  of wrapping them in `AutoSuggestion<T>`.
- `AutoSuggestionsBox.suggestionBuilder` is now the single public conversion
  point from raw `T` items to `AutoSuggestion<T>` metadata:
  `AutoSuggestion<T> Function(List<T> items, int index, T element)`.
- Removed `suggestionBuilder` from `SuggestionSources` and
  `AutoSuggestionsBoxController`. Sources and controllers now remain raw-data
  APIs; `AutoSuggestionsBox` owns the metadata builder and wires it internally.
- Updated all built-in source factories (`list`, `fuzzy`, `async`, `hybrid`,
  `remoteFallback`, and `paged`) to accept raw item collections and raw fetch
  results.
- Preserved local matching, fuzzy ranking, hybrid/remote fallback behavior,
  paging, value resolution, recents, and cached de-duplication by using the
  widget-provided builder internally when suggestion metadata is required.
- Updated controller state and callbacks to expose raw values, including
  `initialValue`, `initialSelected`, `initialRecents`, `results`, `selected`,
  `selectedItems`, `selectedValues`, `recents`, `select`, `toggleSelected`,
  `setSelectedItems`, `setRecents`, `selectByValue`, and
  `commitHighlighted`.
- Kept render-facing metadata available through controller accessors such as
  `suggestions`, `suggestionAt(index)`, `highlightedSuggestion`,
  `selectedSuggestion`, and `committedSuggestion`.
- Updated widget callbacks to use raw values, including `onSelected`,
  `onSelectionChanged`, `onCreate`, and the raw-friendly `itemBuilder`
  signature that receives both the raw item and built suggestion metadata.

### Documentation

- Updated `README.md`, `SKILL.md`, `example/README.md`, runnable examples, and
  test coverage for the raw `T` API and widget-owned `suggestionBuilder`.
- Added `migration_0.14.0_to_1.0.0.md` with before-and-after examples for data
  sources, `initialItems`, fetch callbacks, controllers, `AutoSuggestionsBox`,
  `suggestionBuilder`, selection, creation, recents, and removed
  `AutoSuggestion<T>`-based APIs.

## 0.14.1 — 2026-08-12

### Added

- Added `cachedItems` to async, hybrid, and remote-fallback suggestion sources
  so fetched suggestions are retained for the source instance lifetime.

### Changed

- Hybrid and remote-fallback sources now reuse accumulated fetched suggestions
  during local matching and value resolution, avoiding duplicate cached values
  and unnecessary repeat fetches for already collected rows.

## 0.14.0 — 2026-08-10

### Added

- Added `AutoSuggestionsBox.decoration` for supplying label, helper,
  placeholder, and prefix-icon content through Flutter's standard
  `InputDecoration` API.

### Deprecated

- Deprecated `AutoSuggestionsBox.label`; use
  `decoration: InputDecoration(labelText: ...)`.
- Deprecated `AutoSuggestionsBox.hint`; use
  `decoration: InputDecoration(helperText: ...)`.
- Deprecated `AutoSuggestionsBox.leading`; use
  `decoration: InputDecoration(prefixIcon: ...)`.

### Changed

- Migrated the runnable gallery, README, and agent skill examples to the new
  decoration API. The legacy parameters continue to work during migration.

## 0.13.0 — 2026-08-10

### Added

- Added controller-level `isFixed`, `focusNode`, `isHiden`, and `formFieldKey`
  support for protected values, focus wiring, conditional visibility, and direct
  access to the inner `FormFieldState<String>`.
- Added `AutoSuggestionsBox.allowFixed`, which shows a compact lock/unlock action
  at the trailing edge of the label row and toggles `controller.isFixed`.
- Added a runnable fixable-field gallery example and widget coverage for the new
  controller/widget integration.

### Behavior

- A fixed field retains full visual contrast but blocks editing, clearing,
  committing, and multi-select mutations until it is unlocked.
- `isHiden` hides the complete suggestion box when the host rebuilds.

### Changed

- Raised the minimum `super_core` dependency to `3.3.0`.
- Updated all `SuperMaterialThemeData.light` / `.dark` setup examples to pass
  required `SuperTextTheme` values for `textTheme` and `primaryTextTheme`.
- Migrated example typography reads from the removed
  `SuperThemeData.textTheme` API to `context.superTextTheme`.
- `AutoSuggestionsBox` now resolves body, display, and mono font families from
  the ambient `SuperTextTheme` instead of hard-coding `Inter`, `Manrope`, or
  token-level mono metadata. This keeps the component aligned with custom,
  Arabic, and device-specific typography supplied by the host application.
- Deprecated `AutoSuggestionsBoxThemeData.bodyFont` and `displayFont`; they are
  retained temporarily for source compatibility but are no longer used
  internally.

### Migration notes

- `SuperThemeData` no longer owns typography in `super_core 3.3.0`; do not use
  `context.superTheme.textTheme`. Use `context.superTextTheme` or
  `SuperMaterialThemeData.of(context).textTheme`.
- `super_core` no longer infers token font-family metadata from `SuperTextTheme`.
  Configure the type ramp through `SuperTextTheme(bodyFont:, otherFont:)` and
  pass `SuperMaterialThemeData.fontFamily` separately only when a token-level
  override is required.

## 0.12.0 — 2026-08-01

### Added

- Pressing Tab now promotes the visible shadow-hint suffix into the real field
  value before focus traversal, enabling keyboard-first completion for account
  codes, document references, SKUs, and other ERP identifiers.
- Added `completeShadowHintOnTab` (enabled by default) to opt out per field.
- Added widget coverage for Tab completion, second-Tab traversal, and opt-out.

### Behavior

- Shift+Tab is never intercepted by shadow completion.
- When no shadow hint is visible, Tab retains its existing behavior: it invokes
  `onTabNext` when supplied or proceeds with normal focus traversal.
- Accepting the shadow hint completes the text only; it does not fire
  `onSelected` or commit the highlighted suggestion.

## 0.11.0 — 2026-08-01

### Added

- Added inline shadow-hint completion while typing. The untyped remainder of the
  highlighted prefix suggestion is painted inside the editor without changing
  the real text value.
- Added `showShadowHint` (enabled by default) and `shadowHintStyle` for per-field
  control.
- Added support for shadow hints when callers provide an externally owned
  `TextEditingController`; the view mirrors editing state without replacing the
  controller used by `AutoSuggestionsBoxController`.
- Added widget coverage for visual completion, exact-match hiding, and opt-out.

### Behavior

- Shadow hints appear only for enabled single-select fields while focused, with
  a collapsed caret at the end and no active IME composing range.
- The hint is excluded from filtering, `onChanged`, validation, `onSave`, and the
  controller's text. Enter continues to commit the highlighted suggestion.

## 0.10.0 — 2026-08-01

### Added

- Added ERP-oriented text-input configuration to `AutoSuggestionsBox`: `keyboardType`,
  `inputFormatters`, `textDirection`, `textAlign`, `textAlignVertical`,
  `textInputAction`, `textCapitalization`, and `keyboardAppearance`.
- Added field lifecycle callbacks: `onFieldSubmitted`, `onTap`, `onTapOutside`,
  `onTapUpOutside`, `onEditingComplete`, and `onSave`.
- Added exact-entry controls useful for account codes, SKUs, document references,
  IBANs, and voucher numbers: autocorrect/prediction toggles, IME learning, smart
  punctuation, autofill hints, maximum length enforcement, cursor configuration,
  interactive selection, scroll padding/physics, mouse cursor, and focus control.
- Added an ERP document-reference example and a widget test covering keyboard
  configuration, submission, and `FormState.save()`.

### Changed

- Replaced the internal `TextField` with `TextFormField` so the component
  participates in Flutter form-save workflows without changing its existing
  validation badge or suggestion behavior.
- Unified physical Enter and software-keyboard submit handling through the same
  selection/create/free-text pipeline.
- Restored the missing root `pubspec.yaml` and bumped the package to `0.10.0`.

## 0.9.0

- Migrated the package dependency from `super_core` 2.4.0 to 3.0.0.
- Raised the example SDK constraints to Dart 3.8 and Flutter 3.32.
- Replaced removed `SectionCard` usages with `SuperSectionCard`.
- Migrated spacing and radii reads from `SuperTokensData` to
  `context.superTheme.spacing`.
- Updated the example to use `SuperScaffold` for its responsive page frame.
- Simplified theme setup to use `SuperMaterialThemeData.light()` and `.dark()`.

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
  `SuperAutoHybridSuggestionsSource` it documents (it previously constructed the
  progressive fallback source, leaving `SuperAutoHybridSuggestionsSource` as dead code).
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
- **Field-level `theme`** — assign an `AutoSuggestionsBoxThemeData` continues to bridge automatically.
- Removed stale example lock metadata for `super_core` 2.4.0. Run
  `flutter pub get` to regenerate it.
- Removed declarations for package assets that were not present in the source
  archive and were not referenced by the library.

## 0.8.2

- Previous package release.
