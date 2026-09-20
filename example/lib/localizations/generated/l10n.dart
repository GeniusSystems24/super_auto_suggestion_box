import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'l10n_ar.dart';
import 'l10n_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of SuperExampleLocalization
/// returned by `SuperExampleLocalization.of(context)`.
///
/// Applications need to include `SuperExampleLocalization.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: SuperExampleLocalization.localizationsDelegates,
///   supportedLocales: SuperExampleLocalization.supportedLocales,
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
/// be consistent with the languages listed in the SuperExampleLocalization.supportedLocales
/// property.
abstract class SuperExampleLocalization {
  SuperExampleLocalization(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static SuperExampleLocalization of(BuildContext context) {
    return Localizations.of<SuperExampleLocalization>(
      context,
      SuperExampleLocalization,
    )!;
  }

  static const LocalizationsDelegate<SuperExampleLocalization> delegate =
      _SuperExampleLocalizationDelegate();

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

  /// No description provided for @validation.
  ///
  /// In en, this message translates to:
  /// **'VALIDATION'**
  String get validation;

  /// No description provided for @fieldOverride.
  ///
  /// In en, this message translates to:
  /// **'Field override'**
  String get fieldOverride;

  /// No description provided for @suffix.
  ///
  /// In en, this message translates to:
  /// **'Suffix'**
  String get suffix;

  /// No description provided for @under.
  ///
  /// In en, this message translates to:
  /// **'Under'**
  String get under;

  /// No description provided for @label.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get label;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @accounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get accounts;

  /// No description provided for @searchAccounts.
  ///
  /// In en, this message translates to:
  /// **'Search accounts...'**
  String get searchAccounts;

  /// No description provided for @recentAccounts.
  ///
  /// In en, this message translates to:
  /// **'Recent Accounts'**
  String get recentAccounts;

  /// No description provided for @pickAccount.
  ///
  /// In en, this message translates to:
  /// **'Pick an account...'**
  String get pickAccount;

  /// No description provided for @requiredAccountLookup.
  ///
  /// In en, this message translates to:
  /// **'Required account lookup.'**
  String get requiredAccountLookup;

  /// No description provided for @selectionCleared.
  ///
  /// In en, this message translates to:
  /// **'Selection cleared'**
  String get selectionCleared;

  /// No description provided for @directoryEntry.
  ///
  /// In en, this message translates to:
  /// **'Directory entry'**
  String get directoryEntry;

  /// No description provided for @accountCode.
  ///
  /// In en, this message translates to:
  /// **'Account code {code}'**
  String accountCode(String code);

  /// No description provided for @searchModes.
  ///
  /// In en, this message translates to:
  /// **'Search Modes'**
  String get searchModes;

  /// No description provided for @searchModesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'TEXTBOX · ADVANCE VIEW · BOTH'**
  String get searchModesSubtitle;

  /// No description provided for @searchModeVersion.
  ///
  /// In en, this message translates to:
  /// **'v1.3.1 · SEARCH MODE'**
  String get searchModeVersion;

  /// No description provided for @threeSearchSurfaces.
  ///
  /// In en, this message translates to:
  /// **'One component, three search surfaces'**
  String get threeSearchSurfaces;

  /// No description provided for @searchModeResponsiveDescription.
  ///
  /// In en, this message translates to:
  /// **'When mode is omitted, desktop platforms default to TextBox. Android, iOS, and Fuchsia default to AdvanceView.'**
  String get searchModeResponsiveDescription;

  /// No description provided for @adaptiveDefault.
  ///
  /// In en, this message translates to:
  /// **'Adaptive default'**
  String get adaptiveDefault;

  /// No description provided for @adaptiveDefaultDescription.
  ///
  /// In en, this message translates to:
  /// **'No mode is passed. Desktop resolves to TextBox; mobile resolves to AdvanceView.'**
  String get adaptiveDefaultDescription;

  /// No description provided for @adaptiveSearch.
  ///
  /// In en, this message translates to:
  /// **'Adaptive search'**
  String get adaptiveSearch;

  /// No description provided for @platformDefaultMode.
  ///
  /// In en, this message translates to:
  /// **'Uses the platform-dependent default mode.'**
  String get platformDefaultMode;

  /// No description provided for @textBox.
  ///
  /// In en, this message translates to:
  /// **'TextBox'**
  String get textBox;

  /// No description provided for @textBoxDescription.
  ///
  /// In en, this message translates to:
  /// **'Classic editable text box with the anchored inline suggestion dropdown.'**
  String get textBoxDescription;

  /// No description provided for @textBoxMode.
  ///
  /// In en, this message translates to:
  /// **'TextBox mode'**
  String get textBoxMode;

  /// No description provided for @typeAndPickInline.
  ///
  /// In en, this message translates to:
  /// **'Type directly and pick from the inline list.'**
  String get typeAndPickInline;

  /// No description provided for @advanceView.
  ///
  /// In en, this message translates to:
  /// **'AdvanceView'**
  String get advanceView;

  /// No description provided for @advanceViewDescription.
  ///
  /// In en, this message translates to:
  /// **'The field becomes a launcher for the larger Advanced Search surface instead of opening the inline dropdown.'**
  String get advanceViewDescription;

  /// No description provided for @advanceViewMode.
  ///
  /// In en, this message translates to:
  /// **'AdvanceView mode'**
  String get advanceViewMode;

  /// No description provided for @openAdvancedView.
  ///
  /// In en, this message translates to:
  /// **'Tap or focus the field to open Advanced View.'**
  String get openAdvancedView;

  /// No description provided for @both.
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get both;

  /// No description provided for @bothDescription.
  ///
  /// In en, this message translates to:
  /// **'Inline TextBox behavior plus Advanced View. Use the advanced-search action or Ctrl/Cmd + F while focused.'**
  String get bothDescription;

  /// No description provided for @bothModes.
  ///
  /// In en, this message translates to:
  /// **'Both modes'**
  String get bothModes;

  /// No description provided for @bothEnabled.
  ///
  /// In en, this message translates to:
  /// **'Inline suggestions and Advanced View are both enabled.'**
  String get bothEnabled;

  /// No description provided for @searchDirectoryHint.
  ///
  /// In en, this message translates to:
  /// **'Name, code, category, or city...'**
  String get searchDirectoryHint;

  /// No description provided for @autovalidateMode.
  ///
  /// In en, this message translates to:
  /// **'Autovalidate Mode'**
  String get autovalidateMode;

  /// No description provided for @formAutovalidation.
  ///
  /// In en, this message translates to:
  /// **'Form Autovalidation'**
  String get formAutovalidation;

  /// No description provided for @formDefault.
  ///
  /// In en, this message translates to:
  /// **'Form default'**
  String get formDefault;

  /// No description provided for @formDefaultDescription.
  ///
  /// In en, this message translates to:
  /// **'Both boxes below read autovalidateMode from the Form.'**
  String get formDefaultDescription;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @always.
  ///
  /// In en, this message translates to:
  /// **'Always'**
  String get always;

  /// No description provided for @onChange.
  ///
  /// In en, this message translates to:
  /// **'On change'**
  String get onChange;

  /// No description provided for @postingAccount.
  ///
  /// In en, this message translates to:
  /// **'Posting account'**
  String get postingAccount;

  /// No description provided for @expenseAccount.
  ///
  /// In en, this message translates to:
  /// **'Expense account'**
  String get expenseAccount;

  /// No description provided for @mustBeExpense.
  ///
  /// In en, this message translates to:
  /// **'Must be an expense account.'**
  String get mustBeExpense;

  /// No description provided for @chooseExpense.
  ///
  /// In en, this message translates to:
  /// **'Choose an expense account.'**
  String get chooseExpense;

  /// No description provided for @validate.
  ///
  /// In en, this message translates to:
  /// **'Validate'**
  String get validate;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @fieldAlwaysValidates.
  ///
  /// In en, this message translates to:
  /// **'This box validates always, independent of the Form mode.'**
  String get fieldAlwaysValidates;

  /// No description provided for @immediateAccount.
  ///
  /// In en, this message translates to:
  /// **'Immediate account'**
  String get immediateAccount;

  /// No description provided for @fieldAutovalidatePrecedence.
  ///
  /// In en, this message translates to:
  /// **'Field-level autovalidateMode takes precedence.'**
  String get fieldAutovalidatePrecedence;

  /// No description provided for @validationPosition.
  ///
  /// In en, this message translates to:
  /// **'Validation Position'**
  String get validationPosition;

  /// No description provided for @feedbackPlacement.
  ///
  /// In en, this message translates to:
  /// **'Feedback Placement'**
  String get feedbackPlacement;

  /// No description provided for @globalDefault.
  ///
  /// In en, this message translates to:
  /// **'Global default'**
  String get globalDefault;

  /// No description provided for @globalDefaultDescription.
  ///
  /// In en, this message translates to:
  /// **'Leave it responsive, or set one package-wide position.'**
  String get globalDefaultDescription;

  /// No description provided for @responsive.
  ///
  /// In en, this message translates to:
  /// **'Responsive'**
  String get responsive;

  /// No description provided for @usesPackageDefault.
  ///
  /// In en, this message translates to:
  /// **'Uses package default'**
  String get usesPackageDefault;

  /// No description provided for @fieldPositionDescription.
  ///
  /// In en, this message translates to:
  /// **'The selected field position overrides the package default.'**
  String get fieldPositionDescription;

  /// No description provided for @usesFieldPosition.
  ///
  /// In en, this message translates to:
  /// **'Uses field position'**
  String get usesFieldPosition;

  /// No description provided for @exampleScreen.
  ///
  /// In en, this message translates to:
  /// **'Example Screen'**
  String get exampleScreen;

  /// No description provided for @documentReference.
  ///
  /// In en, this message translates to:
  /// **'Document Reference'**
  String get documentReference;

  /// No description provided for @directoryEntryNumber.
  ///
  /// In en, this message translates to:
  /// **'Directory entry {number}'**
  String directoryEntryNumber(int number);

  /// No description provided for @stringSource.
  ///
  /// In en, this message translates to:
  /// **'String source'**
  String get stringSource;

  /// No description provided for @stringSourceDescription.
  ///
  /// In en, this message translates to:
  /// **'Label-equals-value convenience source'**
  String get stringSourceDescription;

  /// No description provided for @listSource.
  ///
  /// In en, this message translates to:
  /// **'List source'**
  String get listSource;

  /// No description provided for @listSourceDescription.
  ///
  /// In en, this message translates to:
  /// **'In-memory contains matching'**
  String get listSourceDescription;

  /// No description provided for @fuzzySource.
  ///
  /// In en, this message translates to:
  /// **'Fuzzy source'**
  String get fuzzySource;

  /// No description provided for @fuzzySourceDescription.
  ///
  /// In en, this message translates to:
  /// **'Typo-tolerant in-memory ranking'**
  String get fuzzySourceDescription;

  /// No description provided for @asyncSource.
  ///
  /// In en, this message translates to:
  /// **'Async source'**
  String get asyncSource;

  /// No description provided for @asyncSourceDescription.
  ///
  /// In en, this message translates to:
  /// **'Server-style asynchronous lookup'**
  String get asyncSourceDescription;

  /// No description provided for @hybridSource.
  ///
  /// In en, this message translates to:
  /// **'Hybrid source'**
  String get hybridSource;

  /// No description provided for @hybridSourceDescription.
  ///
  /// In en, this message translates to:
  /// **'Immediate local results merged with remote data'**
  String get hybridSourceDescription;

  /// No description provided for @remoteFallback.
  ///
  /// In en, this message translates to:
  /// **'Remote fallback'**
  String get remoteFallback;

  /// No description provided for @remoteFallbackDescription.
  ///
  /// In en, this message translates to:
  /// **'Local-first lookup with remote fallback'**
  String get remoteFallbackDescription;

  /// No description provided for @pagedSource.
  ///
  /// In en, this message translates to:
  /// **'Paged source'**
  String get pagedSource;

  /// No description provided for @pagedSourceDescription.
  ///
  /// In en, this message translates to:
  /// **'Infinite scrolling through server pages'**
  String get pagedSourceDescription;

  /// No description provided for @sourceExample.
  ///
  /// In en, this message translates to:
  /// **'SOURCE EXAMPLE'**
  String get sourceExample;

  /// No description provided for @sourceVersion.
  ///
  /// In en, this message translates to:
  /// **'v1.3.1 · {title}'**
  String sourceVersion(String title);

  /// No description provided for @basicLookup.
  ///
  /// In en, this message translates to:
  /// **'Basic Lookup'**
  String get basicLookup;

  /// No description provided for @widgetOwnsSource.
  ///
  /// In en, this message translates to:
  /// **'The widget owns the source and controller.'**
  String get widgetOwnsSource;

  /// No description provided for @externalController.
  ///
  /// In en, this message translates to:
  /// **'External Controller'**
  String get externalController;

  /// No description provided for @controlFromHost.
  ///
  /// In en, this message translates to:
  /// **'Read selection and control the field from host code.'**
  String get controlFromHost;

  /// No description provided for @controlledAccount.
  ///
  /// In en, this message translates to:
  /// **'Controlled Account'**
  String get controlledAccount;

  /// No description provided for @hostControlledLookup.
  ///
  /// In en, this message translates to:
  /// **'Host-controlled lookup...'**
  String get hostControlledLookup;

  /// No description provided for @multiSelect.
  ///
  /// In en, this message translates to:
  /// **'Multi-select'**
  String get multiSelect;

  /// No description provided for @selectSeveralValues.
  ///
  /// In en, this message translates to:
  /// **'Select several raw values from the same source type.'**
  String get selectSeveralValues;

  /// No description provided for @selectAccounts.
  ///
  /// In en, this message translates to:
  /// **'Select accounts...'**
  String get selectAccounts;

  /// No description provided for @recentSelections.
  ///
  /// In en, this message translates to:
  /// **'Recent Selections'**
  String get recentSelections;

  /// No description provided for @committedValuesPinned.
  ///
  /// In en, this message translates to:
  /// **'Committed values are pinned when the query is empty.'**
  String get committedValuesPinned;

  /// No description provided for @accountNumber.
  ///
  /// In en, this message translates to:
  /// **'Account {number}'**
  String accountNumber(int number);

  /// No description provided for @allItemScenarios.
  ///
  /// In en, this message translates to:
  /// **'ALL ITEM SCENARIOS'**
  String get allItemScenarios;

  /// No description provided for @itemApiVersion.
  ///
  /// In en, this message translates to:
  /// **'v1.3.1 · ITEM API'**
  String get itemApiVersion;

  /// No description provided for @everyItemScenario.
  ///
  /// In en, this message translates to:
  /// **'Every SuperAutoSuggestionsItem scenario'**
  String get everyItemScenario;

  /// No description provided for @itemScenarioOverview.
  ///
  /// In en, this message translates to:
  /// **'The list below covers text metadata, custom widgets, grouping, keywords, static enabled state, Stream<bool> enabledSnapshot, and a combined rich item.'**
  String get itemScenarioOverview;

  /// No description provided for @enabledSnapshotDescription.
  ///
  /// In en, this message translates to:
  /// **'This switch updates the Stream<bool> used by the enabledSnapshot scenario.'**
  String get enabledSnapshotDescription;

  /// No description provided for @dynamicSuggestionEnabled.
  ///
  /// In en, this message translates to:
  /// **'Dynamic suggestion is enabled'**
  String get dynamicSuggestionEnabled;

  /// No description provided for @dynamicSuggestionDisabled.
  ///
  /// In en, this message translates to:
  /// **'Dynamic suggestion is disabled'**
  String get dynamicSuggestionDisabled;

  /// No description provided for @allItemScenariosTitle.
  ///
  /// In en, this message translates to:
  /// **'All item scenarios'**
  String get allItemScenariosTitle;

  /// No description provided for @inspectItemCases.
  ///
  /// In en, this message translates to:
  /// **'Open the suggestions and inspect each rendering/API case.'**
  String get inspectItemCases;

  /// No description provided for @itemScenariosLabel.
  ///
  /// In en, this message translates to:
  /// **'SuperAutoSuggestionsItem scenarios'**
  String get itemScenariosLabel;

  /// No description provided for @openEmptyQuery.
  ///
  /// In en, this message translates to:
  /// **'Open the list with an empty query to see every case.'**
  String get openEmptyQuery;

  /// No description provided for @searchTitleKeywords.
  ///
  /// In en, this message translates to:
  /// **'Search title or keywords...'**
  String get searchTitleKeywords;

  /// No description provided for @plainTitleText.
  ///
  /// In en, this message translates to:
  /// **'Plain title text'**
  String get plainTitleText;

  /// No description provided for @descriptionAsText.
  ///
  /// In en, this message translates to:
  /// **'Description as text'**
  String get descriptionAsText;

  /// No description provided for @descriptionTextSupport.
  ///
  /// In en, this message translates to:
  /// **'descriptionText renders supporting plain text'**
  String get descriptionTextSupport;

  /// No description provided for @descriptionAsWidget.
  ///
  /// In en, this message translates to:
  /// **'Description as widget'**
  String get descriptionAsWidget;

  /// No description provided for @customDescriptionWidget.
  ///
  /// In en, this message translates to:
  /// **'Custom description widget'**
  String get customDescriptionWidget;

  /// No description provided for @trailingText.
  ///
  /// In en, this message translates to:
  /// **'Trailing text'**
  String get trailingText;

  /// No description provided for @trailingWidget.
  ///
  /// In en, this message translates to:
  /// **'Trailing widget'**
  String get trailingWidget;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get active;

  /// No description provided for @customIconWidget.
  ///
  /// In en, this message translates to:
  /// **'Custom icon widget'**
  String get customIconWidget;

  /// No description provided for @groupedSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Grouped suggestion'**
  String get groupedSuggestion;

  /// No description provided for @metadataScenarios.
  ///
  /// In en, this message translates to:
  /// **'Metadata scenarios'**
  String get metadataScenarios;

  /// No description provided for @searchableAliases.
  ///
  /// In en, this message translates to:
  /// **'Searchable aliases'**
  String get searchableAliases;

  /// No description provided for @searchAliasesHint.
  ///
  /// In en, this message translates to:
  /// **'Search for: invoice, vendor, INV-1042'**
  String get searchAliasesHint;

  /// No description provided for @staticallyDisabled.
  ///
  /// In en, this message translates to:
  /// **'Statically disabled'**
  String get staticallyDisabled;

  /// No description provided for @streamControlledState.
  ///
  /// In en, this message translates to:
  /// **'Stream-controlled enabled state'**
  String get streamControlledState;

  /// No description provided for @streamControlledDescription.
  ///
  /// In en, this message translates to:
  /// **'enabledSnapshot: Stream<bool> · toggle it above the field'**
  String get streamControlledDescription;

  /// No description provided for @combinedRichSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Combined rich suggestion'**
  String get combinedRichSuggestion;

  /// No description provided for @richDescription.
  ///
  /// In en, this message translates to:
  /// **'Widget description · searchable title remains titleText'**
  String get richDescription;

  /// No description provided for @richScenarios.
  ///
  /// In en, this message translates to:
  /// **'Rich scenarios'**
  String get richScenarios;

  /// No description provided for @autoSuggestionBox.
  ///
  /// In en, this message translates to:
  /// **'Auto Suggestion Box'**
  String get autoSuggestionBox;

  /// No description provided for @accountLookup.
  ///
  /// In en, this message translates to:
  /// **'Account Lookup'**
  String get accountLookup;

  /// No description provided for @postToAccount.
  ///
  /// In en, this message translates to:
  /// **'Post To Account'**
  String get postToAccount;

  /// No description provided for @searchChartAccounts.
  ///
  /// In en, this message translates to:
  /// **'Search the chart of accounts by name or code'**
  String get searchChartAccounts;

  /// No description provided for @accountsReceivableExample.
  ///
  /// In en, this message translates to:
  /// **'e.g. Accounts Receivable'**
  String get accountsReceivableExample;

  /// No description provided for @tagCostCenters.
  ///
  /// In en, this message translates to:
  /// **'Tag Cost Centers'**
  String get tagCostCenters;

  /// No description provided for @assignCostCenters.
  ///
  /// In en, this message translates to:
  /// **'Assign one or more cost centers to this entry'**
  String get assignCostCenters;

  /// No description provided for @quickFilter.
  ///
  /// In en, this message translates to:
  /// **'Quick Filter'**
  String get quickFilter;

  /// No description provided for @fuzzyMatchHint.
  ///
  /// In en, this message translates to:
  /// **'Fuzzy match - type loosely'**
  String get fuzzyMatchHint;

  /// No description provided for @rdhExample.
  ///
  /// In en, this message translates to:
  /// **'e.g. rdh'**
  String get rdhExample;

  /// No description provided for @selectVendor.
  ///
  /// In en, this message translates to:
  /// **'Select Vendor'**
  String get selectVendor;

  /// No description provided for @vendorRemoteDescription.
  ///
  /// In en, this message translates to:
  /// **'Local vendors show instantly; server search runs when local matches are few'**
  String get vendorRemoteDescription;

  /// No description provided for @vendorExample.
  ///
  /// In en, this message translates to:
  /// **'e.g. cement, freight, glass...'**
  String get vendorExample;

  /// No description provided for @vendorDirectory.
  ///
  /// In en, this message translates to:
  /// **'Vendor Directory'**
  String get vendorDirectory;

  /// No description provided for @advancedSearchShortcutDescription.
  ///
  /// In en, this message translates to:
  /// **'Focus the field and press Ctrl / Cmd + F to open Advanced Search'**
  String get advancedSearchShortcutDescription;

  /// No description provided for @searchDirectory.
  ///
  /// In en, this message translates to:
  /// **'Search the directory... (Cmd/Ctrl+F)'**
  String get searchDirectory;

  /// No description provided for @requiredCustomValidator.
  ///
  /// In en, this message translates to:
  /// **'Required field with a custom validator - leave it empty and tab away'**
  String get requiredCustomValidator;

  /// No description provided for @debitAccount.
  ///
  /// In en, this message translates to:
  /// **'Debit Account'**
  String get debitAccount;

  /// No description provided for @pickAccountTypes.
  ///
  /// In en, this message translates to:
  /// **'Pick an asset, liability, equity, income or expense account'**
  String get pickAccountTypes;

  /// No description provided for @pickAccountFromList.
  ///
  /// In en, this message translates to:
  /// **'Pick an account from the list'**
  String get pickAccountFromList;

  /// No description provided for @lockedAccount.
  ///
  /// In en, this message translates to:
  /// **'Locked Account'**
  String get lockedAccount;

  /// No description provided for @disabledFieldDescription.
  ///
  /// In en, this message translates to:
  /// **'A disabled field blocks typing and opening the overlay'**
  String get disabledFieldDescription;

  /// No description provided for @reconciliationAccount.
  ///
  /// In en, this message translates to:
  /// **'Reconciliation Account'**
  String get reconciliationAccount;

  /// No description provided for @themedField.
  ///
  /// In en, this message translates to:
  /// **'Themed Field'**
  String get themedField;

  /// No description provided for @themedFieldDescription.
  ///
  /// In en, this message translates to:
  /// **'A theme assigned directly to one box - green focused fill, border and bold text'**
  String get themedFieldDescription;

  /// No description provided for @ledgerAccount.
  ///
  /// In en, this message translates to:
  /// **'Ledger Account'**
  String get ledgerAccount;

  /// No description provided for @customFocusedStyleHint.
  ///
  /// In en, this message translates to:
  /// **'Focus me to see the custom focused style'**
  String get customFocusedStyleHint;

  /// No description provided for @recentAccountsDescription.
  ///
  /// In en, this message translates to:
  /// **'Pick a few, clear the field and reopen - recent picks pin to the top'**
  String get recentAccountsDescription;

  /// No description provided for @projectTag.
  ///
  /// In en, this message translates to:
  /// **'Project Tag'**
  String get projectTag;

  /// No description provided for @createProjectDescription.
  ///
  /// In en, this message translates to:
  /// **'Type a missing name and press Enter to create it'**
  String get createProjectDescription;

  /// No description provided for @project.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get project;

  /// No description provided for @seafrontVillasExample.
  ///
  /// In en, this message translates to:
  /// **'e.g. Seafront Villas'**
  String get seafrontVillasExample;

  /// No description provided for @itemCatalog.
  ///
  /// In en, this message translates to:
  /// **'Item Catalog'**
  String get itemCatalog;

  /// No description provided for @itemCatalogDescription.
  ///
  /// In en, this message translates to:
  /// **'Large master data - 12 rows per page; scroll the dropdown to load more'**
  String get itemCatalogDescription;

  /// No description provided for @item.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get item;

  /// No description provided for @search64Items.
  ///
  /// In en, this message translates to:
  /// **'Search 64 items...'**
  String get search64Items;

  /// No description provided for @boundAccount.
  ///
  /// In en, this message translates to:
  /// **'Bound Account'**
  String get boundAccount;

  /// No description provided for @boundAccountDescription.
  ///
  /// In en, this message translates to:
  /// **'Bind by stored code, then lock to a read-only posted view'**
  String get boundAccountDescription;

  /// No description provided for @pickOrBindCode.
  ///
  /// In en, this message translates to:
  /// **'Pick or bind by code'**
  String get pickOrBindCode;

  /// No description provided for @bind1020.
  ///
  /// In en, this message translates to:
  /// **'Bind 1020'**
  String get bind1020;

  /// No description provided for @bind4000.
  ///
  /// In en, this message translates to:
  /// **'Bind 4000'**
  String get bind4000;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @lockReadOnly.
  ///
  /// In en, this message translates to:
  /// **'Lock (read-only)'**
  String get lockReadOnly;

  /// No description provided for @erpDocumentReference.
  ///
  /// In en, this message translates to:
  /// **'ERP Document Reference'**
  String get erpDocumentReference;

  /// No description provided for @erpReferenceDescription.
  ///
  /// In en, this message translates to:
  /// **'Type a prefix, press Tab to accept completion, then Tab again to move focus'**
  String get erpReferenceDescription;

  /// No description provided for @inv1042Example.
  ///
  /// In en, this message translates to:
  /// **'e.g. INV-1042'**
  String get inv1042Example;

  /// No description provided for @fieldTapped.
  ///
  /// In en, this message translates to:
  /// **'Field tapped'**
  String get fieldTapped;

  /// No description provided for @pointerDownOutside.
  ///
  /// In en, this message translates to:
  /// **'Pointer down outside'**
  String get pointerDownOutside;

  /// No description provided for @pointerUpOutside.
  ///
  /// In en, this message translates to:
  /// **'Pointer up outside'**
  String get pointerUpOutside;

  /// No description provided for @selectedValue.
  ///
  /// In en, this message translates to:
  /// **'Selected: {value}'**
  String selectedValue(String value);

  /// No description provided for @validateAndSave.
  ///
  /// In en, this message translates to:
  /// **'Validate & Save'**
  String get validateAndSave;

  /// No description provided for @formValidated.
  ///
  /// In en, this message translates to:
  /// **'Form validated'**
  String get formValidated;

  /// No description provided for @savedStatus.
  ///
  /// In en, this message translates to:
  /// **'Saved: {reference} - {event}'**
  String savedStatus(String reference, String event);

  /// No description provided for @fixableAccount.
  ///
  /// In en, this message translates to:
  /// **'Fixable Account'**
  String get fixableAccount;

  /// No description provided for @fixableDescription.
  ///
  /// In en, this message translates to:
  /// **'Use the small label action to protect or unlock the current value'**
  String get fixableDescription;

  /// No description provided for @settlementAccount.
  ///
  /// In en, this message translates to:
  /// **'Settlement Account'**
  String get settlementAccount;

  /// No description provided for @lockAfterSelecting.
  ///
  /// In en, this message translates to:
  /// **'Lock the field after selecting an account'**
  String get lockAfterSelecting;

  /// No description provided for @pickThenFix.
  ///
  /// In en, this message translates to:
  /// **'Pick an account, then fix it'**
  String get pickThenFix;

  /// No description provided for @focusField.
  ///
  /// In en, this message translates to:
  /// **'Focus field'**
  String get focusField;

  /// No description provided for @validateField.
  ///
  /// In en, this message translates to:
  /// **'Validate field'**
  String get validateField;

  /// No description provided for @inputDecoration.
  ///
  /// In en, this message translates to:
  /// **'Input Decoration'**
  String get inputDecoration;

  /// No description provided for @inputDecorationDescription.
  ///
  /// In en, this message translates to:
  /// **'Label, helper, and placeholder copy use Flutter standard InputDecoration'**
  String get inputDecorationDescription;

  /// No description provided for @cashAccount.
  ///
  /// In en, this message translates to:
  /// **'Cash Account'**
  String get cashAccount;

  /// No description provided for @standardInputHelper.
  ///
  /// In en, this message translates to:
  /// **'Standard InputDecoration helper text'**
  String get standardInputHelper;

  /// No description provided for @searchByAccount.
  ///
  /// In en, this message translates to:
  /// **'Search by account code or name'**
  String get searchByAccount;

  /// No description provided for @projectTagDescription.
  ///
  /// In en, this message translates to:
  /// **'Project tag'**
  String get projectTagDescription;

  /// No description provided for @catalogItem.
  ///
  /// In en, this message translates to:
  /// **'Item {number}'**
  String catalogItem(String number);

  /// No description provided for @warehouseDescription.
  ///
  /// In en, this message translates to:
  /// **'{sku} - Warehouse A'**
  String warehouseDescription(String sku);

  /// No description provided for @inStock.
  ///
  /// In en, this message translates to:
  /// **'{count} in stock'**
  String inStock(int count);

  /// No description provided for @localRiyadh.
  ///
  /// In en, this message translates to:
  /// **'Local - Riyadh'**
  String get localRiyadh;

  /// No description provided for @serverRemote.
  ///
  /// In en, this message translates to:
  /// **'Server - remote'**
  String get serverRemote;

  /// No description provided for @noSelectionEventYet.
  ///
  /// In en, this message translates to:
  /// **'No selection event yet'**
  String get noSelectionEventYet;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Super Auto Suggestion Box'**
  String get appTitle;

  /// No description provided for @galleryEyebrow.
  ///
  /// In en, this message translates to:
  /// **'SUPER AUTO SUGGESTION BOX • GALLERY'**
  String get galleryEyebrow;

  /// No description provided for @componentDemos.
  ///
  /// In en, this message translates to:
  /// **'Component Demos'**
  String get componentDemos;

  /// No description provided for @suggestionItemScenarios.
  ///
  /// In en, this message translates to:
  /// **'Suggestion item scenarios'**
  String get suggestionItemScenarios;

  /// No description provided for @suggestionItemScenariosGalleryDescription.
  ///
  /// In en, this message translates to:
  /// **'All SuperAutoSuggestionsItem fields · enabledSnapshot'**
  String get suggestionItemScenariosGalleryDescription;

  /// No description provided for @autovalidateGalleryDescription.
  ///
  /// In en, this message translates to:
  /// **'Field value · Form default · disabled fallback'**
  String get autovalidateGalleryDescription;

  /// No description provided for @validationPositionGalleryDescription.
  ///
  /// In en, this message translates to:
  /// **'Suffix icon · under-box text · label-trailing icon'**
  String get validationPositionGalleryDescription;

  /// No description provided for @advancedSearch.
  ///
  /// In en, this message translates to:
  /// **'Advanced Search'**
  String get advancedSearch;

  /// No description provided for @advancedSearchGalleryDescription.
  ///
  /// In en, this message translates to:
  /// **'Ctrl / Cmd + F · built-in dialog · custom advanced-search surface'**
  String get advancedSearchGalleryDescription;

  /// No description provided for @autoSuggestionBoxGalleryDescription.
  ///
  /// In en, this message translates to:
  /// **'Typeahead · recents · create · paged · multi-select · fuzzy'**
  String get autoSuggestionBoxGalleryDescription;

  /// No description provided for @sourceDemoCapabilities.
  ///
  /// In en, this message translates to:
  /// **'basic · controlled · multi-select · recents'**
  String get sourceDemoCapabilities;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light Theme'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get darkTheme;

  /// No description provided for @switchToArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية (RTL)'**
  String get switchToArabic;

  /// No description provided for @switchToEnglish.
  ///
  /// In en, this message translates to:
  /// **'English (LTR)'**
  String get switchToEnglish;
}

class _SuperExampleLocalizationDelegate
    extends LocalizationsDelegate<SuperExampleLocalization> {
  const _SuperExampleLocalizationDelegate();

  @override
  Future<SuperExampleLocalization> load(Locale locale) {
    return SynchronousFuture<SuperExampleLocalization>(
      lookupSuperExampleLocalization(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_SuperExampleLocalizationDelegate old) => false;
}

SuperExampleLocalization lookupSuperExampleLocalization(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return SuperExampleLocalizationAr();
    case 'en':
      return SuperExampleLocalizationEn();
  }

  throw FlutterError(
    'SuperExampleLocalization.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
