# Migration to super_core 3.0.0

This package now requires:

```yaml
environment:
  sdk: ">=3.8.0 <4.0.0"
  flutter: ">=3.32.0"

dependencies:
  super_core: ^3.0.0
```

## Consumer changes

Use the `super_core` barrel and its generated themes:

```dart
import 'package:super_auto_suggestion_box/super_auto_suggestion_box.dart';

MaterialApp(
  theme: SuperMaterialThemeData.light(),
  darkTheme: SuperMaterialThemeData.dark(),
);
```

`AutoSuggestionsBoxThemeData.of(context)` automatically derives its defaults
from the active `SuperMaterialThemeData`. An explicit extension is only needed
when overriding the component theme.

The v3 layout and section APIs are re-exported by this package:

- Replace `SectionCard`, `SuperSection`, and `SuperCard` with
  `SuperSectionCard`.
- Replace `SectionHeader` with `SuperSectionHeader`.
- Read spacing, radii, control heights, and container insets from
  `context.superTheme.spacing`.
- Use `SuperScaffold` and `SuperGrid` for responsive page layouts.

## Validation

Run from the package root:

```bash
flutter pub get
dart format .
flutter analyze
flutter test

cd example
flutter pub get
flutter analyze
```
