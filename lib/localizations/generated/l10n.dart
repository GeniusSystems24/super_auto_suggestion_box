import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'l10n_ar.dart';
import 'l10n_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of SuperAutoSuggestionLocalization
/// returned by `SuperAutoSuggestionLocalization.of(context)`.
///
/// Applications need to include `SuperAutoSuggestionLocalization.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: SuperAutoSuggestionLocalization.localizationsDelegates,
///   supportedLocales: SuperAutoSuggestionLocalization.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the SuperAutoSuggestionLocalization.supportedLocales
/// property.
abstract class SuperAutoSuggestionLocalization {
  SuperAutoSuggestionLocalization(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static SuperAutoSuggestionLocalization of(BuildContext context) {
    return Localizations.of<SuperAutoSuggestionLocalization>(
      context,
      SuperAutoSuggestionLocalization,
    )!;
  }

  static const LocalizationsDelegate<SuperAutoSuggestionLocalization> delegate =
      _SuperAutoSuggestionLocalizationDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @requiredMessage.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get requiredMessage;

  /// No description provided for @recent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recent;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @searching.
  ///
  /// In en, this message translates to:
  /// **'Searching…'**
  String get searching;

  /// No description provided for @searchingQuery.
  ///
  /// In en, this message translates to:
  /// **'Searching “{query}”…'**
  String searchingQuery(String query);

  /// No description provided for @typeToSearch.
  ///
  /// In en, this message translates to:
  /// **'Type to search'**
  String get typeToSearch;

  /// No description provided for @noMatches.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get noMatches;

  /// No description provided for @noMatchesForQuery.
  ///
  /// In en, this message translates to:
  /// **'No matches for “{query}”'**
  String noMatchesForQuery(String query);

  /// No description provided for @loadingMore.
  ///
  /// In en, this message translates to:
  /// **'Loading more…'**
  String get loadingMore;

  /// No description provided for @loadingMoreFromServer.
  ///
  /// In en, this message translates to:
  /// **'Loading more from server…'**
  String get loadingMoreFromServer;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @enter.
  ///
  /// In en, this message translates to:
  /// **'ENTER'**
  String get enter;

  /// No description provided for @fix.
  ///
  /// In en, this message translates to:
  /// **'Fix'**
  String get fix;

  /// No description provided for @unfix.
  ///
  /// In en, this message translates to:
  /// **'Unfix'**
  String get unfix;

  /// No description provided for @advancedSearch.
  ///
  /// In en, this message translates to:
  /// **'Advanced Search'**
  String get advancedSearch;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search…'**
  String get search;

  /// No description provided for @advancedSearchKeyboardHint.
  ///
  /// In en, this message translates to:
  /// **'↑ ↓ TO NAVIGATE   ⏎ TO SELECT   ESC TO CLOSE'**
  String get advancedSearchKeyboardHint;
}

class _SuperAutoSuggestionLocalizationDelegate
    extends LocalizationsDelegate<SuperAutoSuggestionLocalization> {
  const _SuperAutoSuggestionLocalizationDelegate();

  @override
  Future<SuperAutoSuggestionLocalization> load(Locale locale) {
    return SynchronousFuture<SuperAutoSuggestionLocalization>(
      lookupSuperAutoSuggestionLocalization(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_SuperAutoSuggestionLocalizationDelegate old) => false;
}

SuperAutoSuggestionLocalization lookupSuperAutoSuggestionLocalization(
  Locale locale,
) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return SuperAutoSuggestionLocalizationAr();
    case 'en':
      return SuperAutoSuggestionLocalizationEn();
  }

  throw FlutterError(
    'SuperAutoSuggestionLocalization.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
