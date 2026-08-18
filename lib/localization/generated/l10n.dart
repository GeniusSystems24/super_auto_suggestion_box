// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class SuperAutoSuggestionsTranslation {
  SuperAutoSuggestionsTranslation();

  static SuperAutoSuggestionsTranslation? _current;

  static SuperAutoSuggestionsTranslation get current {
    assert(
      _current != null,
      'No instance of SuperAutoSuggestionsTranslation was loaded. Try to initialize the SuperAutoSuggestionsTranslation delegate before accessing SuperAutoSuggestionsTranslation.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<SuperAutoSuggestionsTranslation> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = SuperAutoSuggestionsTranslation();
      SuperAutoSuggestionsTranslation._current = instance;

      return instance;
    });
  }

  static SuperAutoSuggestionsTranslation of(BuildContext context) {
    final instance = SuperAutoSuggestionsTranslation.maybeOf(context);
    assert(
      instance != null,
      'No instance of SuperAutoSuggestionsTranslation present in the widget tree. Did you add SuperAutoSuggestionsTranslation.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static SuperAutoSuggestionsTranslation? maybeOf(BuildContext context) {
    return Localizations.of<SuperAutoSuggestionsTranslation>(
      context,
      SuperAutoSuggestionsTranslation,
    );
  }

  /// `This field is required`
  String get requiredMessage {
    return Intl.message(
      'This field is required',
      name: 'requiredMessage',
      desc: '',
      args: [],
    );
  }

  /// `Recent`
  String get recent {
    return Intl.message('Recent', name: 'recent', desc: '', args: []);
  }

  /// `Loading…`
  String get loading {
    return Intl.message('Loading…', name: 'loading', desc: '', args: []);
  }

  /// `Searching…`
  String get searching {
    return Intl.message('Searching…', name: 'searching', desc: '', args: []);
  }

  /// `Searching “{query}”…`
  String searchingQuery(String query) {
    return Intl.message(
      'Searching “$query”…',
      name: 'searchingQuery',
      desc: '',
      args: [query],
    );
  }

  /// `Type to search`
  String get typeToSearch {
    return Intl.message(
      'Type to search',
      name: 'typeToSearch',
      desc: '',
      args: [],
    );
  }

  /// `No matches`
  String get noMatches {
    return Intl.message('No matches', name: 'noMatches', desc: '', args: []);
  }

  /// `No matches for “{query}”`
  String noMatchesForQuery(String query) {
    return Intl.message(
      'No matches for “$query”',
      name: 'noMatchesForQuery',
      desc: '',
      args: [query],
    );
  }

  /// `Loading more…`
  String get loadingMore {
    return Intl.message(
      'Loading more…',
      name: 'loadingMore',
      desc: '',
      args: [],
    );
  }

  /// `Loading more from server…`
  String get loadingMoreFromServer {
    return Intl.message(
      'Loading more from server…',
      name: 'loadingMoreFromServer',
      desc: '',
      args: [],
    );
  }

  /// `Create`
  String get create {
    return Intl.message('Create', name: 'create', desc: '', args: []);
  }

  /// `ENTER`
  String get enter {
    return Intl.message('ENTER', name: 'enter', desc: '', args: []);
  }

  /// `Fix`
  String get fix {
    return Intl.message('Fix', name: 'fix', desc: '', args: []);
  }

  /// `Unfix`
  String get unfix {
    return Intl.message('Unfix', name: 'unfix', desc: '', args: []);
  }

  /// `Advanced Search`
  String get advancedSearch {
    return Intl.message(
      'Advanced Search',
      name: 'advancedSearch',
      desc: '',
      args: [],
    );
  }

  /// `Search…`
  String get search {
    return Intl.message('Search…', name: 'search', desc: '', args: []);
  }

  /// `↑ ↓ TO NAVIGATE   ⏎ TO SELECT   ESC TO CLOSE`
  String get advancedSearchKeyboardHint {
    return Intl.message(
      '↑ ↓ TO NAVIGATE   ⏎ TO SELECT   ESC TO CLOSE',
      name: 'advancedSearchKeyboardHint',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate
    extends LocalizationsDelegate<SuperAutoSuggestionsTranslation> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<SuperAutoSuggestionsTranslation> load(Locale locale) =>
      SuperAutoSuggestionsTranslation.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
