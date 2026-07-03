// ============================================================
// features/auto_suggestion_box/domain/entities/match_strategy.dart
// ------------------------------------------------------------
// The matching policy + its pure engine. [AutoSuggestionMatch] names the four
// strategies a query is tested with; [AutoSuggestionMatching] is the
// dependency-free implementation of *test* (does this query match?) and *spans*
// (where, for highlighting?). Shared by every data source and the view.
// ============================================================

import 'auto_suggestion.dart';

/// How a query string is tested against a suggestion's haystack.
enum AutoSuggestionMatch {
  /// Substring anywhere (default).
  contains,

  /// Haystack must start with the query.
  prefix,

  /// Every whitespace-separated token of the query must appear (any order).
  words,

  /// Subsequence/fuzzy — the query's characters appear in order, gaps allowed.
  fuzzy,
}

/// Pure matching + highlight helpers (shared by sources and the view).
class AutoSuggestionMatching {
  AutoSuggestionMatching._();

  /// Test a (already-cased) [haystack] against a (already-cased) [query].
  static bool test(String haystack, String query, AutoSuggestionMatch mode) {
    if (query.isEmpty) return true;
    switch (mode) {
      case AutoSuggestionMatch.contains:
        return haystack.contains(query);
      case AutoSuggestionMatch.prefix:
        return haystack.startsWith(query);
      case AutoSuggestionMatch.words:
        return query.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).every(haystack.contains);
      case AutoSuggestionMatch.fuzzy:
        return _isSubsequence(query, haystack);
    }
  }

  static bool _isSubsequence(String needle, String hay) {
    var i = 0;
    for (var j = 0; j < hay.length && i < needle.length; j++) {
      if (hay[j] == needle[i]) i++;
    }
    return i == needle.length;
  }

  /// A relevance score for ranking matches (higher = better; 0 = no match).
  /// Both arguments are already-cased. For prefix/contains/words it rewards an
  /// earlier, tighter hit; for fuzzy it rewards consecutive runs and matches at
  /// word boundaries — so `SuggestionSources.fuzzy` orders by match *quality*,
  /// not just insertion order.
  static double score(String haystack, String query, AutoSuggestionMatch mode) {
    if (query.isEmpty) return 1;
    if (!test(haystack, query, mode)) return 0;
    switch (mode) {
      case AutoSuggestionMatch.prefix:
        // Shorter haystacks rank first (the query is a larger fraction of them).
        return (1000 - (haystack.length - query.length).clamp(0, 999)).toDouble();
      case AutoSuggestionMatch.contains:
      case AutoSuggestionMatch.words:
        final at = haystack.indexOf(query);
        final idx = at < 0 ? 500 : at; // words: fall back to a mid rank
        return (1000 - idx * 2 - (haystack.length - query.length).clamp(0, 400) * 0.25).toDouble();
      case AutoSuggestionMatch.fuzzy:
        return _fuzzyScore(query, haystack);
    }
  }

  /// Subsequence score: +base per matched char, a bonus for consecutive runs and
  /// for hits at a word boundary (start / after a space, `_`, `-`, `.` or `/`),
  /// and a small penalty per gap. Normalised so a perfect prefix run scores high.
  static double _fuzzyScore(String needle, String hay) {
    const boundary = {' ', '_', '-', '.', '/', ':'};
    var score = 0.0;
    var i = 0, run = 0;
    for (var j = 0; j < hay.length && i < needle.length; j++) {
      if (hay[j] == needle[i]) {
        score += 8;
        run += 1;
        score += run * 4; // reward longer consecutive runs
        final atBoundary = j == 0 || boundary.contains(hay[j - 1]);
        if (atBoundary) score += 10;
        i++;
      } else {
        run = 0;
        score -= 1; // small penalty per skipped char
      }
    }
    if (i < needle.length) return 0; // not a full subsequence
    // Nudge shorter haystacks ahead when scores otherwise tie.
    return score + (100 - hay.length).clamp(0, 100) * 0.1;
  }

  /// Compute highlight spans of [query] within [label] for bolding. Returns the
  /// contiguous match for contains/prefix/words tokens, or per-character spans
  /// for fuzzy. Empty when nothing lines up.
  static List<HighlightSpan> spans(String label, String query, AutoSuggestionMatch mode) {
    if (query.trim().isEmpty) return const [];
    final lower = label.toLowerCase();
    final q = query.trim().toLowerCase();

    List<HighlightSpan> contiguous(String token) {
      final spans = <HighlightSpan>[];
      var from = 0;
      while (true) {
        final i = lower.indexOf(token, from);
        if (i < 0) break;
        spans.add(HighlightSpan(i, i + token.length));
        from = i + token.length;
      }
      return spans;
    }

    switch (mode) {
      case AutoSuggestionMatch.contains:
      case AutoSuggestionMatch.prefix:
        return contiguous(q);
      case AutoSuggestionMatch.words:
        final spans = <HighlightSpan>[];
        for (final t in q.split(RegExp(r'\s+')).where((t) => t.isNotEmpty)) {
          spans.addAll(contiguous(t));
        }
        spans.sort((a, b) => a.start - b.start);
        return _merge(spans);
      case AutoSuggestionMatch.fuzzy:
        final spans = <HighlightSpan>[];
        var i = 0;
        for (var j = 0; j < lower.length && i < q.length; j++) {
          if (lower[j] == q[i]) {
            spans.add(HighlightSpan(j, j + 1));
            i++;
          }
        }
        return i == q.length ? _merge(spans) : const [];
    }
  }

  static List<HighlightSpan> _merge(List<HighlightSpan> spans) {
    if (spans.length < 2) return spans;
    final out = <HighlightSpan>[spans.first];
    for (var k = 1; k < spans.length; k++) {
      final last = out.last;
      final s = spans[k];
      if (s.start <= last.end) {
        out[out.length - 1] = HighlightSpan(last.start, s.end > last.end ? s.end : last.end);
      } else {
        out.add(s);
      }
    }
    return out;
  }
}
