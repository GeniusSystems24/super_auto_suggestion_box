# Migration Guide: 1.3.0 to 1.3.1

Version 1.3.1 aligns `SuperAutoSuggestionsBox` with the shared
`super_form_field` field foundation and refines Advanced Search on mobile.

## Dependency

`super_auto_suggestion_box` now depends on:

```yaml
super_form_field: ^1.10.0+2
```

The package reuses `FieldShell`, `ErrorBadge`, and `FieldIconButton` instead of
maintaining private copies of the same form-field UI primitives.

## Advanced Search on mobile

Desktop behavior is unchanged: Advanced Search opens as a centered dialog.

On Android, iOS, and Fuchsia, Advanced Search opens as an edge-to-edge modal
bottom sheet. The mobile surface intentionally has no outer padding/margin and
does not render desktop keyboard-shortcut instructions.

## Grouped Advanced Search results

Advanced Search now displays `SuperAutoSuggestionsItem.group` headings using
the same adjacency rule and visual treatment as the inline overlay menu.

```dart
SuperAutoSuggestionsItem<Account>(
  value: account,
  titleText: account.name,
  group: account.type,
);
```

Consecutive results with the same non-null group share a single group header.
