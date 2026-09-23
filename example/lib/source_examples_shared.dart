import 'package:flutter/material.dart';
import 'package:super_auto_suggestion_box/super_auto_suggestion_box.dart';
import 'package:super_auto_suggestion_box_example/localizations/generated/l10n.dart';

/// Every built-in source gets its own route while sharing the same scenario
/// gallery, making source behavior easy to compare.
enum ExampleSourceType {
  strings,
  list,
  fuzzy,
  asyncSource,
  hybrid,
  remoteFallback,
  paged;

  String title(SuperExampleLocalization l10n) => switch (this) {
    ExampleSourceType.strings => l10n.stringSource,
    ExampleSourceType.list => l10n.listSource,
    ExampleSourceType.fuzzy => l10n.fuzzySource,
    ExampleSourceType.asyncSource => l10n.asyncSource,
    ExampleSourceType.hybrid => l10n.hybridSource,
    ExampleSourceType.remoteFallback => l10n.remoteFallback,
    ExampleSourceType.paged => l10n.pagedSource,
  };

  String description(SuperExampleLocalization l10n) => switch (this) {
    ExampleSourceType.strings => l10n.stringSourceDescription,
    ExampleSourceType.list => l10n.listSourceDescription,
    ExampleSourceType.fuzzy => l10n.fuzzySourceDescription,
    ExampleSourceType.asyncSource => l10n.asyncSourceDescription,
    ExampleSourceType.hybrid => l10n.hybridSourceDescription,
    ExampleSourceType.remoteFallback => l10n.remoteFallbackDescription,
    ExampleSourceType.paged => l10n.pagedSourceDescription,
  };
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

  SuperAutoSuggestionsItem<String> _suggestion(
    BuildContext context,
    List<String> items,
    int index,
    String item,
  ) {
    final l10n = SuperExampleLocalization.of(context);
    return SuperAutoSuggestionsItem<String>(
      value: item,
      titleText: item,
      description: Text(l10n.accountNumber(index + 1)),
      icon: const Icon(Icons.account_balance_outlined),
      keywords: [item.replaceAll(' ', '')],
    );
  }

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
        return SuperAutoSuggestionSources.async<String>((context, query) async {
          await Future<void>.delayed(const Duration(milliseconds: 350));
          return _matches(query);
        }, initialItems: _items.take(5).toList());
      case ExampleSourceType.hybrid:
        return SuperAutoSuggestionSources.hybrid<String>(
          initialItems: _items.take(5).toList(),
          fetch: (context, query) async {
            await Future<void>.delayed(const Duration(milliseconds: 350));
            return _matches(query);
          },
          remoteThreshold: 6,
          remoteMinChars: 1,
        );
      case ExampleSourceType.remoteFallback:
        return SuperAutoSuggestionSources.remoteFallback<String>(
          initialItems: _items.take(5).toList(),
          fetch: (context, query) async {
            await Future<void>.delayed(const Duration(milliseconds: 350));
            return _matches(query);
          },
          remoteThreshold: 6,
          remoteMinChars: 1,
        );
      case ExampleSourceType.paged:
        return SuperAutoSuggestionSources.paged<String>((context, query, page) async {
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
    final l10n = SuperExampleLocalization.of(context);
    final theme = context.superTheme;
    final typography = context.superTextTheme;
    final spacing = theme.spacing;
    final colorScheme = Theme.of(context).colorScheme;
    final sourceTitle = widget.type.title(l10n);
    final sourceDescription = widget.type.description(l10n);

    return Scaffold(
      appBar: SuperAppBar(
        title: Text(sourceTitle),
        subtitle: Text(
          l10n.sourceExample,
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
                l10n.sourceVersion(sourceTitle.toUpperCase()),
                style: typography.eyebrow.copyWith(color: colorScheme.primary),
              ),
              SizedBox(height: spacing.space2),
              Text(
                sourceDescription,
                style: typography.h1.copyWith(color: theme.fg1),
              ),
              SizedBox(height: spacing.space8),
              _scenario(
                title: l10n.basicLookup,
                description: l10n.widgetOwnsSource,
                marker: SuperMarker.identity,
                child: SuperAutoSuggestionsBox<String>(
                  source: _basicSource,
                  suggestionBuilder: _suggestion,
                  decoration: InputDecoration(labelText: l10n.account),
                  hintText: l10n.searchAccounts,
                ),
              ),
              SizedBox(height: spacing.section),
              _scenario(
                title: l10n.externalController,
                description: l10n.controlFromHost,
                marker: SuperMarker.notes,
                child: SuperAutoSuggestionsBox<String>(
                  source: _controlledSource,
                  controller: _controlled,
                  suggestionBuilder: _suggestion,
                  decoration: InputDecoration(
                    labelText: l10n.controlledAccount,
                  ),
                  hintText: l10n.hostControlledLookup,
                ),
              ),
              SizedBox(height: spacing.section),
              _scenario(
                title: l10n.multiSelect,
                description: l10n.selectSeveralValues,
                marker: SuperMarker.ledger,
                child: SuperAutoSuggestionsBox<String>(
                  source: _multiSelectSource,
                  controller: _multiSelect,
                  suggestionBuilder: _suggestion,
                  multiSelect: true,
                  decoration: InputDecoration(labelText: l10n.accounts),
                  hintText: l10n.selectAccounts,
                ),
              ),
              SizedBox(height: spacing.section),
              _scenario(
                title: l10n.recentSelections,
                description: l10n.committedValuesPinned,
                marker: SuperMarker.identity,
                child: SuperAutoSuggestionsBox<String>(
                  source: _recentsSource,
                  controller: _recents,
                  suggestionBuilder: _suggestion,
                  showRecents: true,
                  maxRecents: 4,
                  decoration: InputDecoration(
                    labelText: l10n.recentAccounts,
                  ),
                  hintText: l10n.pickAccount,
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
