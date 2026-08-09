# Migration to super_core 3.3.0

`super_auto_suggestion_box` 0.13.0 requires:

```yaml
environment:
  sdk: ">=3.8.0 <4.0.0"
  flutter: ">=3.32.0"

dependencies:
  super_core: ^3.3.0
```

## Consumer changes

`SuperMaterialThemeData.light` and `.dark` now require explicit
`SuperTextTheme` instances for `textTheme` and `primaryTextTheme`:

```dart
import 'package:super_auto_suggestion_box/super_auto_suggestion_box.dart';

final typography = SuperTextTheme();

MaterialApp(
  theme: SuperMaterialThemeData.light(
    textTheme: typography,
    primaryTextTheme: typography,
  ),
  darkTheme: SuperMaterialThemeData.dark(
    textTheme: typography,
    primaryTextTheme: typography,
  ),
);
```

For Arabic, create the ramp explicitly, for example
`SuperTextTheme(isArabic: true)`. For desktop density, pass
`isDesktop: mode == SuperDeviceMode.desktop`.

## Typography access

`SuperThemeData.textTheme` was removed in `super_core 3.3.0`. Replace old reads:

```dart
// Old — invalid on super_core 3.3.0
context.superTheme.textTheme

// New
context.superTextTheme
// or
SuperMaterialThemeData.of(context).textTheme
```

`AutoSuggestionsBox` 0.13.0 also stops using its legacy hard-coded
`Inter`/`Manrope` aliases internally. Field, overlay, advanced-search, and mono
text now follow the ambient `SuperTextTheme`. The public `bodyFont` and
`displayFont` constants remain temporarily deprecated for source compatibility.

`super_core 3.3.0` no longer infers token font metadata from the supplied text
theme. Configure typography through `SuperTextTheme(bodyFont:, otherFont:)`;
pass `SuperMaterialThemeData.fontFamily` separately only when an explicit token
font-family override is required.

## Component theme bridge

`AutoSuggestionsBoxThemeData.of(context)` still derives color/layout defaults
from the active `SuperMaterialThemeData`. Its bridge reads
`theme.superTheme` for non-typography tokens and deliberately reads typography
through `context.superTextTheme` at widget call sites. An explicit
`AutoSuggestionsBoxThemeData` extension is only needed for per-app component
overrides.

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
