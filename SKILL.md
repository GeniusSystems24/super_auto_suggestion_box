---
name: super-auto-suggestion-box
description: >
  Use the super_auto_suggestion_box Flutter package to build GeniusLink
  design-system typeahead / combobox inputs — AutoSuggestionsBox: local + remote
  suggestion sources, prefix/contains/words/fuzzy-ranked matching, inline shadow
  hint completion, single- and
  multi-select, free-text entry, a local-first progressive remoteFallback source,
  server-side paged infinite-scroll, recently-used suggestions, inline create, a
  trailing meta column, record binding + a read-only view mode, an advanced-search
  overlay, controller-driven fix/hide/focus/form wiring, a bare embedding mode,
  required + validator field validation, a
  disabled state, and per-field theming with a focused-state style. Apply when a
  Flutter app needs a themed (light/dark, LTR/RTL) typeahead/autocomplete field,
  or an embeddable pick-or-type combobox. This package also carries the shared
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
  super_auto_suggestion_box: ^0.14.0
```

```dart
import 'package:super_auto_suggestion_box/super_auto_suggestion_box.dart';
```

Use `super_core >=3.3.0` and build the app theme with explicit
`SuperTextTheme` values:

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

`AutoSuggestionsBoxThemeData.of(context)` automatically derives component colors
from the active `SuperMaterialThemeData`; register an explicit
`AutoSuggestionsBoxThemeData` extension only when overriding the component.

### super_core 3.3.0 typography rules

- `SuperThemeData` does **not** expose `textTheme`; never generate
  `context.superTheme.textTheme`, `theme.superTheme.textTheme`, or
  `SuperThemeData.of(context).textTheme`.
- Read branded typography with `context.superTextTheme`, or from
  `SuperMaterialThemeData.of(context).textTheme`.
- `SuperMaterialThemeData.light` and `.dark` require both `textTheme` and
  `primaryTextTheme`, each a `SuperTextTheme`.
- Configure custom body/display families through `SuperTextTheme(bodyFont:,
  otherFont:)`. Do not rely on `SuperMaterialThemeData` to infer a font family
  from the text theme. Pass its `fontFamily` only when token-level font metadata
  also needs an explicit override.
- `AutoSuggestionsBox` follows the ambient `SuperTextTheme` font families; do not
  hard-code `AutoSuggestionsBoxThemeData.bodyFont` / `displayFont` in new code.

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

### Validation, disabled & theming (0.6.0)

The field matches `super_form_field` (height, layout, states) and adds:

- `required: true` — red `*` on the label + implicit required rule
  (`requiredMessage` to customise; multi-select fails while nothing is chosen).
- `validator: (String value) => error?` — custom rule. Errors surface through a
  **suffix error badge tooltip** (never inline), silent until first blur or
  `forceError: true`; `onValidity` reports the current error.
- `disabled: true` — dims to 55 %, blocks typing / overlay, suppresses errors.
- `theme:` — an `AutoSuggestionsBoxThemeData` assigned to one box, overriding the
  ambient extension.
- `focusedStyle` on `AutoSuggestionsBoxThemeData` — an
  `AutoSuggestionsBoxFocusedStyle(fillColor, border, fontStyle, cursorColor,
  shadow)`; each field is optional and falls back to the resting token.
- `decoration: InputDecoration(labelText:, helperText:, hintText:, prefixIcon:)`
  for field copy and its leading icon (`label`, `hint`, and `leading` are
  deprecated), plus `density:`
  (`FieldDensity.comfortable` / `.compact`).

```dart
AutoSuggestionsBox<String>(
  items: accounts,
  decoration: const InputDecoration(
    labelText: 'Debit Account',
    helperText: 'Pick an account from the chart',
    prefixIcon: Icon(Icons.account_balance_outlined),
  ),
  required: true,
  validator: (v) => v.isEmpty || accounts.any((a) => a.label == v)
      ? null
      : 'Pick an account from the list',
  onValidity: (err) => setState(() => _error = err),
  theme: AutoSuggestionsBoxThemeData.of(context).copyWith(
    focusedStyle: const AutoSuggestionsBoxFocusedStyle(
      border: BorderSide(color: Color(0xFF1DB88A), width: 1.6),
      fontStyle: TextStyle(fontWeight: FontWeight.w600),
    ),
  ),
);
```

### Suggestion sources

`SuggestionSources.list(...)` / `.strings(...)` (static), `.fuzzy(...)`
(fuzzy-ranked by match quality), `.async(...)` (debounced remote),
`.hybrid(...)` (single-phase local-first merge), `.remoteFallback(...)`
(local-first progressive), and `.paged(fetch)` (infinite scroll). Prefer
**`remoteFallback`** for “mostly local, occasionally remote” data: it shows local
matches instantly and only calls `fetch` when local matches ≤ `remoteThreshold`,
merging remote rows in behind a *loading more* indicator (`controller.isLoadingMore`).
Use `.async` for purely-remote search, and **`.paged`** when a single response
would be too large — it serves one `SuggestionsPage(items, hasMore)` per
`(query, page)` and the overlay auto-appends the next page on scroll
(`controller.hasMore` / `isLoadingPage` / `loadNextPage()`).

### ERP features (0.7.0)

- **Recents** — build the controller with `showRecents: true` (+ `maxRecents`,
  `initialRecents`, `onRecentsChanged`) so recent picks pin to a *Recent* section
  on the empty field. The single biggest data-entry accelerator; persist the list
  via `onRecentsChanged` and restore it with `initialRecents`.
- **Inline create** — `onCreate: (query) => FutureOr<AutoSuggestion?>` shows a
  “＋ Create …” action when nothing matches (Enter triggers it before a free-text
  submit; a spinner shows while it resolves). Return the new row to commit it.
- **Trailing meta** — set `AutoSuggestion.trailing` for a right-aligned mono value
  (balance / on-hand qty / price) so rows read as code · name · amount.
- **Record binding** — `controller.selectByValue(id)` resolves a stored id back to
  its full row (via the source’s `resolve`) and commits it — for a form bound to a
  record. Works for `list` / `hybrid` / `remoteFallback` sources and `paged`
  (pass `resolveFrom:` the already-loaded rows).
- **Read-only** — `readOnly: true` shows the value at full contrast but blocks
  typing / overlay / clear (the “posted / review” state). Distinct from `disabled`,
  which dims to 55 %.
- **Fixable field** — construct the controller with `isFixed`, `focusNode`,
  `formFieldKey`, or `isHiden`, and set `allowFixed: true` on the widget to show a
  small lock/unlock action at the trailing edge of its label. Fixed fields keep
  full contrast while blocking user edits and controller mutations. `allowFixed`
  only exposes the action; `controller.isFixed` remains the source of truth.

### Shadow hint completion (0.12.0)

`showShadowHint` defaults to `true`. While the field is focused and the caret is
at the end, the untyped remainder of the highlighted prefix match is painted in a
faint style inside the editor. It is visual only and never changes the controller
value, validation, callbacks, or saved form value. Use `shadowHintStyle` for a
per-field appearance override and `showShadowHint: false` when exact-entry forms
must not expose inline completion. Tab promotes the visible suffix into the real
text by default; disable that behavior with `completeShadowHintOnTab: false`.
Shift+Tab always keeps reverse focus traversal, and Enter still commits the
highlighted row.

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
- Surfacing validation as inline text — it only shows through the suffix error
  badge tooltip; a `hint` is hidden while an error is present.
- Recreating a controller inside `build` for a pre-filled `disabled` field —
  hold it as a `late final` (or state) field and dispose it, or use `items`.
- Enabling **recents** via the `items`/`source` shorthand → recents live on the
  controller, so build an `AutoSuggestionsBoxController(showRecents: true, …)` and
  pass it as `controller:`.
- Using `.async` (or a huge `items` list) for very large master data → prefer
  `.paged` so rows stream in a page at a time as the user scrolls.
- Confusing `readOnly` with `disabled` — `readOnly` is a full-contrast view state
  (blocks editing only); `disabled` dims to 55 % and suppresses validation.
- Expecting `allowFixed` to own fixed state — it only renders the label action;
  read and update `controller.isFixed.value`. After changing the plain boolean
  `controller.isHiden`, rebuild the host so visibility is reevaluated.
- Generating new code with deprecated `label:` or `hint:` — use
  `decoration: const InputDecoration(labelText:, helperText:)`. Use
  `InputDecoration.hintText` for placeholder copy.
- Generating `leading:` — put the widget in `InputDecoration.prefixIcon` instead.
