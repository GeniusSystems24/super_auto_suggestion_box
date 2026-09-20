// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SuperAutoSuggestionLocalizationEn
    extends SuperAutoSuggestionLocalization {
  SuperAutoSuggestionLocalizationEn([String locale = 'en']) : super(locale);

  @override
  String get requiredMessage => 'This field is required';

  @override
  String get recent => 'Recent';

  @override
  String get loading => 'Loading…';

  @override
  String get searching => 'Searching…';

  @override
  String searchingQuery(String query) {
    return 'Searching “$query”…';
  }

  @override
  String get typeToSearch => 'Type to search';

  @override
  String get noMatches => 'No matches';

  @override
  String noMatchesForQuery(String query) {
    return 'No matches for “$query”';
  }

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
