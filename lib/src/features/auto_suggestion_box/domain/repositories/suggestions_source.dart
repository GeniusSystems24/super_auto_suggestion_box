// ============================================================
// features/auto_suggestion_box/domain/repositories/suggestions_source.dart
// ------------------------------------------------------------
// The repository contract. A source produces the suggestions for a query — it
// is the seam between the box and wherever its data lives (an in-memory list, a
// remote search, a database, a hybrid of both). The controller depends only on
// this abstraction; concrete implementations live in the data layer
// (`data/datasources/suggestion_sources.dart`, behind the `SuggestionSources`
// facade).
// ============================================================

import 'dart:async';

import '../entities/auto_suggestion.dart';
import '../entities/suggestions_page.dart';
import '../entities/suggestions_query_result.dart';

/// Produces suggestions for a query. Implement in the data layer (or subclass
/// for custom behaviour); construct via the `SuggestionSources` factory facade.
abstract class AutoSuggestionsSource<T> {
  const AutoSuggestionsSource();

  /// Return the matches for [query] (may be sync or a Future). An empty query
  /// is expected to return the "initial"/all set (capped by the view).
  FutureOr<List<AutoSuggestion<T>>> query(String query);

  /// Whether results arrive asynchronously (drives the loading spinner).
  bool get isAsync => false;

  /// Optional two-phase resolution: return the items available *now* plus an
  /// optional remote `loadMore` thunk (see [SuggestionsQueryResult]). Return
  /// null (the default) to use the single-phase [query] instead. Sources that
  /// want "show local instantly, fetch remote when local is thin" override this.
  SuggestionsQueryResult<T>? progressive(String query) => null;

  /// Whether this source serves results one **page** at a time (infinite
  /// scroll). When true the controller loads page 0 via [fetchPage] on each
  /// query and appends [fetchPage] `page + 1` as the user scrolls near the end.
  bool get isPaged => false;

  /// Fetch one [page] (0-based) of matches for [query]. Only called when
  /// [isPaged] is true; the default throws to catch a mis-wired source.
  Future<SuggestionsPage<T>> fetchPage(String query, int page) =>
      throw UnsupportedError(
        'This source is not paged; override fetchPage or set isPaged.',
      );

  /// Resolve a stored [value] back to its full suggestion (label, description,
  /// icon, …) so a form bound to a record's id can display it. Returns null when
  /// the source can't resolve synchronously (e.g. a purely-remote search); local
  /// sources override this to look the value up in their in-memory set. Used by
  /// `AutoSuggestionsBoxController.selectByValue`.
  AutoSuggestion<T>? resolve(T value) => null;
}
