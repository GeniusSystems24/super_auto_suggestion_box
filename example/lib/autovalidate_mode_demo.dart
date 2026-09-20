// ============================================================
// example/lib/autovalidate_mode_demo.dart
// ------------------------------------------------------------
// Demonstrates Form-level autovalidateMode inheritance for
// SuperAutoSuggestionsBox, plus field-level override behavior.
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_auto_suggestion_box/super_auto_suggestion_box.dart';
import 'package:super_auto_suggestion_box_example/localizations/generated/l10n.dart';

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
    final l10n = SuperExampleLocalization.of(context);
    final theme = context.superTheme;
    final spacing = theme.spacing;
    final typography = context.superTextTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: theme.bg,
      appBar: SuperAppBar(title: Text(l10n.autovalidateMode)),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SuperScaffold(
            maxWidth: 760,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.validation,
                  style: typography.eyebrow.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
                SizedBox(height: spacing.space2),
                Text(
                  l10n.formAutovalidation,
                  style: typography.h1.copyWith(color: theme.fg1),
                ),
                SizedBox(height: spacing.space8),
                SuperSectionCard2(
                  collapsible: false,
                  title: l10n.formDefault,
                  subtitle: l10n.formDefaultDescription,
                  marker: theme.tokens.markerColor(SuperMarker.identity),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SegmentedButton<AutovalidateMode>(
                        segments: [
                          ButtonSegment(
                            value: AutovalidateMode.disabled,
                            icon: const Icon(Icons.pause_circle_outline_rounded),
                            label: Text(l10n.disabled),
                          ),
                          ButtonSegment(
                            value: AutovalidateMode.always,
                            icon: const Icon(Icons.running_with_errors_rounded),
                            label: Text(l10n.always),
                          ),
                          ButtonSegment(
                            value: AutovalidateMode.onUserInteraction,
                            icon: const Icon(Icons.touch_app_rounded),
                            label: Text(l10n.onChange),
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
                              suggestionBuilder: (context, items, index, item) =>
                                  _accountSuggestion(items, index, item, l10n),
                              decoration: InputDecoration(
                                labelText: l10n.postingAccount,
                                helperText: l10n.requiredAccountLookup,
                                prefixIcon: const Icon(Icons.account_balance),
                              ),
                              required: true,
                            ),
                            SizedBox(height: spacing.space6),
                            SuperAutoSuggestionsBox<String>(
                              source: SuggestionSources.list<String>(_accounts),
                              suggestionBuilder: (context, items, index, item) =>
                                  _accountSuggestion(items, index, item, l10n),
                              decoration: InputDecoration(
                                labelText: l10n.expenseAccount,
                                helperText: l10n.mustBeExpense,
                                prefixIcon: const Icon(Icons.receipt_long_outlined),
                              ),
                              validator: (value) =>
                                  value == null || value.startsWith('5')
                                  ? null
                                  : l10n.chooseExpense,
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
                            label: Text(l10n.validate),
                          ),
                          SizedBox(width: spacing.space3),
                          TextButton.icon(
                            onPressed: () => _formKey.currentState?.reset(),
                            icon: const Icon(Icons.restart_alt_rounded),
                            label: Text(
                              l10n.reset,
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
                  title: l10n.fieldOverride,
                  subtitle: l10n.fieldAlwaysValidates,
                  marker: theme.tokens.markerColor(SuperMarker.ledger),
                  child: SuperAutoSuggestionsBox<String>(
                    source: SuggestionSources.list<String>(_accounts),
                    suggestionBuilder: (context, items, index, item) =>
                                  _accountSuggestion(items, index, item, l10n),
                    decoration: InputDecoration(
                      labelText: l10n.immediateAccount,
                      helperText: l10n.fieldAutovalidatePrecedence,
                      prefixIcon: const Icon(Icons.flash_on_outlined),
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
  SuperExampleLocalization l10n,
) {
  final parts = item.split(' ');
  return SuperAutoSuggestionsItem<String>(
    value: item,
    titleText: item,
    descriptionText: l10n.accountCode(parts.first),
    iconData: Icons.account_balance_outlined,
    keywords: [parts.first, item.replaceAll(' ', '')],
  );
}
