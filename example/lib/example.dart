import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:super_auto_suggestion_box/super_auto_suggestion_box.dart';

class TryExampleScreen extends StatelessWidget {
  const TryExampleScreen({super.key});

  static const List<String> documentReferences = [
    'Anwar Abdullah',
    'Saeed Mohammed',
    'Mohammed Ali',
    'John Doe',
    'Jane Smith',
    'Ali Ahmed',
    'Fatima Zahra',
    'Sarah Johnson',
    'Emily Davis',
    'Sara Ali',
    'Ahmed Mohamed',
  ];

  static SuperAutoSuggestionsItem<String> _documentSuggestion(
    List<String> items,
    int index,
    String element,
  ) => SuperAutoSuggestionsItem<String>(
    value: element,
    titleText: element,
    description: Text('Directory entry ${index + 1}'),
    icon: const Icon(Icons.account_box_rounded),
  );

  static List<String> _matches(String query) {
    final q = query.trim().toLowerCase();
    return [
      for (final item in documentReferences)
        if (q.isEmpty || item.toLowerCase().contains(q)) item,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final sources = <String, SuperAutoSuggestionsSource<String>>{
      'list': SuperAutoSuggestionSources.list<String>(
        documentReferences,
        match: AutoSuggestionMatch.fuzzy,
        caseSensitive: false,
      ),
      'async': SuperAutoSuggestionSources.async<String>((query) async {
        debugPrint('Async source called with query: $query');
        await Future<void>.delayed(const Duration(seconds: 1));
        return _matches(query);
      }),
      'fuzzy': SuperAutoSuggestionSources.fuzzy<String>(
        documentReferences,
        caseSensitive: false,
      ),
      'paged': SuperAutoSuggestionSources.paged<String>((query, page) async {
        debugPrint('Paged source called with query: $query, page: $page');
        await Future<void>.delayed(const Duration(seconds: 1));
        final all = _matches(query);
        final items = all.skip(page * 5).take(5).toList();
        return SuperSuggestionsPage<String>(
          items: items,
          hasMore: (page + 1) * 5 < all.length,
        );
      }, resolveFrom: documentReferences),
      'hybrid': SuperAutoSuggestionSources.hybrid<String>(
        fetch: (query) async {
          debugPrint('Hybrid source called with query: $query');
          await Future<void>.delayed(const Duration(seconds: 1));
          return _matches(query);
        },
        caseSensitive: false,
        initialItems: documentReferences.take(3).toList(),
        remoteMinChars: 3,
        remoteThreshold: 5,
      ),
      'remoteFallback': SuperAutoSuggestionSources.remoteFallback<String>(
        fetch: (query) async {
          debugPrint('Remote fallback source called with query: $query');
          await Future<void>.delayed(const Duration(seconds: 1));
          return _matches(query);
        },
        caseSensitive: false,
        initialItems: documentReferences.take(3).toList(),
        remoteMinChars: 3,
        remoteThreshold: 5,
      ),
    };
    final source = sources['remoteFallback']!;

    return Scaffold(
      appBar: AppBar(title: const Text('Example Screen')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 8,
        children: [
          SuperAutoSuggestionsBox<String>(
            source: source,
            suggestionBuilder: _documentSuggestion,
            controller: SuperAutoSuggestionsController<String>(),
            decoration: const InputDecoration(
              labelText: 'Document Reference',
              prefixIcon: Icon(Icons.account_box_rounded),
            ),
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            onSelectionChanged: (items) {
              debugPrint(
                items.isEmpty
                    ? 'Selection cleared'
                    : 'Selected: ${items.last} of ${items.length} items',
              );
            },
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Document Reference'),
            keyboardType: TextInputType.text,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9-]')),
              LengthLimitingTextInputFormatter(16),
            ],
            textInputAction: TextInputAction.done,
            keyboardAppearance: Brightness.dark,
            enableSuggestions: false,
            enableIMEPersonalizedLearning: false,
            maxLength: 16,
          ),
        ],
      ),
    );
  }
}
