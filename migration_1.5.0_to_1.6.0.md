# Migration: 1.5.0 to 1.6.0

Version 1.6.0 changes the suggestion-builder API so row metadata can use the
active Flutter `BuildContext`.

## Removed deprecated constructor fields

Version `1.6.0` no longer includes the deprecated
`SuperAutoSuggestionsBox` constructor fields that were retained temporarily
for backward compatibility.

| Removed field | Replacement |
| --- | --- |
| `label` | `decoration: InputDecoration(labelText: ...)` |
| `leading` | `decoration: InputDecoration(prefixIcon: ...)` |
| `hint` | `decoration: InputDecoration(helperText: ...)` |
| `advancedSearch` | `mode: SuperAutoSuggestionsMode.both` |

Before:

```dart
SuperAutoSuggestionsBox<String>(
  source: SuperAutoSuggestionSources.list<String>(items),
  suggestionBuilder: suggestionBuilder,
  label: 'Account',
  leading: const Icon(Icons.account_balance_outlined),
  hint: 'Choose an account',
  advancedSearch: true,
);
```

After:

```dart
SuperAutoSuggestionsBox<String>(
  source: SuperAutoSuggestionSources.list<String>(items),
  suggestionBuilder: suggestionBuilder,
  decoration: const InputDecoration(
    labelText: 'Account',
    prefixIcon: Icon(Icons.account_balance_outlined),
    helperText: 'Choose an account',
  ),
  mode: SuperAutoSuggestionsMode.both,
);
```

These compatibility fields are removed rather than merely deprecated in
`1.6.0`, so applications still using them must migrate before upgrading.

## Builder rename

`AutoSuggestionBuilder<T>` has been renamed to
`SuperAutoSuggestionBuilder<T>`.

Before:

```dart
final AutoSuggestionBuilder<Account> accountBuilder = (
  items,
  index,
  account,
) => SuperAutoSuggestionsItem<Account>(
  value: account,
  titleText: account.name,
);
```

After:

```dart
final SuperAutoSuggestionBuilder<Account> accountBuilder = (
  context,
  items,
  index,
  account,
) => SuperAutoSuggestionsItem<Account>(
  value: account,
  titleText: account.name,
);
```

## Function signature

Every builder now receives `BuildContext` as its first parameter.

Before:

```dart
SuperAutoSuggestionsItem<Account> accountSuggestion(
  List<Account> items,
  int index,
  Account account,
) {
  return SuperAutoSuggestionsItem<Account>(
    value: account,
    titleText: account.name,
  );
}
```

After:

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
    icon: Icon(Icons.account_balance_outlined, color: colors.primary),
  );
}
```

`SuperAutoSuggestionsBox` usage remains otherwise unchanged:

```dart
SuperAutoSuggestionsBox<Account>(
  source: SuperAutoSuggestionSources.list<Account>(accounts),
  suggestionBuilder: accountSuggestion,
  onSelectionChanged: (selected) {},
);
```

## Inline builders

Before:

```dart
suggestionBuilder: (items, index, element) =>
    SuperAutoSuggestionsItem<String>(
      value: element,
      titleText: element,
    ),
```

After:

```dart
suggestionBuilder: (context, items, index, element) =>
    SuperAutoSuggestionsItem<String>(
      value: element,
      titleText: element,
    ),
```

## Why BuildContext was added

The builder creates presentation metadata and may now safely derive widgets or
styles from the active widget tree, for example:

```dart
SuperAutoSuggestionsItem<Product> productSuggestion(
  BuildContext context,
  List<Product> items,
  int index,
  Product product,
) {
  final theme = Theme.of(context);

  return SuperAutoSuggestionsItem<Product>(
    value: product,
    titleText: product.name,
    trailing: Text(
      product.priceLabel,
      style: theme.textTheme.labelMedium,
    ),
  );
}
```

The package binds the builder from `didChangeDependencies`, so inherited
lookups such as `Theme.of(context)`, localization, MediaQuery, and theme
extensions are valid when the builder is evaluated.

## Migration checklist

1. Replace removed `label`, `leading`, and `hint` fields with the corresponding
   `InputDecoration` properties.
2. Replace removed `advancedSearch` usage with the appropriate
   `SuperAutoSuggestionsMode` value, typically `SuperAutoSuggestionsMode.both`.
3. Rename explicit `AutoSuggestionBuilder<T>` type annotations to
   `SuperAutoSuggestionBuilder<T>`.
4. Add `BuildContext context` as the first parameter of named suggestion
   builder functions.
5. Add `context` as the first parameter of inline `suggestionBuilder` lambdas.
6. Keep passing the builder through `SuperAutoSuggestionsBox.suggestionBuilder`.
7. Use the new context parameter only for presentation/inherited-tree needs;
   keep raw source data and query callbacks independent from UI context.
