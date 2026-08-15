# Migration Guide: 1.0.0 to 1.1.0

Version `1.1.0` gives the widget, controller, and suggestion item consistent
`Super`-prefixed names. It also moves all suggestion data and presentation
configuration to `SuperAutoSuggestionsBox`.

## 1. Rename the widget and suggestion item

Replace `AutoSuggestionsBox<T>` with `SuperAutoSuggestionsBox<T>` and use
`SuperAutoSuggestionsItem<T>` for the metadata returned by a
`suggestionBuilder`:

```dart
SuperAutoSuggestionsItem<String> accountSuggestion(
  List<String> items,
  int index,
  String account,
) => SuperAutoSuggestionsItem(value: account, titleText: account);

SuperAutoSuggestionsBox<String>(
  source: SuggestionSources.list<String>(accounts),
  suggestionBuilder: accountSuggestion,
);
```

The deprecated `AutoSuggestionsBox<T>`, `AutoSuggestions<T>`, and
`AutoSuggestion<T>` typedefs are available as temporary migration aliases.

Suggestion metadata fields are also renamed:

| 1.0.0 | 1.1.0 |
| --- | --- |
| `label` | `titleText` |
| `description` | `descriptionText` |
| `trailing` | `trailingText` |
| `icon` | `iconData` |

Source declarations should use `SuperAutoSuggestionsSource<T>` instead of
`AutoSuggestionsSource<T>`. The old source name remains available as a
deprecated typedef during migration.

Paged sources now return `SuperSuggestionsPage<T>`. The previous
`SuggestionsPage<T>` name remains available as a deprecated typedef.

Use the default `SuperAutoSuggestionsItem` constructor for strings and icon
data. Use `SuperAutoSuggestionsItem.build` when a row needs custom widgets:

```dart
SuperAutoSuggestionsItem<String>.build(
  value: account,
  title: Text(account.name),
  description: Text(account.code),
  trailing: StatusBadge(account.status),
  icon: const Icon(Icons.account_balance_outlined),
);
```

Widget-built rows use `value.toString()` for matching and field completion
because arbitrary widgets do not expose searchable text. Add `keywords` when
additional search terms are required.

## 2. Rename the controller

Replace `AutoSuggestionsBoxController<T>` with
`SuperAutoSuggestionsController<T>`:

```dart
// 1.0.0
final controller = AutoSuggestionsBoxController<String>(
  source: SuggestionSources.list(accounts),
);

// 1.1.0
final controller = SuperAutoSuggestionsController<String>();
```

The old name remains as a deprecated typedef, so existing declarations continue
to compile while you migrate.

## 3. Move the source to the widget

`SuperAutoSuggestionsController` does not accept or expose `source`. Supply
the required `source` to `SuperAutoSuggestionsBox` instead:

```dart
final source = SuggestionSources.list<String>(accounts);
final controller = SuperAutoSuggestionsController<String>(
  initialValue: '1020',
);

SuperAutoSuggestionsBox<String>(
  controller: controller,
  source: source,
  suggestionBuilder: accountSuggestion,
);
```

For a local list, create a list source explicitly:

```dart
SuperAutoSuggestionsBox<String>(
  controller: controller,
  source: SuggestionSources.list<String>(accounts),
  suggestionBuilder: accountSuggestion,
);
```

## 4. Keep `suggestionBuilder` on the widget

The controller has no `suggestionBuilder` parameter or property. Continue to
provide it directly to every `SuperAutoSuggestionsBox`:

```dart
SuperAutoSuggestionsBox<String>(
  controller: controller,
  source: SuggestionSources.list<String>(accounts),
  suggestionBuilder: (items, index, account) => SuperAutoSuggestionsItem(
    value: account,
    titleText: account,
  ),
);
```

The widget binds its source and builder to the controller internally. Initial
values are resolved when the controller is attached to the widget.

## 5. Replace `initialText`

The controller no longer accepts `initialText`. For an initial free-text value,
provide a `TextEditingController` instead:

```dart
final controller = SuperAutoSuggestionsController<String>(
  textController: TextEditingController(text: 'Opening text'),
);
```

Continue to use `initialValue` when the initial value represents an item from
the widget's source.

## 6. Move query and selection configuration to the widget

The following options now belong to `SuperAutoSuggestionsBox`: `debounce`,
`minChars`, `maxResults`, `multiSelect`, `showRecents`, `maxRecents`,
`initialRecents`, `recentsGroupLabel`, and `onRecentsChanged`.

```dart
final controller = SuperAutoSuggestionsController<String>();

SuperAutoSuggestionsBox<String>(
  controller: controller,
  source: SuggestionSources.list<String>(accounts),
  suggestionBuilder: accountSuggestion,
  debounce: const Duration(milliseconds: 250),
  minChars: 2,
  maxResults: 20,
  multiSelect: true,
  showRecents: true,
  maxRecents: 4,
  initialRecents: const ['1020'],
  recentsGroupLabel: 'Recently used',
  onRecentsChanged: saveRecentAccounts,
);
```

## 7. Provide a source and move `initialSelected`

`source` is now required on every `SuperAutoSuggestionsBox`; the `items`
shorthand has been removed. Wrap local values with `SuggestionSources.list`.
The `initialSelected` option now belongs only to the controller:

```dart
final controller = SuperAutoSuggestionsController<String>(
  initialSelected: const ['1010'],
);

SuperAutoSuggestionsBox<String>(
  controller: controller,
  source: SuggestionSources.list<String>(accounts),
  suggestionBuilder: accountSuggestion,
  multiSelect: true,
);
```
