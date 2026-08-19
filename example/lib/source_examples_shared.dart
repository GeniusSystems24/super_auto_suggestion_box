import 'package:flutter/material.dart';
import 'package:super_auto_suggestion_box/super_auto_suggestion_box.dart';

/// Every built-in source gets its own route while sharing the same scenario
/// gallery, making source behavior easy to compare.
enum ExampleSourceType {
  strings('String source', 'Label-equals-value convenience source'),
  list('List source', 'In-memory contains matching'),
  fuzzy('Fuzzy source', 'Typo-tolerant in-memory ranking'),
  asyncSource('Async source', 'Server-style asynchronous lookup'),
  hybrid('Hybrid source', 'Immediate local results merged with remote data'),
  remoteFallback('Remote fallback', 'Local-first lookup with remote fallback'),
  paged('Paged source', 'Infinite scrolling through server pages');

  const ExampleSourceType(this.title, this.description);
  final String title;
  final String description;
}

class SourceExamplesView extends StatefulWidget {
  const SourceExamplesView({required this.type, super.key});

  final ExampleSourceType type;

  @override
  State<SourceExamplesView> createState() => _SourceExamplesViewState();
}

class _SourceExamplesViewState extends State<SourceExamplesView> {
  static const _items = <String>[
    'Cash on Hand',
    'Bank Operating',
    'Accounts Receivable',
    'Inventory',
    'Prepaid Expenses',
    'Accounts Payable',
    'VAT Payable',
    'Owner Equity',
    'Sales Revenue',
    'Service Revenue',
    'Cost of Goods Sold',
    'Salaries and Wages',
    'Office Supplies',
    'Travel Expense',
    'Utilities Expense',
    'Marketing Expense',
    'Equipment',
    'Accumulated Depreciation',
    'Retained Earnings',
    'Other Income',
  ];

  late final SuperAutoSuggestionsController<String> _controlled;
  late final SuperAutoSuggestionsController<String> _multiSelect;
  late final SuperAutoSuggestionsController<String> _recents;
  late final SuperAutoSuggestionsSource<String> _basicSource;
  late final SuperAutoSuggestionsSource<String> _controlledSource;
  late final SuperAutoSuggestionsSource<String> _multiSelectSource;
  late final SuperAutoSuggestionsSource<String> _recentsSource;

  @override
  void initState() {
    super.initState();
    _controlled = SuperAutoSuggestionsController<String>();
    _multiSelect = SuperAutoSuggestionsController<String>(
      initialSelected: const ['Cash on Hand'],
    );
    _recents = SuperAutoSuggestionsController<String>();
    _basicSource = _source();
    _controlledSource = _source();
    _multiSelectSource = _source();
    _recentsSource = _source();
  }

  @override
  void dispose() {
    _controlled.dispose();
    _multiSelect.dispose();
    _recents.dispose();
    super.dispose();
  }

  static SuperAutoSuggestionsItem<String> _suggestion(
    List<String> items,
    int index,
    String item,
  ) => SuperAutoSuggestionsItem<String>(
    value: item,
    titleText: item,
    description: Text('Account ${index + 1}'),
    icon: const Icon(Icons.account_balance_outlined),
    keywords: [item.replaceAll(' ', '')],
  );

  static List<String> _matches(String query) {
    final normalized = query.trim().toLowerCase();
    return _items
        .where(
          (item) =>
              normalized.isEmpty || item.toLowerCase().contains(normalized),
        )
        .toList();
  }

  SuperAutoSuggestionsSource<String> _source() {
    switch (widget.type) {
      case ExampleSourceType.strings:
        return SuperAutoSuggestionSources.strings(_items);
      case ExampleSourceType.list:
        return SuperAutoSuggestionSources.list<String>(_items);
      case ExampleSourceType.fuzzy:
        return SuperAutoSuggestionSources.fuzzy<String>(_items);
      case ExampleSourceType.asyncSource:
        return SuperAutoSuggestionSources.async<String>((query) async {
          await Future<void>.delayed(const Duration(milliseconds: 350));
          return _matches(query);
        }, initialItems: _items.take(5).toList());
      case ExampleSourceType.hybrid:
        return SuperAutoSuggestionSources.hybrid<String>(
          initialItems: _items.take(5).toList(),
          fetch: (query) async {
            await Future<void>.delayed(const Duration(milliseconds: 350));
            return _matches(query);
          },
          remoteThreshold: 6,
          remoteMinChars: 1,
        );
      case ExampleSourceType.remoteFallback:
        return SuperAutoSuggestionSources.remoteFallback<String>(
          initialItems: _items.take(5).toList(),
          fetch: (query) async {
            await Future<void>.delayed(const Duration(milliseconds: 350));
            return _matches(query);
          },
          remoteThreshold: 6,
          remoteMinChars: 1,
        );
      case ExampleSourceType.paged:
        return SuperAutoSuggestionSources.paged<String>((query, page) async {
          await Future<void>.delayed(const Duration(milliseconds: 350));
          final matches = _matches(query);
          const pageSize = 5;
          final start = page * pageSize;
          final pageItems = start >= matches.length
              ? <String>[]
              : matches.skip(start).take(pageSize).toList();
          return SuperSuggestionsPage<String>(
            items: pageItems,
            hasMore: start + pageItems.length < matches.length,
          );
        }, resolveFrom: _items);
    }
  }

  Widget _scenario({
    required String title,
    required String description,
    required SuperMarker marker,
    required Widget child,
  }) => SuperSectionCard2(
    collapsible: false,
    title: title,
    subtitle: description,
    marker: context.superTheme.tokens.markerColor(marker),
    child: child,
  );

  @override
  Widget build(BuildContext context) {
    final theme = context.superTheme;
    final typography = context.superTextTheme;
    final spacing = theme.spacing;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: SuperAppBar(
        title: Text(widget.type.title),
        subtitle: Text(
          'SOURCE EXAMPLE',
          style: typography.eyebrow.copyWith(color: colorScheme.primary),
        ),
      ),
      body: SingleChildScrollView(
        child: SuperScaffold(
          maxWidth: 1120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'v1.3.1 · ${widget.type.title.toUpperCase()}',
                style: typography.eyebrow.copyWith(color: colorScheme.primary),
              ),
              SizedBox(height: spacing.space2),
              Text(
                widget.type.description,
                style: typography.h1.copyWith(color: theme.fg1),
              ),
              SizedBox(height: spacing.space8),
              _scenario(
                title: 'Basic Lookup',
                description: 'The widget owns the source and controller.',
                marker: SuperMarker.identity,
                child: SuperAutoSuggestionsBox<String>(
                  source: _basicSource,
                  suggestionBuilder: _suggestion,
                  decoration: const InputDecoration(labelText: 'Account'),
                  hintText: 'Search accounts...',
                ),
              ),
              SizedBox(height: spacing.section),
              _scenario(
                title: 'External Controller',
                description:
                    'Read selection and control the field from host code.',
                marker: SuperMarker.notes,
                child: SuperAutoSuggestionsBox<String>(
                  source: _controlledSource,
                  controller: _controlled,
                  suggestionBuilder: _suggestion,
                  decoration: const InputDecoration(
                    labelText: 'Controlled Account',
                  ),
                  hintText: 'Host-controlled lookup...',
                ),
              ),
              SizedBox(height: spacing.section),
              _scenario(
                title: 'Multi-select',
                description:
                    'Select several raw values from the same source type.',
                marker: SuperMarker.ledger,
                child: SuperAutoSuggestionsBox<String>(
                  source: _multiSelectSource,
                  controller: _multiSelect,
                  suggestionBuilder: _suggestion,
                  multiSelect: true,
                  decoration: const InputDecoration(labelText: 'Accounts'),
                  hintText: 'Select accounts...',
                ),
              ),
              SizedBox(height: spacing.section),
              _scenario(
                title: 'Recent Selections',
                description:
                    'Committed values are pinned when the query is empty.',
                marker: SuperMarker.identity,
                child: SuperAutoSuggestionsBox<String>(
                  source: _recentsSource,
                  controller: _recents,
                  suggestionBuilder: _suggestion,
                  showRecents: true,
                  maxRecents: 4,
                  decoration: const InputDecoration(
                    labelText: 'Recent Accounts',
                  ),
                  hintText: 'Pick an account...',
                ),
              ),
              SizedBox(height: spacing.section),
            ],
          ),
        ),
      ),
    );
  }
}
