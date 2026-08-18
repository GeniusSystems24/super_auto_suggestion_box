// ============================================================
// features/auto_suggestion_box/domain/repositories/super_auto_suggestions_source.dart
// ------------------------------------------------------------
// The repository contract. A source produces raw matches for a query. The
// widget binds its suggestionBuilder internally so sources can derive
// SuperAutoSuggestionsItem metadata without exposing builder parameters publicly.
// ============================================================

import 'dart:async';

import '../entities/super_auto_suggestions_item.dart';
import '../entities/super_suggestions_page.dart';
import '../entities/suggestions_query_result.dart';

SuperAutoSuggestionsItem<T> _defaultSuggestionBuilder<T>(
  List<T> items,
  int index,
  T element,
) => SuperAutoSuggestionsItem<T>(value: element, titleText: element.toString());

/// Produces raw matches for a query. Implement in the data layer (or subclass
/// for custom behaviour); construct via the `SuperAutoSuggestionSources` factory facade.
abstract class SuperAutoSuggestionsSource<T> {
  SuperAutoSuggestionsSource()
    : _suggestionBuilder = _defaultSuggestionBuilder<T>;

  AutoSuggestionBuilder<T> _suggestionBuilder;

  void _bindViewAdapter(AutoSuggestionBuilder<T> builder) {
    _suggestionBuilder = builder;
  }

  /// Return the matches for [query] (may be sync or a Future). An empty query
  /// is expected to return the "initial"/all set (capped by the view).
  FutureOr<List<T>> query(String query);

  /// Build the [SuperAutoSuggestionsItem] for an item already present in [items].
  SuperAutoSuggestionsItem<T> suggestionAt(List<T> items, int index) =>
      _suggestionBuilder(items, index, items[index]);

  /// Build the [SuperAutoSuggestionsItem] for a standalone [item].
  SuperAutoSuggestionsItem<T> suggestionFor(T item) =>
      _suggestionBuilder([item], 0, item);

  /// Build all [SuperAutoSuggestionsItem] rows for [items].
  List<SuperAutoSuggestionsItem<T>> suggestionsFor(List<T> items) => [
    for (var i = 0; i < items.length; i++) suggestionAt(items, i),
  ];

  /// Whether results arrive asynchronously (drives the loading spinner).
  bool get isAsync => false;

  /// Optional two-phase resolution: return the items available now plus an
  /// optional remote `loadMore` thunk (see [SuggestionsQueryResult]). Return
  /// null (the default) to use the single-phase [query] instead. Sources that
  /// want "show local instantly, fetch remote when local is thin" override this.
  SuggestionsQueryResult<T>? progressive(String query) => null;

  /// Whether this source serves results one page at a time (infinite scroll).
  /// When true the controller loads page 0 via [fetchPage] on each query and
  /// appends [fetchPage] `page + 1` as the user scrolls near the end.
  bool get isPaged => false;

  /// Fetch one [page] (0-based) of matches for [query]. Only called when
  /// [isPaged] is true; the default throws to catch a mis-wired source.
  Future<SuperSuggestionsPage<T>> fetchPage(String query, int page) =>
      throw UnsupportedError(
        'This source is not paged; override fetchPage or set isPaged.',
      );

  /// Resolve a stored [value] back to its raw item so a controller can commit
  /// it and display the label produced by the widget builder. Returns null
  /// when the source can't resolve synchronously (e.g. a purely-remote search);
  /// local sources override this to look the value up in their in-memory set.
  /// Used by `SuperAutoSuggestionsController.selectByValue`.
  T? resolve(T value) => null;
}

/// Binds the widget-owned metadata builder to a source.
///
/// This is hidden from the package barrel and is used by
/// `SuperAutoSuggestionsBox` so source APIs do not expose `suggestionBuilder`.
void bindSuperAutoSuggestionsSourceView<T>(
  SuperAutoSuggestionsSource<T> source,
  AutoSuggestionBuilder<T> builder,
) {
  source._bindViewAdapter(builder);
}

/// Deprecated name for [SuperAutoSuggestionsSource].
@Deprecated('Use SuperAutoSuggestionsSource instead.')
typedef AutoSuggestionsSource<T> = SuperAutoSuggestionsSource<T>;
