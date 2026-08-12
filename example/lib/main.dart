// ============================================================
// example/lib/main.dart
// ------------------------------------------------------------
// Gallery launcher for super_auto_suggestion_box. Uses the super_core 3.3.0
// theme and responsive layout primitives, exposes Light/Dark + LTR/RTL toggles,
// and opens the shipped AutoSuggestionsBox demo.
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_auto_suggestion_box/super_auto_suggestion_box.dart';

import 'auto_suggestion_box_demo.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  ThemeMode _mode = ThemeMode.dark;
  TextDirection _direction = TextDirection.ltr;

  void _toggleTheme() {
    setState(() {
      _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  void _toggleDirection() {
    setState(() {
      _direction = _direction == TextDirection.ltr
          ? TextDirection.rtl
          : TextDirection.ltr;
    });
  }

  @override
  Widget build(BuildContext context) {
    final typography = SuperTextTheme(
      isArabic: _direction == TextDirection.rtl,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Super Auto Suggestion Box',
      themeMode: _mode,
      theme: SuperMaterialThemeData.light(
        textTheme: typography,
        primaryTextTheme: typography,
      ),
      darkTheme: SuperMaterialThemeData.dark(
        textTheme: typography,
        primaryTextTheme: typography,
      ),
      builder: (context, child) =>
          Directionality(textDirection: _direction, child: child!),
      home: _Launcher(
        mode: _mode,
        direction: _direction,
        onToggleTheme: _toggleTheme,
        onToggleDirection: _toggleDirection,
      ),
    );
  }
}

class _Demo {
  const _Demo(this.title, this.subtitle, this.icon, this.builder);

  final String title;
  final String subtitle;
  final IconData icon;
  final WidgetBuilder builder;
}

class _Launcher extends StatelessWidget {
  const _Launcher({
    required this.mode,
    required this.direction,
    required this.onToggleTheme,
    required this.onToggleDirection,
  });

  final ThemeMode mode;
  final TextDirection direction;
  final VoidCallback onToggleTheme;
  final VoidCallback onToggleDirection;

  static final List<_Demo> _demos = [
    _Demo(
      'Auto Suggestion Box',
      'Typeahead · recents · create · paged · multi-select · fuzzy',
      Icons.manage_search_outlined,
      (_) => const AutoSuggestionBoxDemo(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = context.superTheme;
    final typography = context.superTextTheme;
    final spacing = theme.spacing;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: theme.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: SuperScaffold(
            maxWidth: 960,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'SUPER AUTO SUGGESTION BOX • GALLERY',
                  style: typography.eyebrow.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
                SizedBox(height: spacing.space2),
                Text(
                  'Component Demos مكتبة المكونات',
                  style: typography.h1.copyWith(color: theme.fg1),
                ),
                SizedBox(height: spacing.space8),
                for (final demo in _demos) ...[
                  _DemoCard(demo: demo),
                  SizedBox(height: spacing.section),
                ],
                SizedBox(height: spacing.space6),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: spacing.space3,
                  runSpacing: spacing.space3,
                  children: [
                    SuperButton(
                      label: mode == ThemeMode.dark
                          ? 'Light Theme'
                          : 'Dark Theme',
                      variant: SuperButtonVariant.secondary,
                      onPressed: onToggleTheme,
                    ),
                    SuperButton(
                      label: direction == TextDirection.ltr
                          ? 'العربية (RTL)'
                          : 'English (LTR)',
                      variant: SuperButtonVariant.secondary,
                      onPressed: onToggleDirection,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DemoCard extends StatelessWidget {
  const _DemoCard({required this.demo});

  final _Demo demo;

  @override
  Widget build(BuildContext context) {
    final theme = context.superTheme;
    final typography = context.superTextTheme;
    final spacing = theme.spacing;
    final colorScheme = Theme.of(context).colorScheme;

    return SuperSectionCard(
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: demo.builder)),
      padding: spacing.cardPadding,
      child: Row(
        children: [
          Container(
            width: spacing.controlHeight,
            height: spacing.controlHeight,
            decoration: BoxDecoration(
              color: Color.alphaBlend(
                colorScheme.primary.withValues(alpha: 0.14),
                theme.surface,
              ),
              borderRadius: spacing.borderRadiusControl,
            ),
            child: Icon(demo.icon, size: 22, color: colorScheme.primary),
          ),
          SizedBox(width: spacing.space4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  demo.title,
                  style: typography.heading.copyWith(color: theme.fg1),
                ),
                SizedBox(height: spacing.space1),
                Text(
                  demo.subtitle,
                  style: typography.caption.copyWith(color: theme.fg3),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: theme.fg4),
        ],
      ),
    );
  }
}
