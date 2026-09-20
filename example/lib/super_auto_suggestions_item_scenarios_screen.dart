import 'dart:async';

import 'package:flutter/material.dart';
import 'package:super_auto_suggestion_box/super_auto_suggestion_box.dart';
import 'package:super_auto_suggestion_box_example/localizations/generated/l10n.dart';

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
    final l10n = SuperExampleLocalization.of(context);
    switch (item.id) {
      case 'title':
        return SuperAutoSuggestionsItem<_ScenarioItem>(
          value: item,
          titleText: l10n.plainTitleText,
        );

      case 'descriptionText':
        return SuperAutoSuggestionsItem<_ScenarioItem>(
          value: item,
          titleText: l10n.descriptionAsText,
          descriptionText: l10n.descriptionTextSupport,
        );

      case 'descriptionWidget':
        return SuperAutoSuggestionsItem<_ScenarioItem>(
          value: item,
          titleText: l10n.descriptionAsWidget,
          description: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.info_outline_rounded, size: 12),
              const SizedBox(width: 4),
              Text(l10n.customDescriptionWidget),
            ],
          ),
        );

      case 'trailingText':
        return SuperAutoSuggestionsItem<_ScenarioItem>(
          value: item,
          titleText: l10n.trailingText,
          trailingText: 'ERP-1042',
        );

      case 'trailingWidget':
        return SuperAutoSuggestionsItem<_ScenarioItem>(
          value: item,
          titleText: l10n.trailingWidget,
          trailing: Chip(
            visualDensity: VisualDensity.compact,
            label: Text(l10n.active),
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
          titleText: l10n.customIconWidget,
          icon: const CircleAvatar(radius: 10, child: Text('S')),
        );

      case 'group':
        return SuperAutoSuggestionsItem<_ScenarioItem>(
          value: item,
          titleText: l10n.groupedSuggestion,
          group: l10n.metadataScenarios,
        );

      case 'keywords':
        return SuperAutoSuggestionsItem<_ScenarioItem>(
          value: item,
          titleText: l10n.searchableAliases,
          descriptionText: l10n.searchAliasesHint,
          keywords: const <String>['invoice', 'vendor', 'INV-1042'],
        );

      case 'disabled':
        return SuperAutoSuggestionsItem<_ScenarioItem>(
          value: item,
          titleText: l10n.staticallyDisabled,
          descriptionText: 'enabled: false',
          iconData: Icons.block_rounded,
          enabled: false,
        );

      case 'enabledSnapshot':
        return SuperAutoSuggestionsItem<_ScenarioItem>(
          value: item,
          titleText: l10n.streamControlledState,
          descriptionText: l10n.streamControlledDescription,
          iconData: Icons.sensors_rounded,
          enabled: _streamEnabled,
          enabledSnapshot: _enabledController.stream,
        );

      case 'combined':
        return SuperAutoSuggestionsItem<_ScenarioItem>(
          value: item,
          titleText: l10n.combinedRichSuggestion,
          description: Text(
            l10n.richDescription,
          ),
          trailing: const Icon(Icons.chevron_right_rounded),
          icon: const CircleAvatar(
            radius: 10,
            child: Icon(Icons.business_rounded, size: 12),
          ),
          group: l10n.richScenarios,
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
    final l10n = SuperExampleLocalization.of(context);
    final theme = context.superTheme;
    final typography = context.superTextTheme;
    final spacing = theme.spacing;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: SuperAppBar(
        title: const Text('SuperAutoSuggestionsItem'),
        subtitle: Text(
          l10n.allItemScenarios,
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
                l10n.itemApiVersion,
                style: typography.eyebrow.copyWith(color: colorScheme.primary),
              ),
              SizedBox(height: spacing.space2),
              Text(
                l10n.everyItemScenario,
                style: typography.h1.copyWith(color: theme.fg1),
              ),
              SizedBox(height: spacing.space3),
              Text(
                l10n.itemScenarioOverview,
                style: typography.label.copyWith(color: theme.fg2),
              ),
              SizedBox(height: spacing.space8),
              SuperSectionCard2(
                collapsible: false,
                title: 'enabledSnapshot',
                subtitle: l10n.enabledSnapshotDescription,
                marker: theme.tokens.markerColor(SuperMarker.identity),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _streamEnabled
                            ? l10n.dynamicSuggestionEnabled
                            : l10n.dynamicSuggestionDisabled,
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
                title: l10n.allItemScenariosTitle,
                subtitle: l10n.inspectItemCases,
                marker: theme.tokens.markerColor(SuperMarker.ledger),
                child: SuperAutoSuggestionsBox<_ScenarioItem>(
                  source: _source,
                  suggestionBuilder: _suggestion,
                  mode: SuperAutoSuggestionsMode.textBox,
                  minChars: 0,
                  maxResults: 50,
                  decoration: InputDecoration(
                    labelText: l10n.itemScenariosLabel,
                    helperText: l10n.openEmptyQuery,
                    prefixIcon: const Icon(Icons.view_list_rounded),
                  ),
                  hintText: l10n.searchTitleKeywords,
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
