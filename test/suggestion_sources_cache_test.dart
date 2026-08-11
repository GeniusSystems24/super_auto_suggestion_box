import 'package:flutter_test/flutter_test.dart';
import 'package:super_auto_suggestion_box/super_auto_suggestion_box.dart';

AutoSuggestion<String> _item(String value, [String? label]) =>
    AutoSuggestion<String>(value: value, label: label ?? value);

List<String> _values(Iterable<AutoSuggestion<String>> items) =>
    items.map((item) => item.value).toList();

void main() {
  group('AsyncSuggestionsSource cachedItems', () {
    test('copies initial items and accumulates unique fetched items', () async {
      final source = AsyncSuggestionsSource<String>(
        (_) async => [
          _item('b', 'Beta remote'),
          _item('c', 'Charlie'),
          _item('c', 'Charlie duplicate'),
        ],
        initialItems: [_item('a', 'Alpha'), _item('b', 'Beta')],
      );

      expect(_values(source.cachedItems), ['a', 'b']);

      final returned = await source.query('c');

      expect(_values(returned), ['b', 'c', 'c']);
      expect(_values(source.cachedItems), ['a', 'b', 'c']);
      expect(source.resolve('c')?.label, 'Charlie');
    });
  });

  group('HybridSuggestionsSource cachedItems', () {
    test('reuses fetched items locally without a second fetch', () async {
      var fetchCount = 0;
      final source = HybridSuggestionsSource<String>(
        initialItems: [_item('a', 'Alpha')],
        remoteThreshold: 1,
        remoteMinChars: 1,
        fetch: (_) async {
          fetchCount++;
          return [_item('b', 'Beta'), _item('b', 'Beta duplicate')];
        },
      );

      final first = await source.query('bet');

      expect(fetchCount, 1);
      expect(_values(first), ['b']);
      expect(_values(source.cachedItems), ['a', 'b']);
      expect(source.resolve('b')?.label, 'Beta');

      final second = source.query('bet');

      expect(second, isA<List<AutoSuggestion<String>>>());
      expect(_values(second as List<AutoSuggestion<String>>), ['b']);
      expect(fetchCount, 1);
    });
  });

  group('RemoteFallbackSuggestionsSource cachedItems', () {
    test('reuses fetched items through progressive local results', () async {
      var fetchCount = 0;
      final source = RemoteFallbackSuggestionsSource<String>(
        initialItems: [_item('a', 'Alpha')],
        remoteThreshold: 0,
        remoteMinChars: 1,
        fetch: (_) async {
          fetchCount++;
          return [_item('b', 'Beta'), _item('b', 'Beta duplicate')];
        },
      );

      final first = source.progressive('bet');
      expect(first.items, isEmpty);
      expect(first.loadMore, isNotNull);

      final loaded = await first.loadMore!();

      expect(fetchCount, 1);
      expect(_values(loaded), ['b']);
      expect(_values(source.cachedItems), ['a', 'b']);
      expect(source.resolve('b')?.label, 'Beta');

      final second = source.progressive('bet');

      expect(second.loadMore, isNull);
      expect(_values(second.items), ['b']);
      expect(fetchCount, 1);
    });
  });
}
