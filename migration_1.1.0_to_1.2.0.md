# Migration Guide: 1.1.0 to 1.2.0

Version `1.2.0` moves validation to the selected raw value and makes
`onSelectionChanged` the single public selection callback. It also integrates
`SuperAutoSuggestionsBox<T>` with Flutter forms through `FormField<T>`.

## 1. Rename and genericize the validator

`AutoSuggestionsValidator` has been replaced by
`SuperAutoSuggestionsValidator<T>`.

```dart
// 1.1.0
String? validateAccount(String value) {
  if (value.trim().isEmpty) return null;
  return null;
}

// 1.2.0
String? validateAccount(String? value) {
  if (value == null) return null;
  return allowedAccounts.contains(value)
      ? null
      : 'Pick an account from the list';
}
```

The public typedef is now:

```dart
typedef SuperAutoSuggestionsValidator<T> = String? Function(T? value);
```

The validator receives the selected raw `T?`, not the query string or rendered
label. With `required: true`, the package handles an empty selection before
calling your custom validator.

## 2. `SuperAutoSuggestionsBox<T>` now uses `FormField<T>`

The widget owns an outer `FormField<T>` and passes its validator through
`FormField.validator`. This means an enclosing `Form` can validate the selected
raw value using the normal Flutter form lifecycle:

```dart
final formKey = GlobalKey<FormState>();
final controller = SuperAutoSuggestionsController<String>();

Form(
  key: formKey,
  child: SuperAutoSuggestionsBox<String>(
    controller: controller,
    source: SuperAutoSuggestionSources.list<String>(accounts),
    suggestionBuilder: accountSuggestion,
    required: true,
    validator: (value) {
      if (value == null) return null;
      return accounts.contains(value) ? null : 'Invalid account';
    },
  ),
);

final valid = formKey.currentState?.validate() ?? false;
if (valid) {
  final selectedAccount = controller.selected;
}
```

## 3. Update `formFieldKey`

Controller form keys now follow the selected value type:

```dart
// 1.1.0
final key = GlobalKey<FormFieldState<String>>();

// 1.2.0, for SuperAutoSuggestionsController<Account>
final key = GlobalKey<FormFieldState<Account>>();
```

The controller property is:

```dart
GlobalKey<FormFieldState<T>>? formFieldKey;
```

For `T == String`, the concrete key still happens to be
`GlobalKey<FormFieldState<String>>`.

## 4. Replace `onSelected` with `onSelectionChanged`

`onSelected` has been removed. Use `onSelectionChanged` for both selection and
de-selection.

```dart
// 1.1.0
SuperAutoSuggestionsBox<String>(
  source: source,
  suggestionBuilder: accountSuggestion,
  onSelected: (account) {
    currentAccount = account;
  },
);

// 1.2.0
SuperAutoSuggestionsBox<String>(
  source: source,
  suggestionBuilder: accountSuggestion,
  onSelectionChanged: (accounts) {
    currentAccount = accounts.isEmpty ? null : accounts.last;
  },
);
```

Single-select callback values are:

- select -> `[item]`
- de-select / clear -> `[]`

Multi-select always receives the complete selected list after the mutation.
Controller-driven selection changes also trigger `onSelectionChanged`.

## 5. Remove text/action callbacks

The following 1.1.0 widget arguments no longer exist:

- `onChanged`
- `onSubmitted`
- `onSelected`
- `onFieldSubmitted`
- `onEditingComplete`
- `onSave`
- `onValidity`

For query-text observation, keep a controller and listen to its
`TextEditingController`:

```dart
final controller = SuperAutoSuggestionsController<String>();

void initListeners() {
  controller.text.addListener(() {
    final query = controller.text.text;
  });
}
```

For selection state, use `onSelectionChanged` or read
`controller.selected` / `controller.selectedItems`.

There is no `onSave` replacement on the widget. When a host form validates or
submits, read the selected raw value from the controller.

## 6. Migrate form save flows

```dart
// 1.1.0
SuperAutoSuggestionsBox<String>(
  source: source,
  suggestionBuilder: documentSuggestion,
  onSave: (value) => savedReference = value,
);

formKey.currentState?.save();
```

```dart
// 1.2.0
final documentController = SuperAutoSuggestionsController<String>();

SuperAutoSuggestionsBox<String>(
  controller: documentController,
  source: source,
  suggestionBuilder: documentSuggestion,
  required: true,
);

if (formKey.currentState?.validate() ?? false) {
  savedReference = documentController.selected;
}
```

## 7. Additional 1.2.0 API changes

### Source helper and implementation names

The canonical source factory namespace is now
`SuperAutoSuggestionSources`. The old `SuggestionSources` name remains as a
deprecated typedef so existing code can migrate incrementally:

```dart
// 1.1.0
final source = SuggestionSources.list<String>(accounts);

// 1.2.0
final source = SuperAutoSuggestionSources.list<String>(accounts);
```

The concrete source implementations were also renamed:

| 1.1.0 name | 1.2.0 name |
| --- | --- |
| `ListSuggestionsSource<T>` | `SuperAutoListSuggestionsSource<T>` |
| `AsyncSuggestionsSource<T>` | `SuperAutoAsyncSuggestionsSource<T>` |
| `HybridSuggestionsSource<T>` | `SuperAutoHybridSuggestionsSource<T>` |
| `RemoteFallbackSuggestionsSource<T>` | `SuperAutoRemoteFallbackSuggestionsSource<T>` |
| `PagedSuggestionsSource<T>` | `SuperAutoPagedSuggestionsSource<T>` |

Prefer the `SuperAutoSuggestionSources` factories unless direct construction is
needed. Unlike `SuggestionSources`, the old concrete class names do not have
compatibility typedefs.

### `onValidity` was removed

`onValidity` is no longer part of `SuperAutoSuggestionsBox<T>`. Validation is
owned by the outer `FormField<T>` and the enclosing Flutter `Form`.

```dart
final valid = formKey.currentState?.validate() ?? false;
final fieldState = controller.formFieldKey?.currentState;

if (valid && !(fieldState?.hasError ?? false)) {
  final value = controller.selected;
}
```

Use `validator` to define validity, `FormState.validate()` to trigger
validation, and controller/form-field state when the host needs to inspect the
result. Do not recreate a validity callback from query-text changes.

### Localization

Version 1.2.0 includes English and Arabic package strings through
`flutter_localizations`, `intl`, and generated `intl_utils` delegates:

```dart
MaterialApp(
  localizationsDelegates: const [
        // ...
        SuperAutoSuggestionsTranslation.delegate,
      ],
  supportedLocales:
      SuperAutoSuggestionsTranslation.delegate.supportedLocales,
)
```

Registration is optional. If no `SuperAutoSuggestionsLocalization` is present
in the widget tree, package-owned strings use the built-in English
localization. Explicit widget strings still take precedence.

### `TextInputAction.next` after selection

For a single-select field, selecting an item now advances to the next focusable
field when `textInputAction == TextInputAction.next`:

```dart
SuperAutoSuggestionsBox<String>(
  source: SuperAutoSuggestionSources.list<String>(accounts),
  suggestionBuilder: accountSuggestion,
  multiSelect: false,
  textInputAction: TextInputAction.next,
);
```

This applies to normal suggestion selection and built-in Advanced Search
selection. Multi-select fields keep focus in the current field.

## 8. Validation and selection summary

| Concern | 1.1.0 | 1.2.0 |
| --- | --- | --- |
| Validator typedef | `AutoSuggestionsValidator` | `SuperAutoSuggestionsValidator<T>` |
| Validator input | query `String` | selected `T?` |
| Form field | inner text form field | outer `FormField<T>` |
| Controller form key | `FormFieldState<String>` | `FormFieldState<T>` |
| Select callback | `onSelected(T)` | `onSelectionChanged(List<T>)` |
| De-select callback | multi-select only | `onSelectionChanged(List<T>)` |
| Query callback | `onChanged` | controller text listener |
| Save callback | `onSave` | read controller state after validation |
| Validity callback | `onValidity` | `FormState.validate()` / `formFieldKey` state |
| Source factory namespace | `SuggestionSources` | `SuperAutoSuggestionSources` |

After migration, run:

```bash
dart format lib test example/lib
flutter analyze
flutter test
```
