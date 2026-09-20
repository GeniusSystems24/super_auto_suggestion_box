// ============================================================
// example/lib/main.dart
// ------------------------------------------------------------
// Gallery launcher for super_auto_suggestion_box. Uses the super_core 3.3.0
// theme and responsive layout primitives, exposes Light/Dark + LTR/RTL toggles,
// and opens the shipped SuperAutoSuggestionsBox demo.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:super_auto_suggestion_box/super_auto_suggestion_box.dart';
import 'package:super_auto_suggestion_box_example/localizations/generated/l10n.dart';

import 'auto_suggestion_box_demo.dart';
import 'advanced_search_screen.dart';
import 'autovalidate_mode_demo.dart';
import 'sources/async_source_screen.dart';
import 'sources/fuzzy_source_screen.dart';
import 'sources/hybrid_source_screen.dart';
import 'sources/list_source_screen.dart';
import 'sources/paged_source_screen.dart';
import 'sources/remote_fallback_source_screen.dart';
import 'sources/strings_source_screen.dart';
import 'super_auto_suggestions_item_scenarios_screen.dart';
import 'version_1_5_1_changes_demo.dart';
import 'validation_position_demo.dart';

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
      onGenerateTitle: (context) => SuperExampleLocalization.of(context).appTitle,
      locale: Locale(_direction == TextDirection.rtl ? 'ar' : 'en'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        SuperAutoSuggestionLocalization.delegate,
        SuperExampleLocalization.delegate,
      ],
      supportedLocales: SuperAutoSuggestionLocalization.supportedLocales,
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

  @override
  Widget build(BuildContext context) {
    final l10n = SuperExampleLocalization.of(context);
    final theme = context.superTheme;
    final typography = context.superTextTheme;
    final spacing = theme.spacing;
    final colorScheme = Theme.of(context).colorScheme;

    final demos = <_Demo>[
      _Demo(
        l10n.version151Changes,
        l10n.version151GalleryDescription,
        Icons.keyboard_alt_outlined,
        (_) => const Version151ChangesDemo(),
      ),
      _Demo(
        l10n.suggestionItemScenarios,
        l10n.suggestionItemScenariosGalleryDescription,
        Icons.view_list_rounded,
        (_) => const SuperAutoSuggestionsItemScenariosScreen(),
      ),
      _Demo(
        l10n.autovalidateMode,
        l10n.autovalidateGalleryDescription,
        Icons.rule_rounded,
        (_) => const AutovalidateModeDemo(),
      ),
      _Demo(
        l10n.validationPosition,
        l10n.validationPositionGalleryDescription,
        Icons.error_outline_rounded,
        (_) => const ValidationPositionDemo(),
      ),
      _Demo(
        l10n.advancedSearch,
        l10n.advancedSearchGalleryDescription,
        Icons.search_rounded,
        (_) => const AdvancedSearchScreen(),
      ),
      _Demo(
        l10n.autoSuggestionBox,
        l10n.autoSuggestionBoxGalleryDescription,
        Icons.manage_search_outlined,
        (_) => const AutoSuggestionBoxDemo(),
      ),
      _Demo(
        l10n.stringSource,
        '${l10n.stringSourceDescription} · ${l10n.sourceDemoCapabilities}',
        Icons.source_outlined,
        (_) => const StringsSourceScreen(),
      ),
      _Demo(
        l10n.listSource,
        '${l10n.listSourceDescription} · ${l10n.sourceDemoCapabilities}',
        Icons.source_outlined,
        (_) => const ListSourceScreen(),
      ),
      _Demo(
        l10n.fuzzySource,
        '${l10n.fuzzySourceDescription} · ${l10n.sourceDemoCapabilities}',
        Icons.source_outlined,
        (_) => const FuzzySourceScreen(),
      ),
      _Demo(
        l10n.asyncSource,
        '${l10n.asyncSourceDescription} · ${l10n.sourceDemoCapabilities}',
        Icons.source_outlined,
        (_) => const AsyncSourceScreen(),
      ),
      _Demo(
        l10n.hybridSource,
        '${l10n.hybridSourceDescription} · ${l10n.sourceDemoCapabilities}',
        Icons.source_outlined,
        (_) => const HybridSourceScreen(),
      ),
      _Demo(
        l10n.remoteFallback,
        '${l10n.remoteFallbackDescription} · ${l10n.sourceDemoCapabilities}',
        Icons.source_outlined,
        (_) => const RemoteFallbackSourceScreen(),
      ),
      _Demo(
        l10n.pagedSource,
        '${l10n.pagedSourceDescription} · ${l10n.sourceDemoCapabilities}',
        Icons.source_outlined,
        (_) => const PagedSourceScreen(),
      ),
    ];

    return Scaffold(
      backgroundColor: theme.bg,
      appBar: AppBar(
        backgroundColor: theme.bg,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            tooltip: mode == ThemeMode.dark ? l10n.lightTheme : l10n.darkTheme,
            onPressed: onToggleTheme,
            icon: Icon(
              mode == ThemeMode.dark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
          ),
          IconButton(
            tooltip: direction == TextDirection.ltr
                ? l10n.switchToArabic
                : l10n.switchToEnglish,
            onPressed: onToggleDirection,
            icon: const Icon(Icons.language_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SuperScaffold(
            maxWidth: 960,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.galleryEyebrow,
                  style: typography.eyebrow.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
                SizedBox(height: spacing.space2),
                Text(
                  l10n.componentDemos,
                  style: typography.h1.copyWith(color: theme.fg1),
                ),
                SizedBox(height: spacing.space8),
                for (final demo in demos) ...[
                  _DemoCard(demo: demo),
                  SizedBox(height: spacing.section),
                ],
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

    return InkWell(
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: demo.builder)),
      child: SuperSectionCard1(
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
      ),
    );
  }
}
