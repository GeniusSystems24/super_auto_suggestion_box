import 'dart:async';

import '../../domain/entities/super_auto_suggestions_item.dart';
import '../../domain/entities/match_strategy.dart';
import '../../domain/entities/super_suggestions_page.dart';
import '../../domain/entities/suggestions_query_result.dart';
import '../../domain/repositories/super_auto_suggestions_source.dart';

/// Factory helpers for common suggestion data source patterns.
abstract final class SuggestionSources {
  /// Creates an in-memory source backed by raw [items].
  static SuperAutoSuggestionsSource<T> list<T>(
    List<T> items, {
    AutoSuggestionMatch match = AutoSuggestionMatch.contains,
    bool caseSensitive = false,
  }) => ListSuggestionsSource<T>(
    items,
    match: match,
    caseSensitive: caseSensitive,
  );

  /// Creates a convenience string source where the label and value are equal.
  static SuperAutoSuggestionsSource<String> strings(
    List<String> values, {
    AutoSuggestionMatch match = AutoSuggestionMatch.contains,
  }) => ListSuggestionsSource<String>(values, match: match);

  /// Creates an in-memory source that uses fuzzy matching.
  static SuperAutoSuggestionsSource<T> fuzzy<T>(
    List<T> items, {
    bool caseSensitive = false,
  }) => ListSuggestionsSource<T>(
    items,
    match: AutoSuggestionMatch.fuzzy,
    caseSensitive: caseSensitive,
  );

  /// Creates an async source backed by [fetch].
  static SuperAutoSuggestionsSource<T> async<T>(
    Future<List<T>> Function(String query) fetch, {
    List<T> initialItems = const [],
  }) => AsyncSuggestionsSource<T>(fetch, initialItems: initialItems);

  /// Creates a source that returns local matches immediately and can then merge
  /// remote results when [remoteThreshold] and [remoteMinChars] allow it.
  static SuperAutoSuggestionsSource<T> hybrid<T>({
    required List<T> initialItems,
    required Future<List<T>> Function(String query) fetch,
    AutoSuggestionMatch match = AutoSuggestionMatch.contains,
    int remoteThreshold = 1,
    int remoteMinChars = 1,
    bool caseSensitive = false,
  }) => HybridSuggestionsSource<T>(
    initialItems: initialItems,
    fetch: fetch,
    match: match,
    remoteThreshold: remoteThreshold,
    remoteMinChars: remoteMinChars,
    caseSensitive: caseSensitive,
  );

  /// Creates a source that uses local data first and falls back to remote
  /// fetching when local matches are below [remoteThreshold].
  static SuperAutoSuggestionsSource<T> remoteFallback<T>({
    required List<T> initialItems,
    required Future<List<T>> Function(String query) fetch,
    AutoSuggestionMatch match = AutoSuggestionMatch.contains,
    int remoteThreshold = 5,
    int remoteMinChars = 1,
    bool caseSensitive = false,
  }) => RemoteFallbackSuggestionsSource<T>(
    initialItems: initialItems,
    fetch: fetch,
    match: match,
    remoteThreshold: remoteThreshold,
    remoteMinChars: remoteMinChars,
    caseSensitive: caseSensitive,
  );

  /// Creates a paged source backed by [fetch].
  static SuperAutoSuggestionsSource<T> paged<T>(
    Future<SuperSuggestionsPage<T>> Function(String query, int page) fetch, {
    List<T> resolveFrom = const [],
  }) => PagedSuggestionsSource<T>(fetch, resolveFrom: resolveFrom);
}

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

/// In-memory source backed by raw [items].
class ListSuggestionsSource<T> extends SuperAutoSuggestionsSource<T> {
  ListSuggestionsSource(
    this.items, {
    this.match = AutoSuggestionMatch.contains,
    this.caseSensitive = false,
  });

  final List<T> items;
  final AutoSuggestionMatch match;
  final bool caseSensitive;

  @override
  List<T> query(String query) => _localMatches(
    items: items,
    suggestionBuilder: (items, index, element) => suggestionAt(items, index),
    query: query,
    match: match,
    caseSensitive: caseSensitive,
  );

  @override
  T? resolve(T value) =>
      _resolveByValue(items, value, (_, _, element) => suggestionFor(element));
}

/// Async source backed by a fetch callback returning raw values.
class AsyncSuggestionsSource<T> extends SuperAutoSuggestionsSource<T> {
  AsyncSuggestionsSource(this.fetch, {List<T> initialItems = const []})
    : cachedItems = List<T>.of(initialItems);

  final Future<List<T>> Function(String query) fetch;
  final List<T> cachedItems;

  @override
  bool get isAsync => true;

  @override
  Future<List<T>> query(String query) => fetch(query).then((items) {
    _appendUniqueByValue(
      cachedItems,
      items,
      (_, _, element) => suggestionFor(element),
    );
    return items;
  });

  @override
  T? resolve(T value) => _resolveByValue(
    cachedItems,
    value,
    (_, _, element) => suggestionFor(element),
  );
}

/// Source that combines local results with remote results.
class HybridSuggestionsSource<T> extends SuperAutoSuggestionsSource<T> {
  HybridSuggestionsSource({
    required List<T> initialItems,
    required this.fetch,
    this.match = AutoSuggestionMatch.contains,
    this.remoteThreshold = 1,
    this.remoteMinChars = 1,
    this.caseSensitive = false,
  }) : cachedItems = List<T>.of(initialItems);

  final List<T> cachedItems;
  final Future<List<T>> Function(String query) fetch;
  final AutoSuggestionMatch match;
  final int remoteThreshold;
  final int remoteMinChars;
  final bool caseSensitive;

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

  @override
  FutureOr<List<T>> query(String query) {
    final local = _local(query);
    if (!_shouldFetch(query, local)) {
      return local;
    }
    return _fetchAndMerge(local, query).catchError((Object _) => local);
  }

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

  @override
  T? resolve(T value) => _resolveByValue(
    cachedItems,
    value,
    (_, _, element) => suggestionFor(element),
  );
}

/// Source that returns local matches and only requests remote fallback when
/// local matches are sparse.
class RemoteFallbackSuggestionsSource<T> extends SuperAutoSuggestionsSource<T> {
  RemoteFallbackSuggestionsSource({
    required List<T> initialItems,
    required this.fetch,
    this.match = AutoSuggestionMatch.contains,
    this.remoteThreshold = 5,
    this.remoteMinChars = 1,
    this.caseSensitive = false,
  }) : cachedItems = List<T>.of(initialItems);

  final List<T> cachedItems;
  final Future<List<T>> Function(String query) fetch;
  final AutoSuggestionMatch match;
  final int remoteThreshold;
  final int remoteMinChars;
  final bool caseSensitive;

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

  @override
  FutureOr<List<T>> query(String query) {
    final local = _local(query);
    if (!_shouldFetch(query, local)) {
      return local;
    }
    return _fetchAndMerge(local, query).catchError((Object _) => local);
  }

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

  @override
  T? resolve(T value) => _resolveByValue(
    cachedItems,
    value,
    (_, _, element) => suggestionFor(element),
  );
}

/// Source backed by page-based fetching.
class PagedSuggestionsSource<T> extends SuperAutoSuggestionsSource<T> {
  PagedSuggestionsSource(this.fetch, {List<T> resolveFrom = const []})
    : cachedItems = List<T>.of(resolveFrom);

  final Future<SuperSuggestionsPage<T>> Function(String query, int page) fetch;
  final List<T> cachedItems;

  @override
  bool get isAsync => true;

  @override
  bool get isPaged => true;

  @override
  Future<List<T>> query(String query) =>
      fetchPage(query, 0).then((page) => page.items);

  @override
  Future<SuperSuggestionsPage<T>> fetchPage(String query, int page) =>
      fetch(query, page).then((result) {
        cachedItems.addAll(result.items);
        return result;
      });

  @override
  T? resolve(T value) => _resolveByValue(
    cachedItems,
    value,
    (_, _, element) => suggestionFor(element),
  );
}
