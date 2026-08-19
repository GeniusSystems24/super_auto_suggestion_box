# Migration Guide: 1.2.0 to 1.3.0

`super_auto_suggestion_box` 1.3.0 consolidates suggestion-row construction and
finishes the `Super` prefix migration for public classes in
`presentation/widgets`.

## 1. SuperAutoSuggestionsItem.build was removed

In 1.2.0, widget-based row content used a separate named constructor:

```dart
SuperAutoSuggestionsItem<String>.build(
  value: code,
  title: Text(label),
  description: Text(description),
  trailing: Chip(label: Text(status)),
  icon: const Icon(Icons.account_balance_outlined),
);
```

In 1.3.0, use the normal constructor. The title is always supplied through
`titleText`; custom widgets remain available for description, trailing content,
and icon:

```dart
SuperAutoSuggestionsItem<String>(
  value: code,
  titleText: label,
  description: Text(description),
  trailing: Chip(label: Text(status)),
  icon: const Icon(Icons.account_balance_outlined),
);
```

The custom `title` widget field no longer exists. `titleText` is the canonical
searchable, display, and field-completion title.

The existing metadata alternatives remain valid:

```dart
SuperAutoSuggestionsItem<String>(
  value: code,
  titleText: label,
  descriptionText: description,
  trailingText: status,
  iconData: Icons.account_balance_outlined,
);
```

## 2. enabledSnapshot

`SuperAutoSuggestionsItem` now exposes an optional `Stream? enabledSnapshot`
field:

```dart
SuperAutoSuggestionsItem<String>(
  value: code,
  titleText: label,
  enabled: true,
  enabledSnapshot: enabledStream,
);
```

`enabled` remains available for the immediate boolean state.

## 3. Public widget classes now use the Super prefix

Use the new canonical names:

| 1.2.x name | 1.3.0 canonical name |
| --- | --- |
| `AutoSuggestionsBoxFocusedStyle` | `SuperAutoSuggestionsBoxFocusedStyle` |
| `AutoSuggestionsBoxThemeData` | `SuperAutoSuggestionsBoxThemeData` |
| `AutoSuggestionsHighlight` | `SuperAutoSuggestionsHighlight` |
| `AutoSuggestionsPanel<T>` | `SuperAutoSuggestionsPanel<T>` |

Deprecated typedef aliases are retained for the 1.2.x names.

Example:

```dart
SuperAutoSuggestionsBox<String>(
  source: SuperAutoSuggestionSources.list<String>(accounts),
  suggestionBuilder: accountSuggestion,
  theme: SuperAutoSuggestionsBoxThemeData.of(context).copyWith(
    focusedStyle: const SuperAutoSuggestionsBoxFocusedStyle(
      fontStyle: TextStyle(fontWeight: FontWeight.w600),
    ),
  ),
);
```

## 4. Package version

Update the dependency:

```yaml
dependencies:
  super_auto_suggestion_box: ^1.3.0
```
