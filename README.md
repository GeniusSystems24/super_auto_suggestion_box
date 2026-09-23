# super_auto_suggestion_box

[![Pub](https://img.shields.io/pub/v/super_auto_suggestion_box.svg)](https://pub.dev/packages/super_auto_suggestion_box)
[![style: flutter_lints](https://img.shields.io/badge/style-flutter__lints-blue)](https://pub.dev/packages/flutter_lints)

A Flutter typeahead / combobox for local and remote data with rich suggestion
rows, fuzzy matching, single or multi-select, advanced search, validation,
recents, inline creation, paging, shadow-hint completion, and controller-driven
ERP form workflows.

`SuperAutoSuggestionsBox<T>` keeps domain data as raw `T` values. A
`SuperAutoSuggestionBuilder<T>` converts each value into searchable and
renderable `SuperAutoSuggestionsItem<T>` metadata at the presentation boundary.

Current package version: `1.6.0`.

<details>
  <summary>Table of contents</summary>

- [Features](#features)
- [Getting started](#getting-started)
  - [Install](#install)
  - [Import](#import)
  - [Localization](#localization)
- [Basic usage](#basic-usage)
- [Suggestion builder](#suggestion-builder)
- [Suggestion sources](#suggestion-sources)
  - [Local list](#local-list)
  - [Fuzzy](#fuzzy)
  - [Async](#async)
  - [Hybrid](#hybrid)
  - [Remote fallback](#remote-fallback)
  - [Paged](#paged)
- [Matching strategies](#matching-strategies)
- [Search modes](#search-modes)
- [Multi-select](#multi-select)
- [Recent suggestions](#recent-suggestions)
- [Inline create](#inline-create)
- [Shadow-hint completion](#shadow-hint-completion)
- [Forms and validation](#forms-and-validation)
- [Controller](#controller)
- [Rich and custom rows](#rich-and-custom-rows)
- [Field states and embedding](#field-states-and-embedding)
- [Input configuration](#input-configuration)
- [Theming](#theming)
- [Documentation](#documentation)
- [Changelog](#changelog)
- [Issues](#issues)

</details>

## Features

- Local, asynchronous, hybrid, remote-fallback, and paged suggestion sources.
- `contains`, `prefix`, `words`, and fuzzy matching strategies.
- Relevance-ranked fuzzy results and matched-text highlighting.
- Single-select and multi-select workflows using raw domain values.
- Rich rows with title, description, trailing metadata, icons, groups, keywords,
  enabled state, and custom widgets.
- `BuildContext`-aware `SuperAutoSuggestionBuilder<T>` for theme,
  localization, MediaQuery, and inherited design-system values.
- Inline text-box search, Advanced Search, or both search surfaces.
- Recent suggestions with caller-controlled persistence callbacks.
- Server-side zero-based paging and infinite-scroll support.
- Inline creation for missing values with synchronous or asynchronous creation.
- Shadow-hint completion with keyboard-first Tab acceptance.
- Form integration, required validation, custom validators, and configurable
  validation placement.
- Read-only, disabled, fixed, bare/embed, and record-binding-friendly states.
- Keyboard, focus, formatter, directionality, and text-input configuration for
  ERP identifiers and general text entry.
- English and Arabic package localization, LTR/RTL support, and shared
  GeniusLink theming through `super_core`.

## Getting started

### Install

Add the package to `pubspec.yaml`:

```yaml
dependencies:
  super_auto_suggestion_box: ^1.6.0
```

Then resolve dependencies using your normal Flutter workflow.

### Import

```dart
import 'package:super_auto_suggestion_box/super_auto_suggestion_box.dart';
```

The package barrel exports the suggestion box feature, localization,
`super_form_field` integration types used by the widget, and the shared
`super_core` foundation used by the component.

### Localization

Register the package localization delegate when the package-owned strings should
follow the application's locale:

```dart
MaterialApp(
  localizationsDelegates: const [
    SuperAutoSuggestionLocalization.delegate,
  ],
  supportedLocales: SuperAutoSuggestionLocalization.supportedLocales,
);
```

The package also has a safe English fallback when its delegate is not installed.

## Basic usage

A source and a suggestion builder are required. The source owns raw data; the
builder owns searchable and visual metadata.

```dart
final units = <String>['Each', 'Box', 'Carton'];

SuperAutoSuggestionsItem<String> unitSuggestion(
  BuildContext context,
  List<String> items,
  int index,
  String unit,
) {
  return SuperAutoSuggestionsItem<String>(
    value: unit,
    titleText: unit,
  );
}

SuperAutoSuggestionsBox<String>(
  source: SuperAutoSuggestionSources.list<String>(units),
  suggestionBuilder: unitSuggestion,
  hintText: 'Type or pick...',
  onSelectionChanged: (selected) {
    final value = selected.isEmpty ? null : selected.last;
    debugPrint('Selected: $value');
  },
);
```

A controller is optional. Use one when the host needs imperative selection,
focus, form, recents, query, or paging state.

## Suggestion builder

Since `1.6.0`, the canonical builder is:

```dart
typedef SuperAutoSuggestionBuilder<T> =
    SuperAutoSuggestionsItem<T> Function(
      BuildContext context,
      List<T> items,
      int index,
      T element,
    );
```

The active `BuildContext` can safely read inherited presentation values:

```dart
SuperAutoSuggestionsItem<Account> accountSuggestion(
  BuildContext context,
  List<Account> items,
  int index,
  Account account,
) {
  final colors = Theme.of(context).colorScheme;

  return SuperAutoSuggestionsItem<Account>(
    value: account,
    titleText: account.name,
    descriptionText: account.code,
    trailingText: account.balanceText,
    icon: Icon(Icons.account_balance_outlined, color: colors.primary),
    keywords: [account.code],
  );
}
```

`titleText` is the canonical searchable, displayed, and committed title.
`keywords` extend the searchable haystack without changing the visible title.

## Suggestion sources

Use `SuperAutoSuggestionSources` for normal source construction.

| Factory | Use case | Concrete source |
| --- | --- | --- |
| `list` | In-memory data | `SuperAutoListSuggestionsSource<T>` |
| `strings` | In-memory `String` values | `SuperAutoListSuggestionsSource<String>` |
| `fuzzy` | Ranked fuzzy in-memory search | `SuperAutoListSuggestionsSource<T>` |
| `async` | Remote or repository search | `SuperAutoAsyncSuggestionsSource<T>` |
| `hybrid` | Local results plus remote expansion | `SuperAutoHybridSuggestionsSource<T>` |
| `remoteFallback` | Local-first search with sparse-result fallback | `SuperAutoRemoteFallbackSuggestionsSource<T>` |
| `paged` | Server-side paging / infinite scroll | `SuperAutoPagedSuggestionsSource<T>` |

### Local list

```dart
final source = SuperAutoSuggestionSources.list<Account>(
  accounts,
  match: AutoSuggestionMatch.contains,
  caseSensitive: false,
);
```

For plain strings:

```dart
final source = SuperAutoSuggestionSources.strings(
  ['Aden', 'Amman', 'Cairo', 'Dubai'],
  match: AutoSuggestionMatch.prefix,
);
```

The widget still receives a `suggestionBuilder`, including when `strings()` is
used.

### Fuzzy

```dart
final source = SuperAutoSuggestionSources.fuzzy<Account>(accounts);
```

Fuzzy results are ranked by match quality rather than preserving only insertion
order.

### Async

```dart
final source = SuperAutoSuggestionSources.async<Account>(
  (query) => repository.searchAccounts(query),
  initialItems: initiallyKnownAccounts,
);

SuperAutoSuggestionsBox<Account>(
  source: source,
  suggestionBuilder: accountSuggestion,
  debounce: const Duration(milliseconds: 300),
);
```

`initialItems` seed value resolution; they are not automatically returned as the
result of every async query.

### Hybrid

Hybrid search always lets local matches contribute to the final result and
fetches remotely when the local result count is below the configured threshold.

```dart
final source = SuperAutoSuggestionSources.hybrid<Account>(
  initialItems: recentAccounts,
  fetch: repository.searchAccounts,
  remoteThreshold: 3,
  remoteMinChars: 2,
);
```

The remote condition is `localMatches.length < remoteThreshold`.

### Remote fallback

Use `remoteFallback` when remote data should primarily extend sparse local
results:

```dart
final source = SuperAutoSuggestionSources.remoteFallback<Account>(
  initialItems: recentAccounts,
  fetch: repository.searchAccounts,
  remoteThreshold: 5,
  remoteMinChars: 2,
);
```

The remote condition is inclusive:
`localMatches.length <= remoteThreshold`.

### Paged

The page callback uses zero-based page indexes. Page `0` is the first page.

```dart
final source = SuperAutoSuggestionSources.paged<Account>(
  (query, page) async {
    final response = await repository.searchAccountsPage(
      query: query,
      page: page,
    );

    return SuperSuggestionsPage<Account>(
      items: response.items,
      hasMore: response.hasMore,
    );
  },
  resolveFrom: initiallySelectedAccounts,
);
```

Fetched pages are retained for value resolution. The paged source does not
de-duplicate rows across pages, so APIs that can repeat rows should be
normalized in the repository or fetch callback.

## Matching strategies

`AutoSuggestionMatch` supports:

| Strategy | Behavior |
| --- | --- |
| `contains` | Query appears anywhere in the searchable text. |
| `prefix` | Searchable text starts with the query. |
| `words` | Every whitespace-separated query token must appear. |
| `fuzzy` | Query characters appear in order with gaps allowed. |

Example:

```dart
final source = SuperAutoSuggestionSources.list<Account>(
  accounts,
  match: AutoSuggestionMatch.words,
);
```

Use the box's `highlightMatch` and `highlightMatches` options to control row
highlighting behavior.

## Search modes

`SuperAutoSuggestionsMode` controls which search surface is exposed:

- `textBox`: editable field with anchored suggestions.
- `advanceView`: field-like launcher for the Advanced Search view.
- `both`: editable field plus Advanced Search access.

```dart
SuperAutoSuggestionsBox<Account>(
  source: source,
  suggestionBuilder: accountSuggestion,
  mode: SuperAutoSuggestionsMode.both,
);
```

When `mode` is omitted, desktop platforms default to `textBox`; Android, iOS,
and Fuchsia default to `advanceView`.

A custom Advanced Search surface can be supplied with `advancedSearchBuilder`.

## Multi-select

Initial selected values belong to the controller. Multi-select behavior belongs
to the widget.

```dart
final controller = SuperAutoSuggestionsController<Account>(
  initialSelected: initialAccounts,
);

SuperAutoSuggestionsBox<Account>(
  controller: controller,
  source: source,
  suggestionBuilder: accountSuggestion,
  multiSelect: true,
  onSelectionChanged: (selected) {
    debugPrint('Selected ${selected.length} accounts');
  },
);
```

Read the current values from `controller.selectedItems`.

## Recent suggestions

```dart
SuperAutoSuggestionsBox<Account>(
  source: source,
  suggestionBuilder: accountSuggestion,
  showRecents: true,
  maxRecents: 8,
  initialRecents: persistedRecents,
  onRecentsChanged: persistRecents,
);
```

Recents are most-recent-first. The package owns runtime ordering while the host
can persist changes through `onRecentsChanged`.

## Inline create

When `onCreate` is set and a non-empty query has no match, the component can
show a create action in both inline and Advanced Search surfaces.

```dart
SuperAutoSuggestionsBox<Account>(
  source: source,
  suggestionBuilder: accountSuggestion,
  onCreate: (query) async {
    return repository.createAccount(name: query);
  },
  createLabelBuilder: (query) => 'Create "$query"',
);
```

Return the created raw `T` to commit it, or `null` to cancel creation.

## Shadow-hint completion

Shadow hints render the untyped suffix of the highlighted prefix match without
changing the actual editable value.

```dart
SuperAutoSuggestionsBox<String>(
  source: source,
  suggestionBuilder: referenceSuggestion,
  showShadowHint: true,
  completeShadowHintOnTab: true,
);
```

Forward Tab accepts a visible shadow hint. Shift+Tab keeps reverse focus
traversal. If no shadow hint is visible, Tab keeps normal focus traversal or
uses `onTabNext` when supplied.

## Forms and validation

`SuperAutoSuggestionsBox<T>` participates in Flutter forms with the committed
raw `T?` value.

```dart
final formKey = GlobalKey<FormState>();
final fieldKey = GlobalKey<FormFieldState<Account>>();

final controller = SuperAutoSuggestionsController<Account>(
  formFieldKey: fieldKey,
);

Form(
  key: formKey,
  child: SuperAutoSuggestionsBox<Account>(
    controller: controller,
    source: source,
    suggestionBuilder: accountSuggestion,
    required: true,
    validator: (account) {
      if (account != null && account.isBlocked) {
        return 'Blocked accounts cannot be selected';
      }
      return null;
    },
    autovalidateMode: AutovalidateMode.onUserInteraction,
    validationPosition: ValidationPosition.underBox,
  ),
);
```

Validation is selection-driven. Use `FormState.validate()` for form-level
validation and controller state for the selected value.

If `autovalidateMode` is omitted, the field inherits the nearest Form setting
and otherwise defaults to `AutovalidateMode.disabled`.

## Controller

Create a `SuperAutoSuggestionsController<T>` when the host needs direct state
or commands:

```dart
final controller = SuperAutoSuggestionsController<Account>(
  initialValue: initialAccount,
  allowFreeText: false,
  focusNode: accountFocusNode,
);
```

Common reads:

```dart
controller.query;
controller.results;
controller.suggestions;
controller.selected;
controller.selectedItems;
controller.recents;
controller.isOpen;
controller.isLoading;
controller.isLoadingMore;
controller.isPaged;
controller.hasMore;
controller.error;
```

Common commands:

```dart
controller.open();
controller.close();
controller.toggle();
controller.setText('1001');
controller.refresh();
controller.selectByValue(account);
controller.setSelectedItems(accounts);
controller.clearSelection();
controller.setRecents(accounts);
controller.clearRecents();
controller.loadNextPage();
controller.clear();
```

The widget owns the source, builder, query timing, recents configuration,
result limit, and multi-select configuration; the controller is the runtime
state/command surface.

## Rich and custom rows

Use `SuperAutoSuggestionsItem<T>` for default rich rows:

```dart
SuperAutoSuggestionsItem<Account>(
  value: account,
  titleText: account.name,
  descriptionText: account.code,
  trailingText: account.balanceText,
  group: account.typeLabel,
  iconData: Icons.account_balance_outlined,
  keywords: [account.code, account.alias],
  enabled: account.isActive,
);
```

Custom supporting widgets can be supplied directly:

```dart
SuperAutoSuggestionsItem<Account>(
  value: account,
  titleText: account.name,
  description: Text(account.code),
  trailing: Chip(label: Text(account.statusLabel)),
  icon: const Icon(Icons.account_balance_outlined),
);
```

For complete row control, use `itemBuilder`:

```dart
SuperAutoSuggestionsBox<Account>(
  source: source,
  suggestionBuilder: accountSuggestion,
  itemBuilder: (context, account, suggestion, highlighted) {
    return ListTile(
      selected: highlighted,
      title: Text(suggestion.displayText),
      subtitle: Text(account.code),
    );
  },
);
```

Other presentation hooks include `emptyBuilder` and `loadingBuilder`.

## Field states and embedding

The box supports several distinct states:

- `enabled: false`: disables the standard field interaction.
- `disabled: true`: dims the field and suppresses interaction and validation.
- `readOnly: true`: keeps normal contrast while blocking editing and opening.
- `allowFixed: true`: exposes a lock/unlock action backed by
  `controller.isFixed`.
- `bare: true`: removes the outer border/fill and tightens padding for embedded
  surfaces such as editable table cells.

Keyboard-oriented embedders can use `onEscape`, `onTabNext`, and `onTabPrev`.
Use `restoreOnBlur` to control whether uncommitted typing reverts to the last
committed selection.

## Input configuration

The widget exposes Flutter text-input controls needed for ERP and structured
identifiers, including:

- `keyboardType`, `textInputAction`, and `textCapitalization`.
- `inputFormatters`, `maxLength`, and `maxLengthEnforcement`.
- `textDirection`, `textAlign`, and `textAlignVertical`.
- `autocorrect`, `enableSuggestions`, and `enableIMEPersonalizedLearning`.
- `autofillHints`, smart dashes/quotes, cursor options, and selection controls.
- `focusNode`, `autofocus`, `canRequestFocus`, and `scrollOnFocus`.

Example for an exact numeric account code:

```dart
SuperAutoSuggestionsBox<Account>(
  source: source,
  suggestionBuilder: accountSuggestion,
  keyboardType: TextInputType.number,
  enableSuggestions: false,
  autocorrect: false,
  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
  textDirection: TextDirection.ltr,
);
```

## Theming

Use `SuperAutoSuggestionsBoxThemeData` for component styling and
`SuperAutoSuggestionsBoxFocusedStyle` for focused-state overrides.

A field-level theme can override the ambient package theme:

```dart
SuperAutoSuggestionsBox<Account>(
  source: source,
  suggestionBuilder: accountSuggestion,
  theme: SuperAutoSuggestionsBoxThemeData.light.copyWith(
    borderFocus: Colors.indigo,
  ),
);
```

The package integrates with the shared GeniusLink design-system foundation from
`super_core`, including light/dark themes, spacing, typography, and RTL-aware
presentation.

## Documentation

- [Package API documentation](https://pub.dev/documentation/super_auto_suggestion_box/latest/)
- [Package on pub.dev](https://pub.dev/packages/super_auto_suggestion_box)
- [Example / project site](https://geniussystems24.github.io/super_auto_suggestion_box)
- [Source repository](https://github.com/GeniusSystems24/super_auto_suggestion_box)

The `example/` application contains runnable scenarios for local and remote
search, Advanced Search modes, validation placement, autovalidation, rich rows,
and newer package behavior.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for new features, fixes, and breaking changes.

## Issues

Use the [GitHub issue tracker](https://github.com/GeniusSystems24/super_auto_suggestion_box/issues) for bug reports and feature requests.
