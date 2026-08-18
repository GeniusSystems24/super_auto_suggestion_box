import 'dart:async';

import '../../domain/entities/super_auto_suggestions_item.dart';
import '../../domain/entities/match_strategy.dart';
import '../../domain/entities/super_suggestions_page.dart';
import '../../domain/entities/suggestions_query_result.dart';
import '../../domain/repositories/super_auto_suggestions_source.dart';

/// Creates commonly used [SuperAutoSuggestionsSource] implementations.
///
/// Prefer these factories when the built-in source behavior matches the data
/// access pattern of the application. They keep source construction concise
/// while still returning the [SuperAutoSuggestionsSource] abstraction consumed
/// by `SuperAutoSuggestionsBox`.
///
/// The available source strategies are:
///
/// * [list] for synchronous, in-memory filtering.
/// * [strings] for the common `List<String>` case.
/// * [fuzzy] for in-memory fuzzy matching.
/// * [async] for a remote or otherwise asynchronous lookup.
/// * [hybrid] for immediate local matches followed by optional remote results.
/// * [remoteFallback] for local-first lookup with remote fallback when local
///   results are sparse.
/// * [paged] for page-based APIs and incremental loading.
///
/// Which source to choose depends mainly on where the data lives and how much
/// data can be held locally. For small static collections, [list] or [fuzzy]
/// avoids asynchronous work. For server-backed search, use [async], [hybrid],
/// [remoteFallback], or [paged] according to the API's loading model.
///
/// {@template super_auto_suggestion_sources_builder}
/// Matching and de-duplication operate on the [SuperAutoSuggestionsItem]
/// produced by the source's suggestion builder. In particular,
/// `displayText`, `keywords`, and `value` affect matching, ordering,
/// resolution, and merge behavior.
/// {@endtemplate}
abstract final class SuperAutoSuggestionSources {
  /// Creates a synchronous source backed by the in-memory [items].
  ///
  /// The source filters [items] for every query using [match]. Matching is
  /// performed against each suggestion's display text and keywords. When
  /// [caseSensitive] is `false`, both the query and searchable text are
  /// normalized to lower case before matching.
  ///
  /// An empty or whitespace-only query returns all items. Non-fuzzy results are
  /// ordered primarily by where the query appears in the display text, then by
  /// display-text length. Fuzzy results are ordered by fuzzy score.
  ///
  /// This source is a good fit for small or moderate collections that are
  /// already available in memory. For data that must be fetched, see [async],
  /// [hybrid], [remoteFallback], or [paged].
  ///
  /// ---
  /// Example:
  ///
  /// ```dart
  /// final source = SuperAutoSuggestionSources.list<Product>(
  ///   products,
  ///   match: AutoSuggestionMatch.contains,
  /// );
  ///
  /// SuperAutoSuggestionsBox<Product>(
  ///   source: source,
  ///   suggestionBuilder: (items, index, product) {
  ///     return SuperAutoSuggestionsItem<Product>(
  ///       value: product,
  ///       displayText: product.name,
  ///       keywords: [product.sku],
  ///     );
  ///   },
  /// );
  /// ```
  ///
  /// {@macro super_auto_suggestion_sources_builder}
  static SuperAutoSuggestionsSource<T> list<T>(
    List<T> items, {
    AutoSuggestionMatch match = AutoSuggestionMatch.contains,
    bool caseSensitive = false,
  }) => SuperAutoListSuggestionsSource<T>(
    items,
    match: match,
    caseSensitive: caseSensitive,
  );

  /// Creates a synchronous source for a list of [String] values.
  ///
  /// This is the shortest way to use the package when the suggestion value and
  /// visible label are the same string. It uses [SuperAutoListSuggestionsSource] with
  /// case-insensitive matching and the supplied [match] strategy.
  ///
  /// Use [list] instead when suggestions need custom object values, keywords, or
  /// case-sensitive matching.
  ///
  /// ---
  /// Example:
  ///
  /// ```dart
  /// final source = SuperAutoSuggestionSources.strings(
  ///   ['Amman', 'Aden', 'Cairo', 'Dubai'],
  ///   match: AutoSuggestionMatch.startsWith,
  /// );
  ///
  /// SuperAutoSuggestionsBox<String>(
  ///   source: source,
  /// );
  /// ```
  static SuperAutoSuggestionsSource<String> strings(
    List<String> values, {
    AutoSuggestionMatch match = AutoSuggestionMatch.contains,
  }) => SuperAutoListSuggestionsSource<String>(values, match: match);

  /// Creates a synchronous in-memory source using fuzzy matching.
  ///
  /// Fuzzy matching is useful when a query may contain minor spelling
  /// differences or characters that are not contiguous in the candidate text.
  /// Results are ranked by fuzzy score, with shorter display text used as a
  /// tie-breaker.
  ///
  /// Set [caseSensitive] to `true` only when letter case is meaningful to the
  /// search domain.
  ///
  /// This is equivalent to [list] with
  /// `match: AutoSuggestionMatch.fuzzy`.
  ///
  /// ---
  /// Example:
  ///
  /// ```dart
  /// final source = SuperAutoSuggestionSources.fuzzy<Customer>(
  ///   customers,
  /// );
  ///
  /// SuperAutoSuggestionsBox<Customer>(
  ///   source: source,
  ///   suggestionBuilder: (items, index, customer) {
  ///     return SuperAutoSuggestionsItem<Customer>(
  ///       value: customer,
  ///       displayText: customer.name,
  ///       keywords: [customer.code, customer.phone],
  ///     );
  ///   },
  /// );
  /// ```
  static SuperAutoSuggestionsSource<T> fuzzy<T>(
    List<T> items, {
    bool caseSensitive = false,
  }) => SuperAutoListSuggestionsSource<T>(
    items,
    match: AutoSuggestionMatch.fuzzy,
    caseSensitive: caseSensitive,
  );

  /// Creates an asynchronous source backed by [fetch].
  ///
  /// [fetch] is called with the current query and must complete with the raw
  /// values to display. Errors from [fetch] are allowed to propagate to the
  /// consumer; handle transport- or domain-specific failures in the callback
  /// when a fallback result is required.
  ///
  /// Every successful result is added to an internal cache, de-duplicated by the
  /// suggestion value. The cache is used by `resolve` so a previously fetched
  /// value can later be mapped back to its canonical item. [initialItems] seeds
  /// that cache before the first request; it is not returned automatically from
  /// `query`.
  ///
  /// Debouncing belongs to `SuperAutoSuggestionsBox` or to the application
  /// layer. The source itself invokes [fetch] whenever its `query` method is
  /// called.
  ///
  /// ---
  /// Example:
  ///
  /// ```dart
  /// final source = SuperAutoSuggestionSources.async<Customer>(
  ///   (query) => customerRepository.search(query),
  /// );
  ///
  /// SuperAutoSuggestionsBox<Customer>(
  ///   source: source,
  ///   debounce: const Duration(milliseconds: 300),
  ///   suggestionBuilder: (items, index, customer) {
  ///     return SuperAutoSuggestionsItem<Customer>(
  ///       value: customer,
  ///       displayText: customer.name,
  ///     );
  ///   },
  /// );
  /// ```
  static SuperAutoSuggestionsSource<T> async<T>(
    Future<List<T>> Function(String query) fetch, {
    List<T> initialItems = const [],
  }) => SuperAutoAsyncSuggestionsSource<T>(fetch, initialItems: initialItems);

  /// Creates a source that combines local matching with optional remote results.
  ///
  /// [initialItems] are searchable immediately. A remote request is made only
  /// when both of these conditions are true:
  ///
  /// * the trimmed query length is at least [remoteMinChars]; and
  /// * the number of local matches is **less than** [remoteThreshold].
  ///
  /// With progressive querying, local matches can be rendered first and the
  /// remote result loaded afterward. Remote values are cached and merged with
  /// local values, de-duplicated by each suggestion's `value`.
  ///
  /// For ordinary `query` calls, a remote failure falls back to the already
  /// computed local result. A failure from the progressive `loadMore` future is
  /// not swallowed by this source and may be handled by the consumer.
  ///
  /// Choose this strategy when local data should always contribute to the final
  /// result. If remote data should be treated mainly as a fallback for sparse
  /// local results, compare [remoteFallback].
  ///
  /// ---
  /// Example:
  ///
  /// ```dart
  /// final source = SuperAutoSuggestionSources.hybrid<Product>(
  ///   initialItems: popularProducts,
  ///   fetch: (query) => productRepository.search(query),
  ///   remoteThreshold: 3,
  ///   remoteMinChars: 2,
  /// );
  ///
  /// SuperAutoSuggestionsBox<Product>(
  ///   source: source,
  ///   suggestionBuilder: (items, index, product) {
  ///     return SuperAutoSuggestionsItem<Product>(
  ///       value: product,
  ///       displayText: product.name,
  ///       keywords: [product.sku],
  ///     );
  ///   },
  /// );
  /// ```
  ///
  /// {@macro super_auto_suggestion_sources_builder}
  static SuperAutoSuggestionsSource<T> hybrid<T>({
    required List<T> initialItems,
    required Future<List<T>> Function(String query) fetch,
    AutoSuggestionMatch match = AutoSuggestionMatch.contains,
    int remoteThreshold = 1,
    int remoteMinChars = 1,
    bool caseSensitive = false,
  }) => SuperAutoHybridSuggestionsSource<T>(
    initialItems: initialItems,
    fetch: fetch,
    match: match,
    remoteThreshold: remoteThreshold,
    remoteMinChars: remoteMinChars,
    caseSensitive: caseSensitive,
  );

  /// Creates a local-first source that fetches remotely when matches are sparse.
  ///
  /// [initialItems] are filtered synchronously with [match]. A remote request is
  /// made only when both of these conditions are true:
  ///
  /// * the trimmed query length is at least [remoteMinChars]; and
  /// * the number of local matches is **less than or equal to**
  ///   [remoteThreshold].
  ///
  /// Successful remote values are cached and merged with the local matches,
  /// de-duplicated by suggestion `value`. For ordinary `query` calls, a remote
  /// error returns the local result instead. Progressive `loadMore` errors are
  /// exposed to the consumer.
  ///
  /// The inclusive threshold is the notable difference from [hybrid], whose
  /// remote fetch condition uses `local.length < remoteThreshold`.
  ///
  /// ---
  /// Example:
  ///
  /// ```dart
  /// final source = SuperAutoSuggestionSources.remoteFallback<Customer>(
  ///   initialItems: recentCustomers,
  ///   fetch: (query) => customerRepository.search(query),
  ///   remoteThreshold: 5,
  ///   remoteMinChars: 2,
  /// );
  ///
  /// SuperAutoSuggestionsBox<Customer>(
  ///   source: source,
  ///   suggestionBuilder: (items, index, customer) {
  ///     return SuperAutoSuggestionsItem<Customer>(
  ///       value: customer,
  ///       displayText: customer.name,
  ///     );
  ///   },
  /// );
  /// ```
  ///
  /// {@macro super_auto_suggestion_sources_builder}
  static SuperAutoSuggestionsSource<T> remoteFallback<T>({
    required List<T> initialItems,
    required Future<List<T>> Function(String query) fetch,
    AutoSuggestionMatch match = AutoSuggestionMatch.contains,
    int remoteThreshold = 5,
    int remoteMinChars = 1,
    bool caseSensitive = false,
  }) => SuperAutoRemoteFallbackSuggestionsSource<T>(
    initialItems: initialItems,
    fetch: fetch,
    match: match,
    remoteThreshold: remoteThreshold,
    remoteMinChars: remoteMinChars,
    caseSensitive: caseSensitive,
  );

  /// Creates an asynchronous source backed by a zero-based page loader.
  ///
  /// [fetch] receives the current query and a page index. Page `0` is the first
  /// page. The callback returns a [SuperSuggestionsPage] that describes the page
  /// items and whether more data is available.
  ///
  /// Calling the source's ordinary `query` method loads page `0`. Incremental
  /// consumers can call `fetchPage` for subsequent pages. Every fetched item is
  /// retained in an internal resolution cache. [resolveFrom] seeds that cache so
  /// preselected values can be resolved before their page has been fetched.
  ///
  /// Unlike the local/hybrid merge helpers, the paging cache appends fetched
  /// items as returned; the source does not de-duplicate pages. If an API may
  /// repeat rows across pages, de-duplicate in [fetch] or in the repository layer.
  ///
  /// ---
  /// Example:
  ///
  /// ```dart
  /// final source = SuperAutoSuggestionSources.paged<Product>(
  ///   (query, page) async {
  ///     final response = await productRepository.search(
  ///       query: query,
  ///       page: page,
  ///     );
  ///
  ///     return SuperSuggestionsPage<Product>(
  ///       items: response.items,
  ///       hasMore: response.hasMore,
  ///     );
  ///   },
  ///   resolveFrom: initiallySelectedProducts,
  /// );
  ///
  /// SuperAutoSuggestionsBox<Product>(
  ///   source: source,
  ///   suggestionBuilder: (items, index, product) {
  ///     return SuperAutoSuggestionsItem<Product>(
  ///       value: product,
  ///       displayText: product.name,
  ///     );
  ///   },
  /// );
  /// ```
  static SuperAutoSuggestionsSource<T> paged<T>(
    Future<SuperSuggestionsPage<T>> Function(String query, int page) fetch, {
    List<T> resolveFrom = const [],
  }) => SuperAutoPagedSuggestionsSource<T>(fetch, resolveFrom: resolveFrom);
}

/// A deprecated alias for [SuperAutoSuggestionSources].
///
/// Existing code can continue to compile while migrating to the canonical
/// [SuperAutoSuggestionSources] name. New code should not use this alias.
@Deprecated('Use SuperAutoSuggestionSources instead.')
typedef SuggestionSources = SuperAutoSuggestionSources;

class _SuggestionRow<T> {
  const _SuggestionRow(this.item, this.suggestion);

  final T item;
  final SuperAutoSuggestionsItem<T> suggestion;
}

List<_SuggestionRow<T>> _buildRows<T>(
  List<T> items,
  AutoSuggestionBuilder<T> suggestionBuilder,
) => [
  for (var i = 0; i < items.length; i++)
    _SuggestionRow<T>(items[i], suggestionBuilder(items, i, items[i])),
];

List<T> _localMatches<T>({
  required List<T> items,
  required AutoSuggestionBuilder<T> suggestionBuilder,
  required String query,
  required AutoSuggestionMatch match,
  required bool caseSensitive,
}) {
  final normalizedQuery = caseSensitive
      ? query.trim()
      : query.trim().toLowerCase();
  final rows = _buildRows(items, suggestionBuilder);
  if (normalizedQuery.isEmpty) {
    return [for (final row in rows) row.item];
  }

  String haystackOf(SuperAutoSuggestionsItem<T> suggestion) => caseSensitive
      ? [suggestion.displayText, ...suggestion.keywords].join(' ')
      : suggestion.haystack;

  final matched = [
    for (final row in rows)
      if (AutoSuggestionMatching.test(
        haystackOf(row.suggestion),
        normalizedQuery,
        match,
      ))
        row,
  ];

  if (match == AutoSuggestionMatch.fuzzy) {
    matched.sort((a, b) {
      final byScore =
          AutoSuggestionMatching.score(
            haystackOf(b.suggestion),
            normalizedQuery,
            match,
          ).compareTo(
            AutoSuggestionMatching.score(
              haystackOf(a.suggestion),
              normalizedQuery,
              match,
            ),
          );
      return byScore != 0
          ? byScore
          : a.suggestion.displayText.length - b.suggestion.displayText.length;
    });
  } else {
    matched.sort((a, b) {
      final aLabel = caseSensitive
          ? a.suggestion.displayText
          : a.suggestion.displayText.toLowerCase();
      final bLabel = caseSensitive
          ? b.suggestion.displayText
          : b.suggestion.displayText.toLowerCase();
      final aIndex = aLabel.indexOf(normalizedQuery);
      final bIndex = bLabel.indexOf(normalizedQuery);
      final aRank = aIndex < 0 ? 1 << 20 : aIndex;
      final bRank = bIndex < 0 ? 1 << 20 : bIndex;
      if (aRank != bRank) return aRank - bRank;
      return aLabel.length - bLabel.length;
    });
  }

  return [for (final row in matched) row.item];
}

void _appendUniqueByValue<T>(
  List<T> target,
  Iterable<T> items,
  AutoSuggestionBuilder<T> suggestionBuilder,
) {
  final seen = {
    for (final row in _buildRows(target, suggestionBuilder))
      row.suggestion.value,
  };

  for (final item in items) {
    final suggestion = suggestionBuilder([item], 0, item);
    if (seen.add(suggestion.value)) {
      target.add(item);
    }
  }
}

List<T> _mergeUniqueByValue<T>(
  List<T> local,
  List<T> remote,
  AutoSuggestionBuilder<T> suggestionBuilder,
) {
  final merged = List<T>.of(local);
  _appendUniqueByValue(merged, remote, suggestionBuilder);
  return merged;
}

T? _resolveByValue<T>(
  List<T> items,
  T value,
  AutoSuggestionBuilder<T> suggestionBuilder,
) {
  final valueSuggestion = suggestionBuilder([value], 0, value);
  for (final row in _buildRows(items, suggestionBuilder)) {
    if (row.suggestion.value == valueSuggestion.value) {
      return row.item;
    }
  }
  return null;
}

/// A synchronous suggestion source backed by an in-memory collection.
///
/// Use this class directly when the application already owns the values to
/// search and needs explicit access to the source instance or its configuration.
/// For concise construction, prefer [SuperAutoSuggestionSources.list] or
/// [SuperAutoSuggestionSources.fuzzy].
///
/// ---
/// ### Query behavior
///
/// Each call to `query` filters [items] using [match]. Matching is performed
/// against the `displayText` and `keywords` produced by the configured
/// suggestion builder. An empty or whitespace-only query returns every item.
///
/// When [caseSensitive] is `false`, both the query and searchable suggestion
/// text are normalized to lower case. For non-fuzzy matching, results are
/// ordered by the first query occurrence in the display text and then by label
/// length. Fuzzy results are ordered by fuzzy score.
///
/// ---
/// ### Resolution
///
/// `resolve` searches [items] for a suggestion whose `value` matches the
/// requested value. This is useful when a controller or form restores a value
/// and needs the canonical item from the source.
///
/// The [items] list is retained by reference. Mutating it affects subsequent
/// queries and resolution.
///
/// ---
/// Example:
///
/// ```dart
/// final source = SuperAutoListSuggestionsSource<Product>(
///   products,
///   match: AutoSuggestionMatch.startsWith,
/// );
///
/// SuperAutoSuggestionsBox<Product>(
///   source: source,
///   suggestionBuilder: (items, index, product) {
///     return SuperAutoSuggestionsItem<Product>(
///       value: product,
///       displayText: product.name,
///       keywords: [product.sku, product.barcode],
///     );
///   },
/// );
/// ```
class SuperAutoListSuggestionsSource<T> extends SuperAutoSuggestionsSource<T> {
  /// Creates a synchronous source for [items].
  ///
  /// [match] controls how the query is compared with suggestion text and
  /// keywords. [caseSensitive] controls whether matching distinguishes upper-
  /// and lower-case characters.
  SuperAutoListSuggestionsSource(
    this.items, {
    this.match = AutoSuggestionMatch.contains,
    this.caseSensitive = false,
  });

  /// The in-memory values searched by this source.
  ///
  /// The list is retained by reference, so later mutations affect subsequent
  /// queries and resolution.
  final List<T> items;

  /// The matching strategy applied to display text and keywords.
  final AutoSuggestionMatch match;

  /// Whether local matching distinguishes upper- and lower-case text.
  final bool caseSensitive;

  /// Returns the local items that match [query].
  ///
  /// This operation is synchronous. A blank query returns every [items]
  /// element. Result ordering follows the configured [match] strategy.
  @override
  List<T> query(String query) => _localMatches(
    items: items,
    suggestionBuilder: (items, index, element) => suggestionAt(items, index),
    query: query,
    match: match,
    caseSensitive: caseSensitive,
  );

  /// Returns the canonical item whose suggestion value matches [value].
  ///
  /// Returns `null` when [value] cannot be resolved from [items].
  @override
  T? resolve(T value) =>
      _resolveByValue(items, value, (_, _, element) => suggestionFor(element));
}

/// An asynchronous suggestion source backed by a query callback.
///
/// Use this class for server-backed, database-backed, or otherwise asynchronous
/// searches where each query should invoke [fetch]. For concise construction,
/// prefer [SuperAutoSuggestionSources.async].
///
/// ---
/// ### Query behavior
///
/// Every call to `query` invokes [fetch] with the current query and completes
/// with the returned items. The source itself does not debounce requests;
/// configure debouncing on `SuperAutoSuggestionsBox` or in the repository layer
/// when needed.
///
/// Errors from [fetch] propagate through the returned future. Handle transport,
/// timeout, authorization, or domain-specific failures inside [fetch] when a
/// fallback result is required.
///
/// ---
/// ### Cache and resolution
///
/// Successful query results are appended to [cachedItems], de-duplicated by the
/// `value` produced by the suggestion builder. `initialItems` seed that cache
/// before the first request but are not returned automatically by `query`.
///
/// `resolve` searches [cachedItems], allowing a value fetched earlier—or seeded
/// through [initialItems]—to be mapped back to its canonical item.
///
/// ---
/// Example:
///
/// ```dart
/// final source = SuperAutoAsyncSuggestionsSource<Customer>(
///   (query) => customerRepository.search(query),
///   initialItems: recentlyUsedCustomers,
/// );
///
/// SuperAutoSuggestionsBox<Customer>(
///   source: source,
///   debounce: const Duration(milliseconds: 300),
///   suggestionBuilder: (items, index, customer) {
///     return SuperAutoSuggestionsItem<Customer>(
///       value: customer,
///       displayText: customer.name,
///       keywords: [customer.code, customer.phone],
///     );
///   },
/// );
/// ```
class SuperAutoAsyncSuggestionsSource<T> extends SuperAutoSuggestionsSource<T> {
  /// Creates an asynchronous source that delegates queries to [fetch].
  ///
  /// [initialItems] seed [cachedItems] for resolution. They do not cause a
  /// query result to be emitted and are not passed to [fetch].
  SuperAutoAsyncSuggestionsSource(this.fetch, {List<T> initialItems = const []})
    : cachedItems = List<T>.of(initialItems);

  /// Loads suggestion values for a query.
  ///
  /// Errors are propagated by `query` unless handled inside this callback.
  final Future<List<T>> Function(String query) fetch;

  /// Values retained for later resolution.
  ///
  /// The cache starts with `initialItems` and grows after successful queries.
  /// Fetched values are de-duplicated by suggestion `value` before insertion.
  final List<T> cachedItems;

  /// Whether this source performs asynchronous queries.
  @override
  bool get isAsync => true;

  /// Invokes [fetch] for [query], caches successful items, and returns them.
  ///
  /// The returned future completes with the same error if [fetch] fails.
  @override
  Future<List<T>> query(String query) => fetch(query).then((items) {
    _appendUniqueByValue(
      cachedItems,
      items,
      (_, _, element) => suggestionFor(element),
    );
    return items;
  });

  /// Resolves [value] from [cachedItems].
  ///
  /// Returns `null` if the value has not been seeded or observed in a successful
  /// query.
  @override
  T? resolve(T value) => _resolveByValue(
    cachedItems,
    value,
    (_, _, element) => suggestionFor(element),
  );
}

/// A local-first source that can progressively augment matches from a remote source.
///
/// Use this class when the UI should be able to show local matches immediately
/// and fetch more results only when the local result set is too small. For
/// concise construction, prefer [SuperAutoSuggestionSources.hybrid].
///
/// ---
/// ### Local matching
///
/// `initialItems` seed [cachedItems] and are searchable immediately. Local
/// matching uses [match] and [caseSensitive] against the suggestion's
/// `displayText` and `keywords`.
///
/// A remote request is eligible only when both conditions are true:
///
/// * the trimmed query length is at least [remoteMinChars]; and
/// * the local result count is **less than** [remoteThreshold].
///
/// The threshold is exclusive: with `remoteThreshold: 3`, a remote request is
/// considered for 0, 1, or 2 local matches, but not for 3 local matches.
///
/// ---
/// ### Progressive loading
///
/// `progressive` returns the local matches immediately. When a remote request is
/// eligible, its `loadMore` callback fetches and merges the remote items.
/// Remote values are de-duplicated by suggestion `value`, appended to
/// [cachedItems], and merged after the local results.
///
/// Ordinary `query` uses the same local/remote decision but falls back to the
/// local result if the remote fetch fails. A failure produced by the
/// progressive `loadMore` future is not swallowed by this source.
///
/// ---
/// ### Resolution
///
/// `resolve` searches [cachedItems], so both initial and previously fetched
/// values can be restored.
///
/// ---
/// Example:
///
/// ```dart
/// final source = SuperAutoHybridSuggestionsSource<Product>(
///   initialItems: popularProducts,
///   fetch: (query) => productRepository.search(query),
///   match: AutoSuggestionMatch.contains,
///   remoteThreshold: 3,
///   remoteMinChars: 2,
/// );
///
/// SuperAutoSuggestionsBox<Product>(
///   source: source,
///   suggestionBuilder: (items, index, product) {
///     return SuperAutoSuggestionsItem<Product>(
///       value: product,
///       displayText: product.name,
///       keywords: [product.sku],
///     );
///   },
/// );
/// ```
class SuperAutoHybridSuggestionsSource<T>
    extends SuperAutoSuggestionsSource<T> {
  /// Creates a source that combines an initial local cache with [fetch].
  ///
  /// [initialItems] are immediately searchable. [remoteThreshold] is an
  /// exclusive local-result threshold and [remoteMinChars] is evaluated against
  /// the trimmed query before a remote request is considered.
  SuperAutoHybridSuggestionsSource({
    required List<T> initialItems,
    required this.fetch,
    this.match = AutoSuggestionMatch.contains,
    this.remoteThreshold = 1,
    this.remoteMinChars = 1,
    this.caseSensitive = false,
  }) : cachedItems = List<T>.of(initialItems);

  /// Local and previously fetched values available for matching and resolution.
  ///
  /// Remote values are de-duplicated by suggestion `value` before insertion.
  final List<T> cachedItems;

  /// Loads additional remote values when the threshold rules allow it.
  final Future<List<T>> Function(String query) fetch;

  /// The strategy used for local matching.
  final AutoSuggestionMatch match;

  /// The exclusive local-result threshold for remote lookup.
  ///
  /// Remote fetching is eligible when `local.length < remoteThreshold`.
  final int remoteThreshold;

  /// The minimum trimmed query length required before remote lookup.
  final int remoteMinChars;

  /// Whether local matching distinguishes upper- and lower-case text.
  final bool caseSensitive;

  /// Whether this source can perform asynchronous work.
  @override
  bool get isAsync => true;

  List<T> _local(String query) => _localMatches(
    items: cachedItems,
    suggestionBuilder: (items, index, element) => suggestionAt(items, index),
    query: query,
    match: match,
    caseSensitive: caseSensitive,
  );

  bool _shouldFetch(String query, List<T> local) =>
      query.trim().length >= remoteMinChars && local.length < remoteThreshold;

  /// Returns local matches and, when eligible, merges remote matches.
  ///
  /// Remote failures are converted to the already-computed local result.
  @override
  FutureOr<List<T>> query(String query) {
    final local = _local(query);
    if (!_shouldFetch(query, local)) {
      return local;
    }
    return _fetchAndMerge(local, query).catchError((Object _) => local);
  }

  /// Returns local matches immediately and an optional remote `loadMore` step.
  ///
  /// When no remote request is eligible, the result is already complete.
  @override
  SuggestionsQueryResult<T> progressive(String query) {
    final local = _local(query);
    if (!_shouldFetch(query, local)) {
      return SuggestionsQueryResult<T>.complete(local);
    }
    return SuggestionsQueryResult<T>(
      items: local,
      loadMore: () => _fetchAndMerge(local, query),
    );
  }

  Future<List<T>> _fetchAndMerge(List<T> local, String query) =>
      fetch(query).then((remote) {
        _appendUniqueByValue(
          cachedItems,
          remote,
          (_, _, element) => suggestionFor(element),
        );
        return _mergeUniqueByValue(
          local,
          remote,
          (_, _, element) => suggestionFor(element),
        );
      });

  /// Resolves [value] from the current local/remote cache.
  @override
  T? resolve(T value) => _resolveByValue(
    cachedItems,
    value,
    (_, _, element) => suggestionFor(element),
  );
}

/// A local-first source that uses remote search as a fallback for sparse results.
///
/// Use this class when local data should satisfy common queries and the remote
/// source should be consulted only when too few local matches are available.
/// For concise construction, prefer
/// [SuperAutoSuggestionSources.remoteFallback].
///
/// ---
/// ### Local matching
///
/// `initialItems` seed [cachedItems]. Local matching uses [match] and
/// [caseSensitive] against the suggestion's `displayText` and `keywords`.
///
/// A remote request is eligible only when both conditions are true:
///
/// * the trimmed query length is at least [remoteMinChars]; and
/// * the local result count is **less than or equal to** [remoteThreshold].
///
/// The threshold is inclusive. This differs from
/// [SuperAutoHybridSuggestionsSource], which fetches only when the local count
/// is strictly less than its threshold.
///
/// ---
/// ### Progressive loading
///
/// `progressive` exposes local matches immediately and supplies a `loadMore`
/// callback when the remote fallback is eligible. Remote items are
/// de-duplicated by suggestion `value`, appended to [cachedItems], and merged
/// after the local results.
///
/// Ordinary `query` falls back to the local result when [fetch] fails. Errors
/// from the progressive `loadMore` future remain visible to the consumer.
///
/// ---
/// ### Resolution
///
/// `resolve` searches [cachedItems], including both the original local values
/// and remote values fetched by earlier queries.
///
/// ---
/// Example:
///
/// ```dart
/// final source = SuperAutoRemoteFallbackSuggestionsSource<Customer>(
///   initialItems: recentCustomers,
///   fetch: (query) => customerRepository.search(query),
///   remoteThreshold: 5,
///   remoteMinChars: 2,
/// );
///
/// SuperAutoSuggestionsBox<Customer>(
///   source: source,
///   suggestionBuilder: (items, index, customer) {
///     return SuperAutoSuggestionsItem<Customer>(
///       value: customer,
///       displayText: customer.name,
///     );
///   },
/// );
/// ```
class SuperAutoRemoteFallbackSuggestionsSource<T>
    extends SuperAutoSuggestionsSource<T> {
  /// Creates a local-first source with a remote fallback provided by [fetch].
  ///
  /// [initialItems] are immediately searchable. [remoteThreshold] is an
  /// inclusive local-result threshold and [remoteMinChars] is evaluated against
  /// the trimmed query before a remote request is considered.
  SuperAutoRemoteFallbackSuggestionsSource({
    required List<T> initialItems,
    required this.fetch,
    this.match = AutoSuggestionMatch.contains,
    this.remoteThreshold = 5,
    this.remoteMinChars = 1,
    this.caseSensitive = false,
  }) : cachedItems = List<T>.of(initialItems);

  /// Local and previously fetched values available for matching and resolution.
  ///
  /// Remote values are de-duplicated by suggestion `value` before insertion.
  final List<T> cachedItems;

  /// Loads remote fallback values when local results are sparse enough.
  final Future<List<T>> Function(String query) fetch;

  /// The strategy used for local matching.
  final AutoSuggestionMatch match;

  /// The inclusive local-result threshold for remote fallback.
  ///
  /// Remote fetching is eligible when `local.length <= remoteThreshold`.
  final int remoteThreshold;

  /// The minimum trimmed query length required before remote fallback.
  final int remoteMinChars;

  /// Whether local matching distinguishes upper- and lower-case text.
  final bool caseSensitive;

  /// Whether this source can perform asynchronous work.
  @override
  bool get isAsync => true;

  List<T> _local(String query) => _localMatches(
    items: cachedItems,
    suggestionBuilder: (items, index, element) => suggestionAt(items, index),
    query: query,
    match: match,
    caseSensitive: caseSensitive,
  );

  bool _shouldFetch(String query, List<T> local) =>
      query.trim().length >= remoteMinChars && local.length <= remoteThreshold;

  /// Returns local matches and, when eligible, merges remote fallback matches.
  ///
  /// Remote failures are converted to the already-computed local result.
  @override
  FutureOr<List<T>> query(String query) {
    final local = _local(query);
    if (!_shouldFetch(query, local)) {
      return local;
    }
    return _fetchAndMerge(local, query).catchError((Object _) => local);
  }

  /// Returns local matches immediately and an optional remote `loadMore` step.
  ///
  /// When no fallback request is eligible, the result is already complete.
  @override
  SuggestionsQueryResult<T> progressive(String query) {
    final local = _local(query);
    if (!_shouldFetch(query, local)) {
      return SuggestionsQueryResult<T>.complete(local);
    }
    return SuggestionsQueryResult<T>(
      items: local,
      loadMore: () => _fetchAndMerge(local, query),
    );
  }

  Future<List<T>> _fetchAndMerge(List<T> local, String query) =>
      fetch(query).then((remote) {
        _appendUniqueByValue(
          cachedItems,
          remote,
          (_, _, element) => suggestionFor(element),
        );
        return _mergeUniqueByValue(
          local,
          remote,
          (_, _, element) => suggestionFor(element),
        );
      });

  /// Resolves [value] from the current local/remote cache.
  @override
  T? resolve(T value) => _resolveByValue(
    cachedItems,
    value,
    (_, _, element) => suggestionFor(element),
  );
}

/// An asynchronous suggestion source backed by a zero-based page loader.
///
/// Use this class when the backing API exposes explicit pages and the UI should
/// request additional pages incrementally. For concise construction, prefer
/// [SuperAutoSuggestionSources.paged].
///
/// ---
/// ### Paging behavior
///
/// [fetch] receives the current query and a zero-based page index. Page `0` is
/// the first page. The callback returns a [SuperSuggestionsPage] containing the
/// page items and its `hasMore` state.
///
/// `query` loads only page `0`. Incremental consumers use `fetchPage` for later
/// pages. Every fetched page is appended to [cachedItems]. The source does not
/// de-duplicate items across pages; if the backing API can repeat rows, perform
/// de-duplication in [fetch] or the repository layer.
///
/// Errors from [fetch] propagate to the caller.
///
/// ---
/// ### Resolution
///
/// `resolveFrom` seeds [cachedItems] so an already-selected value can be
/// resolved before its page is loaded. `resolve` also searches all values from
/// pages fetched during the lifetime of this source.
///
/// ---
/// Example:
///
/// ```dart
/// final source = SuperAutoPagedSuggestionsSource<Product>(
///   (query, page) async {
///     final response = await productRepository.search(
///       query: query,
///       page: page,
///     );
///
///     return SuperSuggestionsPage<Product>(
///       items: response.items,
///       hasMore: response.hasMore,
///     );
///   },
///   resolveFrom: initiallySelectedProducts,
/// );
///
/// SuperAutoSuggestionsBox<Product>(
///   source: source,
///   suggestionBuilder: (items, index, product) {
///     return SuperAutoSuggestionsItem<Product>(
///       value: product,
///       displayText: product.name,
///     );
///   },
/// );
/// ```
class SuperAutoPagedSuggestionsSource<T> extends SuperAutoSuggestionsSource<T> {
  /// Creates a zero-based paged source that delegates page loading to [fetch].
  ///
  /// [resolveFrom] seeds [cachedItems] with values that may need to be resolved
  /// before their page has been fetched.
  SuperAutoPagedSuggestionsSource(this.fetch, {List<T> resolveFrom = const []})
    : cachedItems = List<T>.of(resolveFrom);

  /// Loads one zero-based page for a query.
  ///
  /// Page `0` is the first page. Errors propagate to `query` or `fetchPage`.
  final Future<SuperSuggestionsPage<T>> Function(String query, int page) fetch;

  /// Values retained from `resolveFrom` and all fetched pages.
  ///
  /// Page items are appended as returned and are not de-duplicated by this
  /// source.
  final List<T> cachedItems;

  /// Whether this source performs asynchronous queries.
  @override
  bool get isAsync => true;

  /// Whether this source supports explicit incremental page loading.
  @override
  bool get isPaged => true;

  /// Loads page `0` for [query] and returns that page's items.
  @override
  Future<List<T>> query(String query) =>
      fetchPage(query, 0).then((page) => page.items);

  /// Loads [page] for [query], caches its items, and returns the page result.
  ///
  /// [page] is zero-based. This method does not prevent duplicate values across
  /// pages.
  @override
  Future<SuperSuggestionsPage<T>> fetchPage(String query, int page) =>
      fetch(query, page).then((result) {
        cachedItems.addAll(result.items);
        return result;
      });

  /// Resolves [value] from seeded values and all previously fetched pages.
  @override
  T? resolve(T value) => _resolveByValue(
    cachedItems,
    value,
    (_, _, element) => suggestionFor(element),
  );
}
