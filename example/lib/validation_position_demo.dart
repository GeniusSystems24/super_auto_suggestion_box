// ============================================================
// example/lib/validation_position_demo.dart
// ------------------------------------------------------------
// Demonstrates validation feedback placement for SuperAutoSuggestionsBox.
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_auto_suggestion_box/super_auto_suggestion_box.dart';

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
    final theme = context.superTheme;
    final spacing = theme.spacing;
    final typography = context.superTextTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: theme.bg,
      appBar: SuperAppBar(title: const Text('Validation Position')),
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
                  'Feedback Placement',
                  style: typography.h1.copyWith(color: theme.fg1),
                ),
                SizedBox(height: spacing.space8),
                SuperSectionCard2(
                  collapsible: false,
                  title: 'Global default',
                  subtitle:
                      'Leave it responsive, or set one package-wide position.',
                  marker: theme.tokens.markerColor(SuperMarker.identity),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(
                        spacing: spacing.space2,
                        runSpacing: spacing.space2,
                        children: [
                          ChoiceChip(
                            label: const Text('Responsive'),
                            selected: _globalPosition == null,
                            onSelected: (_) => _setGlobalPosition(null),
                          ),
                          ChoiceChip(
                            label: const Text('Suffix'),
                            selected:
                                _globalPosition ==
                                ValidationPosition.suffixIcon,
                            onSelected: (_) => _setGlobalPosition(
                              ValidationPosition.suffixIcon,
                            ),
                          ),
                          ChoiceChip(
                            label: const Text('Under'),
                            selected:
                                _globalPosition == ValidationPosition.underBox,
                            onSelected: (_) =>
                                _setGlobalPosition(ValidationPosition.underBox),
                          ),
                          ChoiceChip(
                            label: const Text('Label'),
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
                      const _RequiredBox(label: 'Uses package default'),
                    ],
                  ),
                ),
                SizedBox(height: spacing.space8),
                SuperSectionCard2(
                  collapsible: false,
                  title: 'Field override',
                  subtitle:
                      'The selected field position overrides the package default.',
                  marker: theme.tokens.markerColor(SuperMarker.ledger),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SegmentedButton<ValidationPosition>(
                        segments: const [
                          ButtonSegment(
                            value: ValidationPosition.suffixIcon,
                            icon: Icon(Icons.input_rounded),
                            label: Text('Suffix'),
                          ),
                          ButtonSegment(
                            value: ValidationPosition.underBox,
                            icon: Icon(Icons.short_text_rounded),
                            label: Text('Under'),
                          ),
                          ButtonSegment(
                            value: ValidationPosition.labelTrailing,
                            icon: Icon(Icons.label_important_outline_rounded),
                            label: Text('Label'),
                          ),
                        ],
                        selected: {_position},
                        onSelectionChanged: (value) =>
                            setState(() => _position = value.single),
                      ),
                      SizedBox(height: spacing.space6),
                      _RequiredBox(
                        label: 'Uses field position',
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
    return Form(
      autovalidateMode: AutovalidateMode.always,
      child: SuperAutoSuggestionsBox<String>(
        source: SuggestionSources.list<String>(
          _ValidationPositionDemoState._accounts,
        ),
        suggestionBuilder: _accountSuggestion,
        decoration: InputDecoration(
          labelText: label,
          helperText: 'Required account lookup.',
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
) {
  final code = item.split(' ').first;
  return SuperAutoSuggestionsItem<String>(
    value: item,
    titleText: item,
    descriptionText: 'Account code $code',
    iconData: Icons.account_balance_outlined,
    keywords: [code, item.replaceAll(' ', '')],
  );
}
