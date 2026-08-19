import 'package:flutter/material.dart';
import 'package:super_auto_suggestion_box/super_auto_suggestion_box.dart';

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
    return SuperAutoSuggestionsBox<_DirectoryRecord>(
      source: _source,
      suggestionBuilder: _suggestion,
      mode: mode,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        prefixIcon: const Icon(Icons.manage_search_rounded),
      ),
      hintText: 'Name, code, category, or city...',
      onSelectionChanged: (items) {
        debugPrint(
          items.isEmpty ? '$label: cleared' : '$label: ${items.last.name}',
        );
      },
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
        title: const Text('Search Modes'),
        subtitle: Text(
          'TEXTBOX · ADVANCE VIEW · BOTH',
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
                'v1.3.1 · SEARCH MODE',
                style: typography.eyebrow.copyWith(color: colorScheme.primary),
              ),
              SizedBox(height: spacing.space2),
              Text(
                'One component, three search surfaces',
                style: typography.h1.copyWith(color: theme.fg1),
              ),
              SizedBox(height: spacing.space3),
              Text(
                'When mode is omitted, desktop platforms default to TextBox. '
                'Android, iOS, and Fuchsia default to AdvanceView.',
                style: typography.label.copyWith(color: theme.fg2),
              ),
              SizedBox(height: spacing.space8),
              _scenario(
                title: 'Adaptive default',
                description:
                    'No mode is passed. Desktop resolves to TextBox; mobile '
                    'resolves to AdvanceView.',
                marker: SuperMarker.identity,
                child: _box(
                  label: 'Adaptive search',
                  helperText: 'Uses the platform-dependent default mode.',
                ),
              ),
              SizedBox(height: spacing.section),
              _scenario(
                title: 'TextBox',
                description:
                    'Classic editable text box with the anchored inline '
                    'suggestion dropdown.',
                marker: SuperMarker.ledger,
                child: _box(
                  label: 'TextBox mode',
                  mode: SuperAutoSuggestionsMode.textBox,
                  helperText: 'Type directly and pick from the inline list.',
                ),
              ),
              SizedBox(height: spacing.section),
              _scenario(
                title: 'AdvanceView',
                description:
                    'The field becomes a launcher for the larger Advanced '
                    'Search surface instead of opening the inline dropdown.',
                marker: SuperMarker.notes,
                child: _box(
                  label: 'AdvanceView mode',
                  mode: SuperAutoSuggestionsMode.advanceView,
                  helperText: 'Tap or focus the field to open Advanced View.',
                ),
              ),
              SizedBox(height: spacing.section),
              _scenario(
                title: 'Both',
                description:
                    'Inline TextBox behavior plus Advanced View. Use the '
                    'advanced-search action or Ctrl/Cmd + F while focused.',
                marker: SuperMarker.ledger,
                child: _box(
                  label: 'Both modes',
                  mode: SuperAutoSuggestionsMode.both,
                  helperText:
                      'Inline suggestions and Advanced View are both enabled.',
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
