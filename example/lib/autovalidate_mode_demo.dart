// ============================================================
// example/lib/autovalidate_mode_demo.dart
// ------------------------------------------------------------
// Demonstrates Form-level autovalidateMode inheritance for
// SuperAutoSuggestionsBox, plus field-level override behavior.
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_auto_suggestion_box/super_auto_suggestion_box.dart';

class AutovalidateModeDemo extends StatefulWidget {
  const AutovalidateModeDemo({super.key});

  @override
  State<AutovalidateModeDemo> createState() => _AutovalidateModeDemoState();
}

class _AutovalidateModeDemoState extends State<AutovalidateModeDemo> {
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _mode = AutovalidateMode.disabled;

  static const _accounts = <String>[
    '1010 Cash on Hand',
    '1020 Bank Operating',
    '1200 Accounts Receivable',
    '4000 Sales Revenue',
    '5200 Travel Expense',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = context.superTheme;
    final spacing = theme.spacing;
    final typography = context.superTextTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: theme.bg,
      appBar: SuperAppBar(title: const Text('Autovalidate Mode')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SuperScaffold(
            maxWidth: 760,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'VALIDATION',
                  style: typography.eyebrow.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
                SizedBox(height: spacing.space2),
                Text(
                  'Form Autovalidation',
                  style: typography.h1.copyWith(color: theme.fg1),
                ),
                SizedBox(height: spacing.space8),
                SuperSectionCard2(
                  collapsible: false,
                  title: 'Form default',
                  subtitle:
                      'Both boxes below read autovalidateMode from the Form.',
                  marker: theme.tokens.markerColor(SuperMarker.identity),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SegmentedButton<AutovalidateMode>(
                        segments: const [
                          ButtonSegment(
                            value: AutovalidateMode.disabled,
                            icon: Icon(Icons.pause_circle_outline_rounded),
                            label: Text('Disabled'),
                          ),
                          ButtonSegment(
                            value: AutovalidateMode.always,
                            icon: Icon(Icons.running_with_errors_rounded),
                            label: Text('Always'),
                          ),
                          ButtonSegment(
                            value: AutovalidateMode.onUserInteraction,
                            icon: Icon(Icons.touch_app_rounded),
                            label: Text('On change'),
                          ),
                        ],
                        selected: {_mode},
                        onSelectionChanged: (value) =>
                            setState(() => _mode = value.single),
                      ),
                      SizedBox(height: spacing.space6),
                      Form(
                        key: _formKey,
                        autovalidateMode: _mode,
                        child: Column(
                          children: [
                            SuperAutoSuggestionsBox<String>(
                              source: SuggestionSources.list<String>(_accounts),
                              suggestionBuilder: _accountSuggestion,
                              decoration: const InputDecoration(
                                labelText: 'Posting account',
                                helperText: 'Required account lookup.',
                                prefixIcon: Icon(Icons.account_balance),
                              ),
                              required: true,
                            ),
                            SizedBox(height: spacing.space6),
                            SuperAutoSuggestionsBox<String>(
                              source: SuggestionSources.list<String>(_accounts),
                              suggestionBuilder: _accountSuggestion,
                              decoration: const InputDecoration(
                                labelText: 'Expense account',
                                helperText: 'Must be an expense account.',
                                prefixIcon: Icon(Icons.receipt_long_outlined),
                              ),
                              validator: (value) =>
                                  value == null || value.startsWith('5')
                                  ? null
                                  : 'Choose an expense account.',
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: spacing.space6),
                      Row(
                        children: [
                          FilledButton.icon(
                            onPressed: () => _formKey.currentState?.validate(),
                            icon: const Icon(Icons.fact_check_outlined),
                            label: const Text('Validate'),
                          ),
                          SizedBox(width: spacing.space3),
                          TextButton.icon(
                            onPressed: () => _formKey.currentState?.reset(),
                            icon: const Icon(Icons.restart_alt_rounded),
                            label: Text(
                              'Reset',
                              style: TextStyle(color: theme.fg2),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: spacing.space8),
                SuperSectionCard2(
                  collapsible: false,
                  title: 'Field override',
                  subtitle:
                      'This box validates always, independent of the Form mode.',
                  marker: theme.tokens.markerColor(SuperMarker.ledger),
                  child: SuperAutoSuggestionsBox<String>(
                    source: SuggestionSources.list<String>(_accounts),
                    suggestionBuilder: _accountSuggestion,
                    decoration: const InputDecoration(
                      labelText: 'Immediate account',
                      helperText:
                          'Field-level autovalidateMode takes precedence.',
                      prefixIcon: Icon(Icons.flash_on_outlined),
                    ),
                    required: true,
                    autovalidateMode: AutovalidateMode.always,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

SuperAutoSuggestionsItem<String> _accountSuggestion(
  List<String> items,
  int index,
  String item,
) {
  final parts = item.split(' ');
  return SuperAutoSuggestionsItem<String>(
    value: item,
    titleText: item,
    descriptionText: 'Account code ${parts.first}',
    iconData: Icons.account_balance_outlined,
    keywords: [parts.first, item.replaceAll(' ', '')],
  );
}
