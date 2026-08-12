# Migration Guide: 0.14.0 to 1.0.0

Version `1.0.0` changes `super_auto_suggestion_box` to use raw `T` values at
the public API boundary. `AutoSuggestion<T>` is still public, but callers now
create it only inside `suggestionBuilder`.

## 1. Add `suggestionBuilder`

Every `AutoSuggestionsBox` needs:

```dart
AutoSuggestion<T> suggestionBuilder(
  List<T> items,
  int index,
  T element,
)
```

Example:

```dart
AutoSuggestion<String> accountSuggestion(
  List<String> items,
  int index,
  String code,
) => AutoSuggestion<String>(
  value: code,
  label: accountLabels[code] ?? code,
  description: 'Account $code',
  keywords: [code],
);
```

## 2. Data Sources

Before:

```dart
final source = SuggestionSources.list<String>([
  AutoSuggestion(value: '1010', label: 'Cash on Hand'),
  AutoSuggestion(value: '1020', label: 'Bank - Operating'),
]);
```

After:

```dart
final source = SuggestionSources.list<String>(['1010', '1020']);
```

Fuzzy sources follow the same pattern:

```dart
final source = SuggestionSources.fuzzy<String>(['RUH', 'JED', 'DMM']);
```

`SuggestionSources.strings(values)` remains the convenience API when each raw
string is also the label. No `SuggestionSources.*` factory accepts
`suggestionBuilder` in `1.0.0`; the widget owns it.

## 3. `initialItems`

Before:

```dart
SuggestionSources.hybrid<String>(
  initialItems: [
    AutoSuggestion(value: '1010', label: 'Cash on Hand'),
  ],
  fetch: searchAccounts,
);
```

After:

```dart
SuggestionSources.hybrid<String>(
  initialItems: ['1010'],
  fetch: searchAccounts,
);
```

The same change applies to `async(initialItems:)` and
`remoteFallback(initialItems:)`.

## 4. Fetch Callbacks

Fetch callbacks return raw values.

Before:

```dart
Future<List<AutoSuggestion<String>>> searchAccounts(String query) async {
  final rows = await api.search(query);
  return [
    for (final row in rows)
      AutoSuggestion(value: row.code, label: row.name),
  ];
}
```

After:

```dart
Future<List<String>> searchAccounts(String query) async {
  final rows = await api.search(query);
  return [for (final row in rows) row.code];
}
```

Paged sources now return raw page items:

```dart
SuggestionSources.paged<String>(
  (query, page) async {
    final response = await api.searchPage(query, page);
    return SuggestionsPage<String>(
      items: response.codes,
      hasMore: response.hasMore,
    );
  },
  resolveFrom: knownAccountCodes,
);
```

## 5. Controllers

Controller selection and collection APIs are raw.

Before:

```dart
final controller = AutoSuggestionsBoxController<String>(
  source: source,
  initialValue: AutoSuggestion(value: '1020', label: 'Bank - Operating'),
  initialSelected: [
    AutoSuggestion(value: '1010', label: 'Cash on Hand'),
  ],
  initialRecents: [
    AutoSuggestion(value: '4000', label: 'Sales Revenue'),
  ],
);

controller.selected?.value;
controller.results.first.label;
controller.setSelectedItems([
  AutoSuggestion(value: '1010', label: 'Cash on Hand'),
]);
```

After:

```dart
final controller = AutoSuggestionsBoxController<String>(
  source: source,
  initialValue: '1020',
  initialSelected: const ['1010'],
  initialRecents: const ['4000'],
);

controller.selected;       // String?
controller.results.first;  // String
controller.setSelectedItems(['1010']);
```

Attach the controller to a widget with `suggestionBuilder`:

```dart
AutoSuggestionsBox<String>(
  controller: controller,
  suggestionBuilder: accountSuggestion,
);
```

After the controller is attached to an `AutoSuggestionsBox`, use metadata
accessors when UI code needs labels or descriptions:

```dart
controller.selectedSuggestion?.label;
controller.suggestions.first.label;
controller.suggestionAt(0).description;
controller.highlightedSuggestion;
```

## 6. `AutoSuggestionsBox`

Before:

```dart
AutoSuggestionsBox<String>(
  items: [
    AutoSuggestion(value: '1010', label: 'Cash on Hand'),
  ],
  initialSelected: [
    AutoSuggestion(value: '1010', label: 'Cash on Hand'),
  ],
  onSelected: (suggestion) {
    save(suggestion.value);
  },
  onSelectionChanged: (suggestions) {
    saveAll([for (final suggestion in suggestions) suggestion.value]);
  },
);
```

After:

```dart
AutoSuggestionsBox<String>(
  items: const ['1010'],
  suggestionBuilder: accountSuggestion,
  initialSelected: const ['1010'],
  onSelected: (code) {
    save(code);
  },
  onSelectionChanged: (codes) {
    saveAll(codes);
  },
);
```

`itemBuilder` now receives the raw item and the built suggestion:

```dart
AutoSuggestionsBox<String>(
  items: accounts,
  suggestionBuilder: accountSuggestion,
  itemBuilder: (context, code, suggestion, highlighted) {
    return Text('${suggestion.label} ($code)');
  },
);
```

## 7. Inline Create

Before:

```dart
AutoSuggestionsBox<String>(
  items: vendors,
  onCreate: (query) async {
    final vendor = await api.createVendor(query);
    return AutoSuggestion(value: vendor.id, label: vendor.name);
  },
);
```

After:

```dart
AutoSuggestionsBox<String>(
  items: vendorIds,
  suggestionBuilder: vendorSuggestion,
  onCreate: (query) async {
    final vendor = await api.createVendor(query);
    return vendor.id;
  },
);
```

## 8. Updated Example Usage

Synchronous:

```dart
AutoSuggestionsBox<String>(
  items: accounts,
  suggestionBuilder: accountSuggestion,
);
```

Asynchronous:

```dart
AutoSuggestionsBox<String>(
  source: SuggestionSources.async<String>(
    (query) => api.searchAccounts(query),
  ),
  suggestionBuilder: accountSuggestion,
);
```

Hybrid:

```dart
AutoSuggestionsBox<String>(
  source: SuggestionSources.hybrid<String>(
    initialItems: localAccounts,
    fetch: (query) => api.searchAccounts(query),
  ),
  suggestionBuilder: accountSuggestion,
);
```

Remote fallback:

```dart
AutoSuggestionsBox<String>(
  source: SuggestionSources.remoteFallback<String>(
    initialItems: localAccounts,
    fetch: (query) => api.searchAccounts(query),
  ),
  suggestionBuilder: accountSuggestion,
);
```

## 9. Removed Or Changed `AutoSuggestion<T>`-Based APIs

- `items: List<AutoSuggestion<T>>` -> `items: List<T>` plus
  `suggestionBuilder`.
- `SuggestionSources.list/fuzzy` item lists now use `List<T>`.
- `SuggestionSources.async/hybrid/remoteFallback` fetch callbacks now return
  `Future<List<T>>`.
- `SuggestionSources.*` factories no longer accept `suggestionBuilder`.
- `AutoSuggestionsBoxController` no longer accepts `suggestionBuilder`.
- `AutoSuggestionsBox` requires `suggestionBuilder`.
- `SuggestionsPage.items` now uses `List<T>`.
- `SuggestionsQueryResult.items` and `loadMore` now use raw `T`.
- `AutoSuggestionsBoxController.initialValue` is `T?`.
- `initialSelected`, `selectedItems`, `selectedValues`, `initialRecents`, and
  `recents` are raw `List<T>`.
- `onSelected` receives `T`.
- `onSelectionChanged` receives `List<T>`.
- `onCreate` returns `FutureOr<T?>`.
- Use `controller.suggestions`, `controller.suggestionAt(index)`,
  `controller.highlightedSuggestion`, or `controller.selectedSuggestion` when
  metadata is required.
