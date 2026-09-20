// ============================================================
// example/lib/validation_position_demo.dart
// ------------------------------------------------------------
// Demonstrates validation feedback placement for SuperAutoSuggestionsBox.
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_auto_suggestion_box/super_auto_suggestion_box.dart';
import 'package:super_auto_suggestion_box_example/localizations/generated/l10n.dart';

class ValidationPositionDemo extends StatefulWidget {
  const ValidationPositionDemo({super.key});

  @override
  State<ValidationPositionDemo> createState() => _ValidationPositionDemoState();
}

class _ValidationPositionDemoState extends State<ValidationPositionDemo> {
  ValidationPosition? _globalPosition;
  ValidationPosition _position = ValidationPosition.labelTrailing;

  static const _accounts = <String>[
    '1010 Cash on Hand',
    '1020 Bank Operating',
    '1200 Accounts Receivable',
    '4000 Sales Revenue',
  ];

  @override
  void dispose() {
    if (SuperFormField.validationPosition == _globalPosition) {
      SuperFormField.validationPosition = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = SuperExampleLocalization.of(context);
    final theme = context.superTheme;
    final spacing = theme.spacing;
    final typography = context.superTextTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: theme.bg,
      appBar: SuperAppBar(title: Text(l10n.validationPosition)),
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
                  l10n.feedbackPlacement,
                  style: typography.h1.copyWith(color: theme.fg1),
                ),
                SizedBox(height: spacing.space8),
                SuperSectionCard2(
                  collapsible: false,
                  title: l10n.globalDefault,
                  subtitle: l10n.globalDefaultDescription,
                  marker: theme.tokens.markerColor(SuperMarker.identity),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(
                        spacing: spacing.space2,
                        runSpacing: spacing.space2,
                        children: [
                          ChoiceChip(
                            label: Text(l10n.responsive),
                            selected: _globalPosition == null,
                            onSelected: (_) => _setGlobalPosition(null),
                          ),
                          ChoiceChip(
                            label: Text(l10n.suffix),
                            selected:
                                _globalPosition ==
                                ValidationPosition.suffixIcon,
                            onSelected: (_) => _setGlobalPosition(
                              ValidationPosition.suffixIcon,
                            ),
                          ),
                          ChoiceChip(
                            label: Text(l10n.under),
                            selected:
                                _globalPosition == ValidationPosition.underBox,
                            onSelected: (_) =>
                                _setGlobalPosition(ValidationPosition.underBox),
                          ),
                          ChoiceChip(
                            label: Text(l10n.label),
                            selected:
                                _globalPosition ==
                                ValidationPosition.labelTrailing,
                            onSelected: (_) => _setGlobalPosition(
                              ValidationPosition.labelTrailing,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: spacing.space6),
                      _RequiredBox(label: l10n.usesPackageDefault),
                    ],
                  ),
                ),
                SizedBox(height: spacing.space8),
                SuperSectionCard2(
                  collapsible: false,
                  title: l10n.fieldOverride,
                  subtitle: l10n.fieldPositionDescription,
                  marker: theme.tokens.markerColor(SuperMarker.ledger),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SegmentedButton<ValidationPosition>(
                        segments: [
                          ButtonSegment(
                            value: ValidationPosition.suffixIcon,
                            icon: const Icon(Icons.input_rounded),
                            label: Text(l10n.suffix),
                          ),
                          ButtonSegment(
                            value: ValidationPosition.underBox,
                            icon: const Icon(Icons.short_text_rounded),
                            label: Text(l10n.under),
                          ),
                          ButtonSegment(
                            value: ValidationPosition.labelTrailing,
                            icon: const Icon(Icons.label_important_outline_rounded),
                            label: Text(l10n.label),
                          ),
                        ],
                        selected: {_position},
                        onSelectionChanged: (value) =>
                            setState(() => _position = value.single),
                      ),
                      SizedBox(height: spacing.space6),
                      _RequiredBox(
                        label: l10n.usesFieldPosition,
                        validationPosition: _position,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _setGlobalPosition(ValidationPosition? position) {
    setState(() => _globalPosition = position);
    SuperFormField.validationPosition = position;
  }
}

class _RequiredBox extends StatelessWidget {
  const _RequiredBox({required this.label, this.validationPosition});

  final String label;
  final ValidationPosition? validationPosition;

  @override
  Widget build(BuildContext context) {
    final l10n = SuperExampleLocalization.of(context);
    return Form(
      autovalidateMode: AutovalidateMode.always,
      child: SuperAutoSuggestionsBox<String>(
        source: SuggestionSources.list<String>(
          _ValidationPositionDemoState._accounts,
        ),
        suggestionBuilder: (items, index, item) =>
            _accountSuggestion(items, index, item, l10n),
        decoration: InputDecoration(
          labelText: label,
          helperText: l10n.requiredAccountLookup,
          prefixIcon: const Icon(Icons.account_balance),
        ),
        required: true,
        validationPosition: validationPosition,
        helpIcon: Icon(
          Icons.help_outline_rounded,
          size: 18,
          color: context.superTheme.fg3,
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
  final code = item.split(' ').first;
  return SuperAutoSuggestionsItem<String>(
    value: item,
    titleText: item,
    descriptionText: l10n.accountCode(code),
    iconData: Icons.account_balance_outlined,
    keywords: [code, item.replaceAll(' ', '')],
  );
}
