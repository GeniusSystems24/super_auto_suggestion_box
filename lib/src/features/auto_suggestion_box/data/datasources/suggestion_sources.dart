// ============================================================
// features/auto_suggestion_box/data/datasources/suggestion_sources.dart
// ------------------------------------------------------------
// Concrete implementations of the domain `AutoSuggestionsSource` contract plus
// the `SuggestionSources` factory facade. Flavours:
//
//   • ListSuggestionsSource          — static, in-memory, filtered by [match]
//                                      (contains / prefix / words / fuzzy-ranked).
//   • AsyncSuggestionsSource          — any Future-returning search (debounced).
//   • HybridSuggestionsSource         — single-phase local-first; falls back to a
//                                      remote fetch and merges once.
//   • RemoteFallbackSuggestionsSource — progressive local-first: local rows shown
//                                      instantly, remote streamed in behind a
//                                      "loading more" indicator.
//   • PagedSuggestionsSource          — infinite scroll: one page per (query,page)
//                                      for large master data.
//
// Use the facade rather than the classes directly:
//   SuggestionSources.list · .strings · .fuzzy · .async · .hybrid ·
//   .remoteFallback · .paged
// ============================================================

import 'dart:async';

import '../../domain/entities/auto_suggestion.dart';
import '../../domain/entities/match_strategy.dart';
import '../../domain/entities/suggestions_page.dart';
import '../../domain/entities/suggestions_query_result.dart';
import '../../domain/repositories/suggestions_source.dart';

/// Factory facade for the built-in suggestion sources. Construct sources here;
/// the controller only ever sees the domain [AutoSuggestionsSource] contract.
abstract final class SuggestionSources {
  /// Static, in-memory list filtered locally by [match].
  static AutoSuggestionsSource<T> list<T>(
    List<AutoSuggestion<T>> items, {
    AutoSuggestionMatch match = AutoSuggestionMatch.contains,
    bool caseSensitive = false,
  }) => ListSuggestionsSource<T>(
    items,
    match: match,
    caseSensitive: caseSensitive,
  );

  /// A static source over plain strings (value == label).
  static AutoSuggestionsSource<String> strings(
    List<String> values, {
    AutoSuggestionMatch match = AutoSuggestionMatch.contains,
  }) => ListSuggestionsSource<String>([
    for (final v in values) AutoSuggestion<String>(value: v, label: v),
  ], match: match);

  /// A static, in-memory list ranked by **fuzzy** (subsequence) matching — type
  /// loosely (`acrv` → *Accounts Receivable*) and rows order by match quality
  /// (consecutive runs + word-boundary hits rank first). Shorthand for
  /// `list(items, match: AutoSuggestionMatch.fuzzy)`.
  static AutoSuggestionsSource<T> fuzzy<T>(
    List<AutoSuggestion<T>> items, {
    bool caseSensitive = false,
  }) => ListSuggestionsSource<T>(
    items,
    match: AutoSuggestionMatch.fuzzy,
    caseSensitive: caseSensitive,
  );

  /// Async source — any `Future`-returning search (debounced by the controller).
  static AutoSuggestionsSource<T> async<T>(
    Future<List<AutoSuggestion<T>>> Function(String query) fetch,
  ) => AsyncSuggestionsSource<T>(fetch);

  /// Hybrid source: filter the in-memory [initialItems] first and, when the
  /// local matches are insufficient, fall back to an async [fetch] (remote
  /// search) — merging the two, de-duplicated by value.
  ///
  /// `fetch` only fires when the local match count is below [remoteThreshold]
  /// (default 1 → fetch whenever nothing matches locally) AND the query is at
  /// least [remoteMinChars] long. Remote results are appended after the local
  /// ones. This is the single-phase "start with what we have, load more when we
  /// need it" behaviour: the field shows a spinner and resolves once. For the
  /// **progressive** variant (local rows shown instantly, remote streamed in
  /// behind a *loading more* indicator) use [remoteFallback] instead.
  static AutoSuggestionsSource<T> hybrid<T>({
    required List<AutoSuggestion<T>> initialItems,
    required Future<List<AutoSuggestion<T>>> Function(String query) fetch,
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

  /// Local-first with a **progressive remote fallback**: filter [initialItems]
  /// locally and show them instantly; when the local match count is
  /// [remoteThreshold] **or fewer** (and the query is at least [remoteMinChars]
  /// long), also fetch from [fetch] and merge the remote rows in afterwards,
  /// de-duplicated by value. Unlike [hybrid], the local rows are shown
  /// immediately and a "loading more" indicator sits above them while the
  /// remote call runs — the list never blanks behind a spinner.
  static AutoSuggestionsSource<T> remoteFallback<T>({
    required List<AutoSuggestion<T>> initialItems,
    required Future<List<AutoSuggestion<T>>> Function(String query) fetch,
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

  /// **Paged** remote source for large master data (infinite scroll). [fetch]
  /// returns one [SuggestionsPage] per `(query, page)` — the rows for that page
  /// plus a `hasMore` flag. The controller loads page 0 on each query and
  /// appends the next page as the user scrolls near the bottom of the overlay
  /// (`controller.hasMore` / `controller.isLoadingPage` / `loadNextPage()`).
  /// Use this instead of `.async` when a single response would be too large.
  static AutoSuggestionsSource<T> paged<T>(
    Future<SuggestionsPage<T>> Function(String query, int page) fetch, {
    List<AutoSuggestion<T>> resolveFrom = const [],
  }) => PagedSuggestionsSource<T>(fetch, resolveFrom: resolveFrom);
}

/// Static, in-memory list filtered locally by [match].
class ListSuggestionsSource<T> extends AutoSuggestionsSource<T> {
  final List<AutoSuggestion<T>> items;
  final AutoSuggestionMatch match;
  final bool caseSensitive;
  const ListSuggestionsSource(
    this.items, {
    this.match = AutoSuggestionMatch.contains,
    this.caseSensitive = false,
  });

  @override
  List<AutoSuggestion<T>> query(String query) {
    final q = caseSensitive ? query.trim() : query.trim().toLowerCase();
    if (q.isEmpty) return List<AutoSuggestion<T>>.of(items);
    final out = <AutoSuggestion<T>>[];
    for (final s in items) {
      final hay = caseSensitive
          ? ([s.label, ...s.keywords].join(' '))
          : s.haystack;
      if (AutoSuggestionMatching.test(hay, q, match)) out.add(s);
    }
    if (match == AutoSuggestionMatch.fuzzy) {
      // Fuzzy: rank by match quality (consecutive runs + word-boundary hits).
      String hayOf(AutoSuggestion<T> s) =>
          caseSensitive ? ([s.label, ...s.keywords].join(' ')) : s.haystack;
      out.sort((a, b) {
        final d = AutoSuggestionMatching.score(
          hayOf(b),
          q,
          match,
        ).compareTo(AutoSuggestionMatching.score(hayOf(a), q, match));
        return d != 0 ? d : a.label.length - b.label.length;
      });
      return out;
    }
    // Stable, relevance-ish ordering: prefix hits first, then by match index.
    out.sort((a, b) {
      final ha = caseSensitive ? a.label : a.label.toLowerCase();
      final hb = caseSensitive ? b.label : b.label.toLowerCase();
      final ia = ha.indexOf(q), ib = hb.indexOf(q);
      final ra = ia < 0 ? 1 << 20 : ia, rb = ib < 0 ? 1 << 20 : ib;
      if (ra != rb) return ra - rb;
      return ha.length - hb.length;
    });
    return out;
  }

  @override
  AutoSuggestion<T>? resolve(T value) {
    for (final s in items) {
      if (s.value == value) return s;
    }
    return null;
  }
}

/// Async source — any `Future`-returning search.
class AsyncSuggestionsSource<T> extends AutoSuggestionsSource<T> {
  final Future<List<AutoSuggestion<T>>> Function(String query) fetch;
  const AsyncSuggestionsSource(this.fetch);
  @override
  bool get isAsync => true;
  @override
  Future<List<AutoSuggestion<T>>> query(String query) => fetch(query);
}

/// Local-first source that loads more from [fetch] only when the in-memory set
/// can't satisfy the query (see [SuggestionSources.hybrid]).
class HybridSuggestionsSource<T> extends AutoSuggestionsSource<T> {
  final List<AutoSuggestion<T>> initialItems;
  final Future<List<AutoSuggestion<T>>> Function(String query) fetch;
  final AutoSuggestionMatch match;
  final int remoteThreshold;
  final int remoteMinChars;
  final bool caseSensitive;

  const HybridSuggestionsSource({
    required this.initialItems,
    required this.fetch,
    this.match = AutoSuggestionMatch.contains,
    this.remoteThreshold = 1,
    this.remoteMinChars = 1,
    this.caseSensitive = false,
  });

  @override
  bool get isAsync => true;

  List<AutoSuggestion<T>> _local(String query) {
    final q = caseSensitive ? query.trim() : query.trim().toLowerCase();
    if (q.isEmpty) return List<AutoSuggestion<T>>.of(initialItems);
    final out = <AutoSuggestion<T>>[];
    for (final s in initialItems) {
      final hay = caseSensitive
          ? ([s.label, ...s.keywords].join(' '))
          : s.haystack;
      if (AutoSuggestionMatching.test(hay, q, match)) out.add(s);
    }
    return out;
  }

  @override
  FutureOr<List<AutoSuggestion<T>>> query(String query) {
    final local = _local(query);
    final q = query.trim();
    // Enough local hits, or query too short to bother the network → stay local.
    if (local.length >= remoteThreshold || q.length < remoteMinChars) {
      return local;
    }
    // Otherwise load more and merge (local first, de-duped by value).
    return fetch(query)
        .then((remote) {
          final seen = <T>{for (final s in local) s.value};
          final merged = <AutoSuggestion<T>>[...local];
          for (final r in remote) {
            if (seen.add(r.value)) merged.add(r);
          }
          return merged;
        })
        .catchError((Object _) => local); // network failed → degrade to local
  }

  @override
  AutoSuggestion<T>? resolve(T value) {
    for (final s in initialItems) {
      if (s.value == value) return s;
    }
    return null;
  }
}

/// Local-first source with a **progressive** remote fallback (see
/// [SuggestionSources.remoteFallback]). Resolves via [progressive] so the box
/// shows local rows instantly and streams remote rows in behind a top spinner.
class RemoteFallbackSuggestionsSource<T> extends AutoSuggestionsSource<T> {
  final List<AutoSuggestion<T>> initialItems;
  final Future<List<AutoSuggestion<T>>> Function(String query) fetch;
  final AutoSuggestionMatch match;
  final int remoteThreshold;
  final int remoteMinChars;
  final bool caseSensitive;

  const RemoteFallbackSuggestionsSource({
    required this.initialItems,
    required this.fetch,
    this.match = AutoSuggestionMatch.contains,
    this.remoteThreshold = 5,
    this.remoteMinChars = 1,
    this.caseSensitive = false,
  });

  @override
  bool get isAsync => true;

  List<AutoSuggestion<T>> _local(String query) {
    final q = caseSensitive ? query.trim() : query.trim().toLowerCase();
    if (q.isEmpty) return List<AutoSuggestion<T>>.of(initialItems);
    final out = <AutoSuggestion<T>>[];
    for (final s in initialItems) {
      final hay = caseSensitive
          ? ([s.label, ...s.keywords].join(' '))
          : s.haystack;
      if (AutoSuggestionMatching.test(hay, q, match)) out.add(s);
    }
    return out;
  }

  // Single-phase fallback (used if a caller ignores [progressive]).
  @override
  FutureOr<List<AutoSuggestion<T>>> query(String query) {
    final r = progressive(query);
    if (r.loadMore == null) return r.items;
    return r.loadMore!()
        .then((remote) => _merge(r.items, remote))
        .catchError((Object _) => r.items);
  }

  @override
  SuggestionsQueryResult<T> progressive(String query) {
    final local = _local(query);
    final q = query.trim();
    final wantRemote =
        local.length <= remoteThreshold && q.length >= remoteMinChars;
    if (!wantRemote) return SuggestionsQueryResult<T>.complete(local);
    return SuggestionsQueryResult<T>(
      items: local,
      loadMore: () => fetch(query).then((remote) => _merge(local, remote)),
    );
  }

  List<AutoSuggestion<T>> _merge(
    List<AutoSuggestion<T>> local,
    List<AutoSuggestion<T>> remote,
  ) {
    final seen = <T>{for (final s in local) s.value};
    final merged = <AutoSuggestion<T>>[...local];
    for (final r in remote) {
      if (seen.add(r.value)) merged.add(r);
    }
    return merged;
  }

  @override
  AutoSuggestion<T>? resolve(T value) {
    for (final s in initialItems) {
      if (s.value == value) return s;
    }
    return null;
  }
}

/// **Paged** remote source (infinite scroll) for large ERP master data. Serves
/// one [SuggestionsPage] per `(query, page)`; the controller loads page 0 on
/// each query and appends the next page as the user scrolls (see
/// [SuggestionSources.paged]). Any items passed as [resolveFrom] (e.g. the rows
/// already loaded for the bound record) let `selectByValue` resolve a stored id
/// to its label without a round-trip.
class PagedSuggestionsSource<T> extends AutoSuggestionsSource<T> {
  final Future<SuggestionsPage<T>> Function(String query, int page) fetch;
  final List<AutoSuggestion<T>> resolveFrom;
  const PagedSuggestionsSource(this.fetch, {this.resolveFrom = const []});

  @override
  bool get isAsync => true;

  @override
  bool get isPaged => true;

  @override
  Future<SuggestionsPage<T>> fetchPage(String query, int page) =>
      fetch(query, page);

  /// The single-phase [query] returns page 0 only — so the source still works if
  /// a host ignores pagination (the controller uses [fetchPage] for the rest).
  @override
  Future<List<AutoSuggestion<T>>> query(String query) =>
      fetch(query, 0).then((p) => p.items);

  @override
  AutoSuggestion<T>? resolve(T value) {
    for (final s in resolveFrom) {
      if (s.value == value) return s;
    }
    return null;
  }
}
