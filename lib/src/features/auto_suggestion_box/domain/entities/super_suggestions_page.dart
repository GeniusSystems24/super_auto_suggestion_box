// ============================================================
// features/auto_suggestion_box/domain/entities/super_suggestions_page.dart
// ------------------------------------------------------------
// One page of results for a paginated (infinite-scroll) source. Large ERP
// master data — a chart of thousands of accounts, tens of thousands of
// items/SKUs, a vendor directory — can't be shipped to the client in one shot.
// A [PagedSuggestionsSource] returns the rows for a `(query, page)` pair plus a
// [hasMore] flag; the controller loads page 0 on each query and appends the next
// page when the user scrolls near the bottom of the overlay.
// ============================================================

/// One page of suggestions for a `(query, page)` request.
class SuperSuggestionsPage<T> {
  /// The raw rows on this page (already ordered by the backend).
  final List<T> items;

  /// Whether at least one more page exists after this one. When false the
  /// controller stops requesting further pages for this query.
  final bool hasMore;

  const SuperSuggestionsPage({required this.items, this.hasMore = false});

  /// The last (or only) page — no more rows after it.
  const SuperSuggestionsPage.last(this.items) : hasMore = false;

  /// An empty page (no rows, nothing more to load).
  const SuperSuggestionsPage.empty() : items = const [], hasMore = false;
}

/// Deprecated name for [SuperSuggestionsPage].
@Deprecated('Use SuperSuggestionsPage instead.')
typedef SuggestionsPage<T> = SuperSuggestionsPage<T>;
