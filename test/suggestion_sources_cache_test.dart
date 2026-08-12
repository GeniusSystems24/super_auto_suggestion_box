import 'package:flutter_test/flutter_test.dart';
import 'package:super_auto_suggestion_box/super_auto_suggestion_box.dart';

List<String> _values(Iterable<String> items) => items.toList();

void main() {
  group('AsyncSuggestionsSource cachedItems', () {
    test('copies initial items and accumulates unique fetched items', () async {
      final source = AsyncSuggestionsSource<String>(
        (_) async => ['b', 'c', 'c'],
        initialItems: ['a', 'b'],
      );

      expect(_values(source.cachedItems), ['a', 'b']);

      final returned = await source.query('c');

      expect(_values(returned), ['b', 'c', 'c']);
      expect(_values(source.cachedItems), ['a', 'b', 'c']);
      expect(source.resolve('c'), 'c');
      expect(source.suggestionFor(source.resolve('c')!).label, 'c');
    });
  });

  group('HybridSuggestionsSource cachedItems', () {
    test('reuses fetched items locally without a second fetch', () async {
      var fetchCount = 0;
      final source = HybridSuggestionsSource<String>(
        initialItems: ['a'],
        remoteThreshold: 1,
        remoteMinChars: 1,
        fetch: (_) async {
          fetchCount++;
          return ['b', 'b'];
        },
      );

      final first = await source.query('b');

      expect(fetchCount, 1);
      expect(_values(first), ['b']);
      expect(_values(source.cachedItems), ['a', 'b']);
      expect(source.resolve('b'), 'b');

      final second = source.query('b');

      expect(second, isA<List<String>>());
      expect(_values(second as List<String>), ['b']);
      expect(fetchCount, 1);
    });
  });

  group('RemoteFallbackSuggestionsSource cachedItems', () {
    test('reuses fetched items through progressive local results', () async {
      var fetchCount = 0;
      final source = RemoteFallbackSuggestionsSource<String>(
        initialItems: ['a'],
        remoteThreshold: 0,
        remoteMinChars: 1,
        fetch: (_) async {
          fetchCount++;
          return ['b', 'b'];
        },
      );

      final first = source.progressive('b');
      expect(first.items, isEmpty);
      expect(first.loadMore, isNotNull);

      final loaded = await first.loadMore!();

      expect(fetchCount, 1);
      expect(_values(loaded), ['b']);
      expect(_values(source.cachedItems), ['a', 'b']);
      expect(source.resolve('b'), 'b');

      final second = source.progressive('b');

      expect(second.loadMore, isNull);
      expect(_values(second.items), ['b']);
      expect(fetchCount, 1);
    });
  });
}
