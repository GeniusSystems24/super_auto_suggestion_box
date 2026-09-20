import 'package:flutter/material.dart';
import 'package:super_auto_suggestion_box/super_auto_suggestion_box.dart';
import 'package:super_auto_suggestion_box_example/localizations/generated/l10n.dart';

class AdvancedSearchScreen extends StatefulWidget {
  const AdvancedSearchScreen({super.key});

  @override
  State<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends State<AdvancedSearchScreen> {
  static const _records = <_DirectoryRecord>[
    _DirectoryRecord('V-1001', 'Al Noor Trading', 'Vendor', 'Riyadh'),
    _DirectoryRecord('V-1002', 'Gulf Office Supplies', 'Vendor', 'Jeddah'),
    _DirectoryRecord('V-1003', 'Arabian Logistics', 'Vendor', 'Dammam'),
    _DirectoryRecord('C-2001', 'Horizon Retail Group', 'Customer', 'Riyadh'),
    _DirectoryRecord('C-2002', 'Palm Market', 'Customer', 'Jeddah'),
    _DirectoryRecord('C-2003', 'Eastern Distribution', 'Customer', 'Khobar'),
    _DirectoryRecord('E-3001', 'Ahmed Al Harbi', 'Employee', 'Riyadh'),
    _DirectoryRecord('E-3002', 'Sara Mohammed', 'Employee', 'Jeddah'),
    _DirectoryRecord('A-4001', 'Cash on Hand', 'Account', 'General Ledger'),
    _DirectoryRecord(
      'A-4002',
      'Accounts Receivable',
      'Account',
      'General Ledger',
    ),
  ];

  late final SuperAutoSuggestionsSource<_DirectoryRecord> _source;

  @override
  void initState() {
    super.initState();
    _source = SuperAutoSuggestionSources.list<_DirectoryRecord>(
      _records,
      match: AutoSuggestionMatch.contains,
      caseSensitive: false,
    );
  }

  static IconData _iconFor(_DirectoryRecord record) {
    switch (record.category) {
      case 'Vendor':
        return Icons.local_shipping_outlined;
      case 'Customer':
        return Icons.storefront_outlined;
      case 'Employee':
        return Icons.badge_outlined;
      case 'Account':
        return Icons.account_balance_outlined;
      default:
        return Icons.search_rounded;
    }
  }

  static SuperAutoSuggestionsItem<_DirectoryRecord> _suggestion(
    BuildContext context,
    List<_DirectoryRecord> items,
    int index,
    _DirectoryRecord record,
  ) {
    return SuperAutoSuggestionsItem<_DirectoryRecord>(
      value: record,
      titleText: record.name,
      descriptionText: '${record.code} · ${record.city}',
      trailingText: record.category,
      group: record.category,
      iconData: _iconFor(record),
      keywords: <String>[
        record.code,
        record.category,
        record.city,
        record.name.replaceAll(' ', ''),
      ],
    );
  }

  Widget _scenario({
    required String title,
    required String description,
    required SuperMarker marker,
    required Widget child,
  }) {
    return SuperSectionCard2(
      collapsible: false,
      title: title,
      subtitle: description,
      marker: context.superTheme.tokens.markerColor(marker),
      child: child,
    );
  }

  SuperAutoSuggestionsBox<_DirectoryRecord> _box({
    required String label,
    SuperAutoSuggestionsMode? mode,
    String? helperText,
  }) {
    final l10n = SuperExampleLocalization.of(context);
    return SuperAutoSuggestionsBox<_DirectoryRecord>(
      source: _source,
      suggestionBuilder: _suggestion,
      mode: mode,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        prefixIcon: const Icon(Icons.manage_search_rounded),
      ),
      hintText: l10n.searchDirectoryHint,
      onSelectionChanged: (items) {
        debugPrint(
          items.isEmpty ? '$label: cleared' : '$label: ${items.last.name}',
        );
      },
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
        title: Text(l10n.searchModes),
        subtitle: Text(
          l10n.searchModesSubtitle,
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
                l10n.searchModeVersion,
                style: typography.eyebrow.copyWith(color: colorScheme.primary),
              ),
              SizedBox(height: spacing.space2),
              Text(
                l10n.threeSearchSurfaces,
                style: typography.h1.copyWith(color: theme.fg1),
              ),
              SizedBox(height: spacing.space3),
              Text(
                l10n.searchModeResponsiveDescription,
                style: typography.label.copyWith(color: theme.fg2),
              ),
              SizedBox(height: spacing.space8),
              _scenario(
                title: l10n.adaptiveDefault,
                description: l10n.adaptiveDefaultDescription,
                marker: SuperMarker.identity,
                child: _box(
                  label: l10n.adaptiveSearch,
                  helperText: l10n.platformDefaultMode,
                ),
              ),
              SizedBox(height: spacing.section),
              _scenario(
                title: l10n.textBox,
                description: l10n.textBoxDescription,
                marker: SuperMarker.ledger,
                child: _box(
                  label: l10n.textBoxMode,
                  mode: SuperAutoSuggestionsMode.textBox,
                  helperText: l10n.typeAndPickInline,
                ),
              ),
              SizedBox(height: spacing.section),
              _scenario(
                title: l10n.advanceView,
                description: l10n.advanceViewDescription,
                marker: SuperMarker.notes,
                child: _box(
                  label: l10n.advanceViewMode,
                  mode: SuperAutoSuggestionsMode.advanceView,
                  helperText: l10n.openAdvancedView,
                ),
              ),
              SizedBox(height: spacing.section),
              _scenario(
                title: l10n.both,
                description: l10n.bothDescription,
                marker: SuperMarker.ledger,
                child: _box(
                  label: l10n.bothModes,
                  mode: SuperAutoSuggestionsMode.both,
                  helperText: l10n.bothEnabled,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DirectoryRecord {
  const _DirectoryRecord(this.code, this.name, this.category, this.city);

  final String code;
  final String name;
  final String category;
  final String city;

  @override
  String toString() => name;
}
