import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_auto_suggestion_box/super_auto_suggestion_box.dart';

List<String> _values(Iterable<String> items) => items.toList();

Future<BuildContext> _pumpContext(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: SizedBox()));
  return tester.element(find.byType(SizedBox));
}

void main() {
  test('paged results use the renamed page type', () {
    const page = SuperSuggestionsPage<String>(
      items: ['A'],
      hasMore: true,
    );
    const lastPage = SuperSuggestionsPage<String>.last(['B']);
    const emptyPage = SuperSuggestionsPage<String>.empty();

    expect(page.items, ['A']);
    expect(page.hasMore, isTrue);
    expect(lastPage.hasMore, isFalse);
    expect(emptyPage.items, isEmpty);
  });

  testWidgets('source factories expose the renamed source contract', (tester) async {
    final context = await _pumpContext(tester);
    final SuperAutoSuggestionsSource<String> source =
        SuggestionSources.strings(const ['A']);

    expect(source.query(context, 'A'), ['A']);
  });

  test('suggestion items expose renamed display properties', () {
    const item = SuperAutoSuggestionsItem<String>(
      value: '1000',
      titleText: 'Cash',
      descriptionText: 'Current asset',
      trailingText: '12,400.00',
    );

    expect(item.titleText, 'Cash');
    expect(item.descriptionText, 'Current asset');
    expect(item.trailingText, '12,400.00');
    expect(item.iconData, isNull);
    expect(item.copyWith(titleText: 'Petty Cash').titleText, 'Petty Cash');

    const built = SuperAutoSuggestionsItem<String>(
      value: 'custom',
      titleText: ('Custom title'),
      description: Text('Custom description'),
      trailing: Chip(label: Text('Active')),
      icon: Icon(Icons.star),
    );
    expect(built.titleText, isNull);
    expect(built.description, isA<Text>());
    expect(built.trailing, isA<Chip>());
    expect(built.icon, isA<Icon>());
    expect(built.displayText, 'custom');
  });

  group('SuperAutoAsyncSuggestionsSource cachedItems', () {
    testWidgets('copies initial items and accumulates unique fetched items', (tester) async {
      final context = await _pumpContext(tester);
      final source = SuperAutoAsyncSuggestionsSource<String>(
        (_, _) async => ['b', 'c', 'c'],
        initialItems: ['a', 'b'],
      );

      expect(_values(source.cachedItems), ['a', 'b']);

      final returned = await source.query(context, 'c');

      expect(_values(returned), ['b', 'c', 'c']);
      expect(_values(source.cachedItems), ['a', 'b', 'c']);
      expect(source.resolve('c'), 'c');
      expect(source.suggestionFor(source.resolve('c')!).titleText, 'c');
    });
  });

  group('SuperAutoHybridSuggestionsSource cachedItems', () {
    testWidgets('reuses fetched items locally without a second fetch', (tester) async {
      final context = await _pumpContext(tester);
      var fetchCount = 0;
      final source = SuperAutoHybridSuggestionsSource<String>(
        initialItems: ['a'],
        remoteThreshold: 1,
        remoteMinChars: 1,
        fetch: (_, _) async {
          fetchCount++;
          return ['b', 'b'];
        },
      );

      final first = await source.query(context, 'b');

      expect(fetchCount, 1);
      expect(_values(first), ['b']);
      expect(_values(source.cachedItems), ['a', 'b']);
      expect(source.resolve('b'), 'b');

      final second = source.query(context, 'b');

      expect(second, isA<List<String>>());
      expect(_values(second as List<String>), ['b']);
      expect(fetchCount, 1);
    });
  });

  group('SuperAutoRemoteFallbackSuggestionsSource cachedItems', () {
    testWidgets('reuses fetched items through progressive local results', (tester) async {
      final context = await _pumpContext(tester);
      var fetchCount = 0;
      final source = SuperAutoRemoteFallbackSuggestionsSource<String>(
        initialItems: ['a'],
        remoteThreshold: 0,
        remoteMinChars: 1,
        fetch: (_, _) async {
          fetchCount++;
          return ['b', 'b'];
        },
      );

      final first = source.progressive(context, 'b');
      expect(first.items, isEmpty);
      expect(first.loadMore, isNotNull);

      final loaded = await first.loadMore!();

      expect(fetchCount, 1);
      expect(_values(loaded), ['b']);
      expect(_values(source.cachedItems), ['a', 'b']);
      expect(source.resolve('b'), 'b');

      final second = source.progressive(context, 'b');

      expect(second.loadMore, isNull);
      expect(_values(second.items), ['b']);
      expect(fetchCount, 1);
    });
  });
}
