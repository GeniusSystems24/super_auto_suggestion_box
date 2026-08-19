import 'dart:async';

import 'package:flutter/material.dart';
import 'package:super_auto_suggestion_box/super_auto_suggestion_box.dart';

class SuperAutoSuggestionsItemScenariosScreen extends StatefulWidget {
  const SuperAutoSuggestionsItemScenariosScreen({super.key});

  @override
  State<SuperAutoSuggestionsItemScenariosScreen> createState() =>
      _SuperAutoSuggestionsItemScenariosScreenState();
}

class _SuperAutoSuggestionsItemScenariosScreenState
    extends State<SuperAutoSuggestionsItemScenariosScreen> {
  final StreamController<bool> _enabledController =
      StreamController<bool>.broadcast();

  bool _streamEnabled = true;

  static const _items = <_ScenarioItem>[
    _ScenarioItem('title', '01 · titleText'),
    _ScenarioItem('descriptionText', '02 · descriptionText'),
    _ScenarioItem('descriptionWidget', '03 · description widget'),
    _ScenarioItem('trailingText', '04 · trailingText'),
    _ScenarioItem('trailingWidget', '05 · trailing widget'),
    _ScenarioItem('iconData', '06 · iconData'),
    _ScenarioItem('iconWidget', '07 · icon widget'),
    _ScenarioItem('group', '08 · group'),
    _ScenarioItem('keywords', '09 · keywords'),
    _ScenarioItem('disabled', '10 · enabled = false'),
    _ScenarioItem('enabledSnapshot', '11 · enabledSnapshot'),
    _ScenarioItem('combined', '12 · combined rich item'),
  ];

  late final SuperAutoSuggestionsSource<_ScenarioItem> _source;

  @override
  void initState() {
    super.initState();
    _source = SuperAutoSuggestionSources.list<_ScenarioItem>(
      _items,
      match: AutoSuggestionMatch.contains,
      caseSensitive: false,
    );
  }

  @override
  void dispose() {
    _enabledController.close();
    super.dispose();
  }

  void _toggleStreamEnabled(bool value) {
    setState(() => _streamEnabled = value);
    _enabledController.add(value);
  }

  SuperAutoSuggestionsItem<_ScenarioItem> _suggestion(
    List<_ScenarioItem> items,
    int index,
    _ScenarioItem item,
  ) {
    switch (item.id) {
      case 'title':
        return SuperAutoSuggestionsItem<_ScenarioItem>(
          value: item,
          titleText: 'Plain title text',
        );

      case 'descriptionText':
        return SuperAutoSuggestionsItem<_ScenarioItem>(
          value: item,
          titleText: 'Description as text',
          descriptionText: 'descriptionText renders supporting plain text',
        );

      case 'descriptionWidget':
        return SuperAutoSuggestionsItem<_ScenarioItem>(
          value: item,
          titleText: 'Description as widget',
          description: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info_outline_rounded, size: 12),
              SizedBox(width: 4),
              Text('Custom description widget'),
            ],
          ),
        );

      case 'trailingText':
        return SuperAutoSuggestionsItem<_ScenarioItem>(
          value: item,
          titleText: 'Trailing text',
          trailingText: 'ERP-1042',
        );

      case 'trailingWidget':
        return SuperAutoSuggestionsItem<_ScenarioItem>(
          value: item,
          titleText: 'Trailing widget',
          trailing: const Chip(
            visualDensity: VisualDensity.compact,
            label: Text('ACTIVE'),
          ),
        );

      case 'iconData':
        return SuperAutoSuggestionsItem<_ScenarioItem>(
          value: item,
          titleText: 'IconData',
          iconData: Icons.inventory_2_outlined,
        );

      case 'iconWidget':
        return SuperAutoSuggestionsItem<_ScenarioItem>(
          value: item,
          titleText: 'Custom icon widget',
          icon: const CircleAvatar(radius: 10, child: Text('S')),
        );

      case 'group':
        return SuperAutoSuggestionsItem<_ScenarioItem>(
          value: item,
          titleText: 'Grouped suggestion',
          group: 'Metadata scenarios',
        );

      case 'keywords':
        return SuperAutoSuggestionsItem<_ScenarioItem>(
          value: item,
          titleText: 'Searchable aliases',
          descriptionText: 'Search for: invoice, vendor, INV-1042',
          keywords: const <String>['invoice', 'vendor', 'INV-1042'],
        );

      case 'disabled':
        return SuperAutoSuggestionsItem<_ScenarioItem>(
          value: item,
          titleText: 'Statically disabled',
          descriptionText: 'enabled: false',
          iconData: Icons.block_rounded,
          enabled: false,
        );

      case 'enabledSnapshot':
        return SuperAutoSuggestionsItem<_ScenarioItem>(
          value: item,
          titleText: 'Stream-controlled enabled state',
          descriptionText:
              'enabledSnapshot: Stream<bool> · toggle it above the field',
          iconData: Icons.sensors_rounded,
          enabled: _streamEnabled,
          enabledSnapshot: _enabledController.stream,
        );

      case 'combined':
        return SuperAutoSuggestionsItem<_ScenarioItem>(
          value: item,
          titleText: 'Combined rich suggestion',
          description: const Text(
            'Widget description · searchable title remains titleText',
          ),
          trailing: const Icon(Icons.chevron_right_rounded),
          icon: const CircleAvatar(
            radius: 10,
            child: Icon(Icons.business_rounded, size: 12),
          ),
          group: 'Rich scenarios',
          keywords: const <String>['company', 'customer', 'rich'],
          enabled: true,
        );
    }

    return SuperAutoSuggestionsItem<_ScenarioItem>(
      value: item,
      titleText: item.label,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.superTheme;
    final typography = context.superTextTheme;
    final spacing = theme.spacing;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: SuperAppBar(
        title: const Text('SuperAutoSuggestionsItem'),
        subtitle: Text(
          'ALL ITEM SCENARIOS',
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
                'v1.3.1 · ITEM API',
                style: typography.eyebrow.copyWith(color: colorScheme.primary),
              ),
              SizedBox(height: spacing.space2),
              Text(
                'Every SuperAutoSuggestionsItem scenario',
                style: typography.h1.copyWith(color: theme.fg1),
              ),
              SizedBox(height: spacing.space3),
              Text(
                'The list below covers text metadata, custom widgets, grouping, '
                'keywords, static enabled state, Stream<bool> enabledSnapshot, '
                'and a combined rich item.',
                style: typography.label.copyWith(color: theme.fg2),
              ),
              SizedBox(height: spacing.space8),
              SuperSectionCard2(
                collapsible: false,
                title: 'enabledSnapshot',
                subtitle:
                    'This switch updates the Stream<bool> used by the '
                    'enabledSnapshot scenario.',
                marker: theme.tokens.markerColor(SuperMarker.identity),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _streamEnabled
                            ? 'Dynamic suggestion is enabled'
                            : 'Dynamic suggestion is disabled',
                      ),
                    ),
                    Switch(
                      value: _streamEnabled,
                      onChanged: _toggleStreamEnabled,
                    ),
                  ],
                ),
              ),
              SizedBox(height: spacing.section),
              SuperSectionCard2(
                collapsible: false,
                title: 'All item scenarios',
                subtitle:
                    'Open the suggestions and inspect each rendering/API case.',
                marker: theme.tokens.markerColor(SuperMarker.ledger),
                child: SuperAutoSuggestionsBox<_ScenarioItem>(
                  source: _source,
                  suggestionBuilder: _suggestion,
                  mode: SuperAutoSuggestionsMode.textBox,
                  minChars: 0,
                  maxResults: 50,
                  decoration: const InputDecoration(
                    labelText: 'SuperAutoSuggestionsItem scenarios',
                    helperText:
                        'Open the list with an empty query to see every case.',
                    prefixIcon: Icon(Icons.view_list_rounded),
                  ),
                  hintText: 'Search title or keywords...',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScenarioItem {
  const _ScenarioItem(this.id, this.label);

  final String id;
  final String label;

  @override
  String toString() => label;
}
