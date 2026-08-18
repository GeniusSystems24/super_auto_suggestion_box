# super_auto_suggestion_box example

Runnable gallery for `super_auto_suggestion_box` 1.2.0 with `super_core` 3.3.0.

The gallery demonstrates raw `T` items with `suggestionBuilder` across local,
fuzzy, remote-fallback, paged, multi-select, recents, inline-create, validation,
read-only, advanced-search, fixable-field, and text-input scenarios.

Dedicated launcher entries cover every built-in source factory: `strings`,
`list`, `fuzzy`, `async`, `hybrid`, `remoteFallback`, and `paged`. Each source
screen includes basic, externally controlled, multi-select, and recent-value
examples. Every source route has its own screen file under `lib/sources/`, with
shared scenario plumbing kept in `lib/source_examples_shared.dart`.
The source screens use the same GeniusLink app bar, scaffold, typography,
spacing, marker, and section-card styling as the main component demo.

```bash
flutter pub get
flutter run
```
