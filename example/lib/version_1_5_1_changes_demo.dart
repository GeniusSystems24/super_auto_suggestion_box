import 'package:flutter/material.dart';
import 'package:super_auto_suggestion_box/super_auto_suggestion_box.dart';
import 'package:super_auto_suggestion_box_example/localizations/generated/l10n.dart';

/// Demonstrates the behavior changes introduced in version 1.5.1.
///
/// The first scenario verifies that the inline suggestions overlay only uses
/// the viewport that remains visible above the software keyboard. The second
/// scenario verifies that Advanced View exposes its create action when the
/// current query has no suggestions and [SuperAutoSuggestionsBox.onCreate] is
/// provided.
class Version151ChangesDemo extends StatefulWidget {
  const Version151ChangesDemo({super.key});

  @override
  State<Version151ChangesDemo> createState() => _Version151ChangesDemoState();
}

class _Version151ChangesDemoState extends State<Version151ChangesDemo> {
  late final List<String> _accountCodes;
  late final List<String> _projectCodes;
  late final SuperAutoSuggestionsSource<String> _accountSource;
  late final SuperAutoSuggestionsSource<String> _projectSource;

  String? _selectedProject;

  @override
  void initState() {
    super.initState();

    _accountCodes = List<String>.generate(
      48,
      (index) => 'ACC-${(1001 + index).toString().padLeft(4, '0')}',
    );
    _projectCodes = <String>['PRJ-001', 'PRJ-002', 'PRJ-003'];

    _accountSource = SuperAutoSuggestionSources.list<String>(_accountCodes);
    _projectSource = SuperAutoSuggestionSources.list<String>(_projectCodes);
  }

  SuperAutoSuggestionsItem<String> _accountSuggestion(
    List<String> items,
    int index,
    String item,
    SuperExampleLocalization l10n,
  ) {
    return SuperAutoSuggestionsItem<String>(
      value: item,
      titleText: item,
      descriptionText: l10n.version151SampleAccount,
      iconData: Icons.account_balance_outlined,
      keywords: <String>[item.replaceAll('-', '')],
    );
  }

  SuperAutoSuggestionsItem<String> _projectSuggestion(
    List<String> items,
    int index,
    String item,
    SuperExampleLocalization l10n,
  ) {
    return SuperAutoSuggestionsItem<String>(
      value: item,
      titleText: item,
      descriptionText: l10n.version151SampleProject,
      iconData: Icons.work_outline_rounded,
      keywords: <String>[item.replaceAll('-', '')],
    );
  }

  String? _createProject(String query) {
    final value = query.trim();
    if (value.isEmpty) return null;

    for (final project in _projectCodes) {
      if (project.toLowerCase() == value.toLowerCase()) {
        return project;
      }
    }

    setState(() => _projectCodes.add(value));

    final l10n = SuperExampleLocalization.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.version151CreatedProject(value))),
    );
    return value;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = SuperExampleLocalization.of(context);
    final theme = context.superTheme;
    final typography = context.superTextTheme;
    final spacing = theme.spacing;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: theme.bg,
      appBar: SuperAppBar(title: Text(l10n.version151Changes)),
      body: SafeArea(
        child: SingleChildScrollView(
          // Keep focus on the textBox while the surrounding page scrolls.
          // Using `onDrag` dismisses the keyboard, which also blurs the field
          // and intentionally closes the suggestions overlay.
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
          child: SuperScaffold(
            maxWidth: 860,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.version151Eyebrow,
                  style: typography.eyebrow.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
                SizedBox(height: spacing.space2),
                Text(
                  l10n.version151Title,
                  style: typography.h1.copyWith(color: theme.fg1),
                ),
                SizedBox(height: spacing.space3),
                Text(
                  l10n.version151Description,
                  style: typography.label.copyWith(color: theme.fg2),
                ),
                SizedBox(height: spacing.space8),
                SuperSectionCard2(
                  collapsible: false,
                  title: l10n.version151KeyboardSafeOverlay,
                  subtitle: l10n.version151KeyboardSafeOverlayDescription,
                  marker: theme.tokens.markerColor(SuperMarker.identity),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.version151KeyboardSafeInstruction,
                        style: typography.caption.copyWith(color: theme.fg2),
                      ),
                      SizedBox(height: spacing.space5),
                      SuperAutoSuggestionsBox<String>(
                        source: _accountSource,
                        suggestionBuilder: (items, index, item) =>
                            _accountSuggestion(items, index, item, l10n),
                        mode: SuperAutoSuggestionsMode.textBox,
                        maxVisibleRows: 14,
                        scrollOnFocus: true,
                        decoration: InputDecoration(
                          labelText: l10n.version151AccountLookup,
                          helperText: l10n.version151KeyboardSafeHelper,
                          prefixIcon: const Icon(Icons.keyboard_alt_outlined),
                        ),
                        hintText: l10n.version151AccountHint,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: spacing.section),
                SuperSectionCard2(
                  collapsible: false,
                  title: l10n.version151AdvancedCreate,
                  subtitle: l10n.version151AdvancedCreateDescription,
                  marker: theme.tokens.markerColor(SuperMarker.ledger),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SuperAutoSuggestionsBox<String>(
                        source: _projectSource,
                        suggestionBuilder: (items, index, item) =>
                            _projectSuggestion(items, index, item, l10n),
                        mode: SuperAutoSuggestionsMode.advanceView,
                        decoration: InputDecoration(
                          labelText: l10n.version151ProjectLookup,
                          helperText: l10n.version151ProjectLookupHelper,
                          prefixIcon: const Icon(Icons.add_business_outlined),
                        ),
                        hintText: l10n.version151ProjectHint,
                        onCreate: _createProject,
                        createLabelBuilder: (query) =>
                            l10n.version151CreateProject(query),
                        onSelectionChanged: (items) {
                          setState(() {
                            _selectedProject = items.isEmpty ? null : items.last;
                          });
                        },
                      ),
                      SizedBox(height: spacing.space4),
                      Text(
                        _selectedProject == null
                            ? l10n.version151NoProjectSelected
                            : l10n.version151SelectedProject(_selectedProject!),
                        style: typography.caption.copyWith(color: theme.fg2),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: spacing.space8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
