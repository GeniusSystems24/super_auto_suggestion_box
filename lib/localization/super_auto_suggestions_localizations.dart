import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'generated/l10n.dart';

export 'generated/l10n.dart';

/// Stable localization helpers around the generated translation delegate.
abstract final class SuperAutoSuggestionsLocalizations {
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ar'),
  ];

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        SuperAutoSuggestionsTranslation.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];
}

/// Resolves package translations from [context].
///
/// If the host application did not register
/// [SuperAutoSuggestionsLocalizations.localizationsDelegates], package widgets
/// still render safely using the built-in English strings.
abstract final class SuperAutoSuggestionsLocalization {
  static final SuperAutoSuggestionsTranslation _englishFallback =
      _EnglishSuperAutoSuggestionsTranslation();

  static SuperAutoSuggestionsTranslation of(BuildContext context) =>
      SuperAutoSuggestionsTranslation.maybeOf(context) ?? _englishFallback;
}

/// Explicit English fallback used when no generated localization is available
/// in the current widget tree.
///
/// This intentionally overrides every package-owned message instead of merely
/// constructing `SuperAutoSuggestionsTranslation()`, because generated
/// `Intl.message` getters may otherwise inherit a global `Intl.defaultLocale`.
final class _EnglishSuperAutoSuggestionsTranslation
    extends SuperAutoSuggestionsTranslation {
  @override
  String get requiredMessage => 'This field is required';

  @override
  String get recent => 'Recent';

  @override
  String get loading => 'Loading…';

  @override
  String get searching => 'Searching…';

  @override
  String searchingQuery(String query) => 'Searching “$query”…';

  @override
  String get typeToSearch => 'Type to search';

  @override
  String get noMatches => 'No matches';

  @override
  String noMatchesForQuery(String query) => 'No matches for “$query”';

  @override
  String get loadingMore => 'Loading more…';

  @override
  String get loadingMoreFromServer => 'Loading more from server…';

  @override
  String get create => 'Create';

  @override
  String get enter => 'ENTER';

  @override
  String get fix => 'Fix';

  @override
  String get unfix => 'Unfix';

  @override
  String get advancedSearch => 'Advanced Search';

  @override
  String get search => 'Search…';

  @override
  String get advancedSearchKeyboardHint =>
      '↑ ↓ TO NAVIGATE   ⏎ TO SELECT   ESC TO CLOSE';
}
