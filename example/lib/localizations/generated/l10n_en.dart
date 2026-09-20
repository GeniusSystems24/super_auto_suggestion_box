// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SuperExampleLocalizationEn extends SuperExampleLocalization {
  SuperExampleLocalizationEn([String locale = 'en']) : super(locale);

  @override
  String get validation => 'VALIDATION';

  @override
  String get fieldOverride => 'Field override';

  @override
  String get suffix => 'Suffix';

  @override
  String get under => 'Under';

  @override
  String get label => 'Label';

  @override
  String get account => 'Account';

  @override
  String get accounts => 'Accounts';

  @override
  String get searchAccounts => 'Search accounts...';

  @override
  String get recentAccounts => 'Recent Accounts';

  @override
  String get pickAccount => 'Pick an account...';

  @override
  String get requiredAccountLookup => 'Required account lookup.';

  @override
  String get selectionCleared => 'Selection cleared';

  @override
  String get directoryEntry => 'Directory entry';

  @override
  String accountCode(String code) {
    return 'Account code $code';
  }

  @override
  String get searchModes => 'Search Modes';

  @override
  String get searchModesSubtitle => 'TEXTBOX · ADVANCE VIEW · BOTH';

  @override
  String get searchModeVersion => 'v1.3.1 · SEARCH MODE';

  @override
  String get threeSearchSurfaces => 'One component, three search surfaces';

  @override
  String get searchModeResponsiveDescription =>
      'When mode is omitted, desktop platforms default to TextBox. Android, iOS, and Fuchsia default to AdvanceView.';

  @override
  String get adaptiveDefault => 'Adaptive default';

  @override
  String get adaptiveDefaultDescription =>
      'No mode is passed. Desktop resolves to TextBox; mobile resolves to AdvanceView.';

  @override
  String get adaptiveSearch => 'Adaptive search';

  @override
  String get platformDefaultMode => 'Uses the platform-dependent default mode.';

  @override
  String get textBox => 'TextBox';

  @override
  String get textBoxDescription =>
      'Classic editable text box with the anchored inline suggestion dropdown.';

  @override
  String get textBoxMode => 'TextBox mode';

  @override
  String get typeAndPickInline =>
      'Type directly and pick from the inline list.';

  @override
  String get advanceView => 'AdvanceView';

  @override
  String get advanceViewDescription =>
      'The field becomes a launcher for the larger Advanced Search surface instead of opening the inline dropdown.';

  @override
  String get advanceViewMode => 'AdvanceView mode';

  @override
  String get openAdvancedView =>
      'Tap or focus the field to open Advanced View.';

  @override
  String get both => 'Both';

  @override
  String get bothDescription =>
      'Inline TextBox behavior plus Advanced View. Use the advanced-search action or Ctrl/Cmd + F while focused.';

  @override
  String get bothModes => 'Both modes';

  @override
  String get bothEnabled =>
      'Inline suggestions and Advanced View are both enabled.';

  @override
  String get searchDirectoryHint => 'Name, code, category, or city...';

  @override
  String get autovalidateMode => 'Autovalidate Mode';

  @override
  String get formAutovalidation => 'Form Autovalidation';

  @override
  String get formDefault => 'Form default';

  @override
  String get formDefaultDescription =>
      'Both boxes below read autovalidateMode from the Form.';

  @override
  String get disabled => 'Disabled';

  @override
  String get always => 'Always';

  @override
  String get onChange => 'On change';

  @override
  String get postingAccount => 'Posting account';

  @override
  String get expenseAccount => 'Expense account';

  @override
  String get mustBeExpense => 'Must be an expense account.';

  @override
  String get chooseExpense => 'Choose an expense account.';

  @override
  String get validate => 'Validate';

  @override
  String get reset => 'Reset';

  @override
  String get fieldAlwaysValidates =>
      'This box validates always, independent of the Form mode.';

  @override
  String get immediateAccount => 'Immediate account';

  @override
  String get fieldAutovalidatePrecedence =>
      'Field-level autovalidateMode takes precedence.';

  @override
  String get validationPosition => 'Validation Position';

  @override
  String get feedbackPlacement => 'Feedback Placement';

  @override
  String get globalDefault => 'Global default';

  @override
  String get globalDefaultDescription =>
      'Leave it responsive, or set one package-wide position.';

  @override
  String get responsive => 'Responsive';

  @override
  String get usesPackageDefault => 'Uses package default';

  @override
  String get fieldPositionDescription =>
      'The selected field position overrides the package default.';

  @override
  String get usesFieldPosition => 'Uses field position';

  @override
  String get exampleScreen => 'Example Screen';

  @override
  String get documentReference => 'Document Reference';

  @override
  String directoryEntryNumber(int number) {
    return 'Directory entry $number';
  }

  @override
  String get stringSource => 'String source';

  @override
  String get stringSourceDescription => 'Label-equals-value convenience source';

  @override
  String get listSource => 'List source';

  @override
  String get listSourceDescription => 'In-memory contains matching';

  @override
  String get fuzzySource => 'Fuzzy source';

  @override
  String get fuzzySourceDescription => 'Typo-tolerant in-memory ranking';

  @override
  String get asyncSource => 'Async source';

  @override
  String get asyncSourceDescription => 'Server-style asynchronous lookup';

  @override
  String get hybridSource => 'Hybrid source';

  @override
  String get hybridSourceDescription =>
      'Immediate local results merged with remote data';

  @override
  String get remoteFallback => 'Remote fallback';

  @override
  String get remoteFallbackDescription =>
      'Local-first lookup with remote fallback';

  @override
  String get pagedSource => 'Paged source';

  @override
  String get pagedSourceDescription =>
      'Infinite scrolling through server pages';

  @override
  String get sourceExample => 'SOURCE EXAMPLE';

  @override
  String sourceVersion(String title) {
    return 'v1.3.1 · $title';
  }

  @override
  String get basicLookup => 'Basic Lookup';

  @override
  String get widgetOwnsSource => 'The widget owns the source and controller.';

  @override
  String get externalController => 'External Controller';

  @override
  String get controlFromHost =>
      'Read selection and control the field from host code.';

  @override
  String get controlledAccount => 'Controlled Account';

  @override
  String get hostControlledLookup => 'Host-controlled lookup...';

  @override
  String get multiSelect => 'Multi-select';

  @override
  String get selectSeveralValues =>
      'Select several raw values from the same source type.';

  @override
  String get selectAccounts => 'Select accounts...';

  @override
  String get recentSelections => 'Recent Selections';

  @override
  String get committedValuesPinned =>
      'Committed values are pinned when the query is empty.';

  @override
  String accountNumber(int number) {
    return 'Account $number';
  }

  @override
  String get allItemScenarios => 'ALL ITEM SCENARIOS';

  @override
  String get itemApiVersion => 'v1.3.1 · ITEM API';

  @override
  String get everyItemScenario => 'Every SuperAutoSuggestionsItem scenario';

  @override
  String get itemScenarioOverview =>
      'The list below covers text metadata, custom widgets, grouping, keywords, static enabled state, Stream<bool> enabledSnapshot, and a combined rich item.';

  @override
  String get enabledSnapshotDescription =>
      'This switch updates the Stream<bool> used by the enabledSnapshot scenario.';

  @override
  String get dynamicSuggestionEnabled => 'Dynamic suggestion is enabled';

  @override
  String get dynamicSuggestionDisabled => 'Dynamic suggestion is disabled';

  @override
  String get allItemScenariosTitle => 'All item scenarios';

  @override
  String get inspectItemCases =>
      'Open the suggestions and inspect each rendering/API case.';

  @override
  String get itemScenariosLabel => 'SuperAutoSuggestionsItem scenarios';

  @override
  String get openEmptyQuery =>
      'Open the list with an empty query to see every case.';

  @override
  String get searchTitleKeywords => 'Search title or keywords...';

  @override
  String get plainTitleText => 'Plain title text';

  @override
  String get descriptionAsText => 'Description as text';

  @override
  String get descriptionTextSupport =>
      'descriptionText renders supporting plain text';

  @override
  String get descriptionAsWidget => 'Description as widget';

  @override
  String get customDescriptionWidget => 'Custom description widget';

  @override
  String get trailingText => 'Trailing text';

  @override
  String get trailingWidget => 'Trailing widget';

  @override
  String get active => 'ACTIVE';

  @override
  String get customIconWidget => 'Custom icon widget';

  @override
  String get groupedSuggestion => 'Grouped suggestion';

  @override
  String get metadataScenarios => 'Metadata scenarios';

  @override
  String get searchableAliases => 'Searchable aliases';

  @override
  String get searchAliasesHint => 'Search for: invoice, vendor, INV-1042';

  @override
  String get staticallyDisabled => 'Statically disabled';

  @override
  String get streamControlledState => 'Stream-controlled enabled state';

  @override
  String get streamControlledDescription =>
      'enabledSnapshot: Stream<bool> · toggle it above the field';

  @override
  String get combinedRichSuggestion => 'Combined rich suggestion';

  @override
  String get richDescription =>
      'Widget description · searchable title remains titleText';

  @override
  String get richScenarios => 'Rich scenarios';

  @override
  String get autoSuggestionBox => 'Auto Suggestion Box';

  @override
  String get accountLookup => 'Account Lookup';

  @override
  String get postToAccount => 'Post To Account';

  @override
  String get searchChartAccounts =>
      'Search the chart of accounts by name or code';

  @override
  String get accountsReceivableExample => 'e.g. Accounts Receivable';

  @override
  String get tagCostCenters => 'Tag Cost Centers';

  @override
  String get assignCostCenters =>
      'Assign one or more cost centers to this entry';

  @override
  String get quickFilter => 'Quick Filter';

  @override
  String get fuzzyMatchHint => 'Fuzzy match - type loosely';

  @override
  String get rdhExample => 'e.g. rdh';

  @override
  String get selectVendor => 'Select Vendor';

  @override
  String get vendorRemoteDescription =>
      'Local vendors show instantly; server search runs when local matches are few';

  @override
  String get vendorExample => 'e.g. cement, freight, glass...';

  @override
  String get vendorDirectory => 'Vendor Directory';

  @override
  String get advancedSearchShortcutDescription =>
      'Focus the field and press Ctrl / Cmd + F to open Advanced Search';

  @override
  String get searchDirectory => 'Search the directory... (Cmd/Ctrl+F)';

  @override
  String get requiredCustomValidator =>
      'Required field with a custom validator - leave it empty and tab away';

  @override
  String get debitAccount => 'Debit Account';

  @override
  String get pickAccountTypes =>
      'Pick an asset, liability, equity, income or expense account';

  @override
  String get pickAccountFromList => 'Pick an account from the list';

  @override
  String get lockedAccount => 'Locked Account';

  @override
  String get disabledFieldDescription =>
      'A disabled field blocks typing and opening the overlay';

  @override
  String get reconciliationAccount => 'Reconciliation Account';

  @override
  String get themedField => 'Themed Field';

  @override
  String get themedFieldDescription =>
      'A theme assigned directly to one box - green focused fill, border and bold text';

  @override
  String get ledgerAccount => 'Ledger Account';

  @override
  String get customFocusedStyleHint =>
      'Focus me to see the custom focused style';

  @override
  String get recentAccountsDescription =>
      'Pick a few, clear the field and reopen - recent picks pin to the top';

  @override
  String get projectTag => 'Project Tag';

  @override
  String get createProjectDescription =>
      'Type a missing name and press Enter to create it';

  @override
  String get project => 'Project';

  @override
  String get seafrontVillasExample => 'e.g. Seafront Villas';

  @override
  String get itemCatalog => 'Item Catalog';

  @override
  String get itemCatalogDescription =>
      'Large master data - 12 rows per page; scroll the dropdown to load more';

  @override
  String get item => 'Item';

  @override
  String get search64Items => 'Search 64 items...';

  @override
  String get boundAccount => 'Bound Account';

  @override
  String get boundAccountDescription =>
      'Bind by stored code, then lock to a read-only posted view';

  @override
  String get pickOrBindCode => 'Pick or bind by code';

  @override
  String get bind1020 => 'Bind 1020';

  @override
  String get bind4000 => 'Bind 4000';

  @override
  String get edit => 'Edit';

  @override
  String get lockReadOnly => 'Lock (read-only)';

  @override
  String get erpDocumentReference => 'ERP Document Reference';

  @override
  String get erpReferenceDescription =>
      'Type a prefix, press Tab to accept completion, then Tab again to move focus';

  @override
  String get inv1042Example => 'e.g. INV-1042';

  @override
  String get fieldTapped => 'Field tapped';

  @override
  String get pointerDownOutside => 'Pointer down outside';

  @override
  String get pointerUpOutside => 'Pointer up outside';

  @override
  String selectedValue(String value) {
    return 'Selected: $value';
  }

  @override
  String get validateAndSave => 'Validate & Save';

  @override
  String get formValidated => 'Form validated';

  @override
  String savedStatus(String reference, String event) {
    return 'Saved: $reference - $event';
  }

  @override
  String get fixableAccount => 'Fixable Account';

  @override
  String get fixableDescription =>
      'Use the small label action to protect or unlock the current value';

  @override
  String get settlementAccount => 'Settlement Account';

  @override
  String get lockAfterSelecting => 'Lock the field after selecting an account';

  @override
  String get pickThenFix => 'Pick an account, then fix it';

  @override
  String get focusField => 'Focus field';

  @override
  String get validateField => 'Validate field';

  @override
  String get inputDecoration => 'Input Decoration';

  @override
  String get inputDecorationDescription =>
      'Label, helper, and placeholder copy use Flutter standard InputDecoration';

  @override
  String get cashAccount => 'Cash Account';

  @override
  String get standardInputHelper => 'Standard InputDecoration helper text';

  @override
  String get searchByAccount => 'Search by account code or name';

  @override
  String get projectTagDescription => 'Project tag';

  @override
  String catalogItem(String number) {
    return 'Item $number';
  }

  @override
  String warehouseDescription(String sku) {
    return '$sku - Warehouse A';
  }

  @override
  String inStock(int count) {
    return '$count in stock';
  }

  @override
  String get localRiyadh => 'Local - Riyadh';

  @override
  String get serverRemote => 'Server - remote';

  @override
  String get noSelectionEventYet => 'No selection event yet';

  @override
  String get appTitle => 'Super Auto Suggestion Box';

  @override
  String get galleryEyebrow => 'SUPER AUTO SUGGESTION BOX • GALLERY';

  @override
  String get componentDemos => 'Component Demos';

  @override
  String get suggestionItemScenarios => 'Suggestion item scenarios';

  @override
  String get suggestionItemScenariosGalleryDescription =>
      'All SuperAutoSuggestionsItem fields · enabledSnapshot';

  @override
  String get autovalidateGalleryDescription =>
      'Field value · Form default · disabled fallback';

  @override
  String get validationPositionGalleryDescription =>
      'Suffix icon · under-box text · label-trailing icon';

  @override
  String get advancedSearch => 'Advanced Search';

  @override
  String get advancedSearchGalleryDescription =>
      'Ctrl / Cmd + F · built-in dialog · custom advanced-search surface';

  @override
  String get autoSuggestionBoxGalleryDescription =>
      'Typeahead · recents · create · paged · multi-select · fuzzy';

  @override
  String get sourceDemoCapabilities =>
      'basic · controlled · multi-select · recents';

  @override
  String get lightTheme => 'Light Theme';

  @override
  String get darkTheme => 'Dark Theme';

  @override
  String get switchToArabic => 'العربية (RTL)';

  @override
  String get switchToEnglish => 'English (LTR)';
}
