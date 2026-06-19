/// Super Auto Suggestion Box — a GeniusLink design-system Flutter package that
/// ships the **AutoSuggestionsBox** typeahead / combobox: local + remote
/// sources, prefix / contains / fuzzy matching, single- and multi-select,
/// free-text entry, a local-first progressive `remoteFallback` source, an
/// advanced-search overlay, and a `bare` embedding mode.
///
/// This package also carries the shared GeniusLink **core** foundation (theme
/// tokens, `ThemeExtension`s, text styles and a handful of design-system
/// widgets) that the box is built on. The companion `super_table_field` package
/// depends on this one and re-exports it, so a `SuperTable`'s `combo` columns
/// can be edited through the real `AutoSuggestionsBox`.
///
/// Architecture: Clean Architecture per feature
///   data/        — datasources, models (DTOs), repository implementations
///   domain/      — entities, repository contracts, usecases (pure Dart)
///   presentation/— controllers (Model / state), widgets + pages (the View)
///
/// Shared, cross-feature code lives in `lib/src/core/`.
///
/// The shared GeniusLink **core** foundation now lives in the `super_core`
/// package, which this package depends on and re-exports.
///
/// Import this single barrel to get everything:
///   `import 'package:super_auto_suggestion_box/super_auto_suggestion_box.dart';`
library super_auto_suggestion_box;

// ── Core (theme tokens, shared widgets, utils — from super_core) ─────────────
export 'src/core/core.dart';

// ── Feature ─────────────────────────────────────────────────────────────────
export 'src/features/auto_suggestion_box/auto_suggestion_box.dart';
