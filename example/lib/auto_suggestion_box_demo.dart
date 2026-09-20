// ============================================================
// example/lib/auto_suggestion_box_demo.dart
// ------------------------------------------------------------
// Runnable gallery for SuperAutoSuggestionsBox. The examples use raw String values
// for all source data and create SuperAutoSuggestionsItem metadata only in builders.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:super_auto_suggestion_box/super_auto_suggestion_box.dart';
import 'package:super_auto_suggestion_box_example/localizations/generated/l10n.dart';

class _DemoSuggestionMeta {
  const _DemoSuggestionMeta({
    required this.label,
    this.description,
    this.trailing,
    this.group,
    this.icon,
  });

  final String label;
  final String? description;
  final String? trailing;
  final String? group;
  final IconData? icon;
}

class AutoSuggestionBoxDemo extends StatefulWidget {
  const AutoSuggestionBoxDemo({super.key});

  @override
  State<AutoSuggestionBoxDemo> createState() => _AutoSuggestionBoxDemoState();
}

class _AutoSuggestionBoxDemoState extends State<AutoSuggestionBoxDemo> {
  static const Map<String, _DemoSuggestionMeta> _accountMeta = {
    '1010': _DemoSuggestionMeta(
      label: 'Cash on Hand',
      description: '1010 - Current Assets',
      trailing: '12,400.00',
      group: 'Assets',
      icon: Icons.payments_outlined,
    ),
    '1020': _DemoSuggestionMeta(
      label: 'Bank - Operating',
      description: '1020 - Current Assets',
      trailing: '285,120.50',
      group: 'Assets',
      icon: Icons.account_balance_outlined,
    ),
    '1200': _DemoSuggestionMeta(
      label: 'Accounts Receivable',
      description: '1200 - Current Assets',
      trailing: '94,300.00',
      group: 'Assets',
      icon: Icons.receipt_long_outlined,
    ),
    '2010': _DemoSuggestionMeta(
      label: 'Accounts Payable',
      description: '2010 - Current Liabilities',
      trailing: '47,890.00',
      group: 'Liabilities',
      icon: Icons.request_quote_outlined,
    ),
    '2100': _DemoSuggestionMeta(
      label: 'VAT Payable',
      description: '2100 - Current Liabilities',
      trailing: '8,215.75',
      group: 'Liabilities',
      icon: Icons.account_balance_wallet_outlined,
    ),
    '3000': _DemoSuggestionMeta(
      label: "Owner's Equity",
      description: '3000 - Equity',
      trailing: '500,000.00',
      group: 'Equity',
      icon: Icons.savings_outlined,
    ),
    '4000': _DemoSuggestionMeta(
      label: 'Sales Revenue',
      description: '4000 - Income',
      trailing: '612,540.00',
      group: 'Income',
      icon: Icons.trending_up_outlined,
    ),
    '5000': _DemoSuggestionMeta(
      label: 'Cost of Goods Sold',
      description: '5000 - Expenses',
      trailing: '288,900.00',
      group: 'Expenses',
      icon: Icons.inventory_2_outlined,
    ),
    '5200': _DemoSuggestionMeta(
      label: 'Salaries & Wages',
      description: '5200 - Expenses',
      trailing: '96,000.00',
      group: 'Expenses',
      icon: Icons.badge_outlined,
    ),
  };

  static const List<String> _accounts = [
    '1010',
    '1020',
    '1200',
    '2010',
    '2100',
    '3000',
    '4000',
    '5000',
    '5200',
  ];

  static SuperAutoSuggestionsItem<String> _accountSuggestion(
    BuildContext context,
    List<String> items,
    int index,
    String code,
  ) {
    final meta = _accountMeta[code];
    return SuperAutoSuggestionsItem<String>(
      value: code,
      titleText: meta?.label ?? code,
      descriptionText: meta?.description,
      trailingText: meta?.trailing,
      group: meta?.group,
      iconData: meta?.icon,
      keywords: [code],
    );
  }

  static const Map<String, _DemoSuggestionMeta> _documentReferenceMeta = {
    'INV-1001': _DemoSuggestionMeta(
      label: 'INV-1001',
      description: 'Sales invoice - Posted',
      icon: Icons.receipt_long_outlined,
    ),
    'INV-1042': _DemoSuggestionMeta(
      label: 'INV-1042',
      description: 'Sales invoice - Draft',
      icon: Icons.receipt_long_outlined,
    ),
    'PO-2040': _DemoSuggestionMeta(
      label: 'PO-2040',
      description: 'Purchase order - Approved',
      icon: Icons.shopping_cart_outlined,
    ),
    'JV-0098': _DemoSuggestionMeta(
      label: 'JV-0098',
      description: 'Journal voucher - Posted',
      icon: Icons.menu_book_outlined,
    ),
  };

  static const List<String> _documentReferences = [
    'INV-1001',
    'INV-1042',
    'PO-2040',
    'JV-0098',
  ];

  static SuperAutoSuggestionsItem<String> _documentReferenceSuggestion(
    BuildContext context,
    List<String> items,
    int index,
    String reference,
  ) {
    final meta = _documentReferenceMeta[reference];
    return SuperAutoSuggestionsItem<String>(
      value: reference,
      titleText: meta?.label ?? reference,
      descriptionText: meta?.description,
      iconData: meta?.icon,
    );
  }

  static const Map<String, String> _cityLabels = {
    'RUH': 'Riyadh',
    'JED': 'Jeddah',
    'DMM': 'Dammam',
    'MKC': 'Mecca',
    'MED': 'Medina',
    'KHB': 'Khobar',
    'TUU': 'Tabuk',
    'AHB': 'Abha',
  };

  static const List<String> _cities = [
    'RUH',
    'JED',
    'DMM',
    'MKC',
    'MED',
    'KHB',
    'TUU',
    'AHB',
  ];

  static SuperAutoSuggestionsItem<String> _citySuggestion(
    BuildContext context,
    List<String> items,
    int index,
    String code,
  ) => SuperAutoSuggestionsItem<String>(
    value: code,
    titleText: _cityLabels[code] ?? code,
    descriptionText: code,
    keywords: [code],
  );

  static const List<String> _projects = [
    'North Tower',
    'Marina Retail',
    'Airport Expansion',
  ];

  SuperAutoSuggestionsItem<String> _projectSuggestion(
    BuildContext context,
    List<String> items,
    int index,
    String project,
  ) => SuperAutoSuggestionsItem<String>(
    value: project,
    titleText: project,
    descriptionText: SuperExampleLocalization.of(context).projectTagDescription,
    iconData: Icons.sell_outlined,
  );

  static final List<String> _catalog = [
    for (var i = 1; i <= 64; i++) 'SKU-${i.toString().padLeft(4, '0')}',
  ];

  String _catalogLabel(String sku) =>
      SuperExampleLocalization.of(context).catalogItem(sku.split('-').last);

  SuperAutoSuggestionsItem<String> _catalogSuggestion(
    BuildContext context,
    List<String> items,
    int index,
    String sku,
  ) {
    final l10n = SuperExampleLocalization.of(context);
    final number = int.tryParse(sku.split('-').last) ?? index + 1;
    return SuperAutoSuggestionsItem<String>(
      value: sku,
      titleText: _catalogLabel(sku),
      descriptionText: l10n.warehouseDescription(sku),
      trailingText: l10n.inStock((number * 7) % 90 + 3),
      iconData: Icons.inventory_2_outlined,
      keywords: [sku],
    );
  }

  Future<SuperSuggestionsPage<String>> _fetchCatalogPage(
    String query,
    int page,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    const pageSize = 12;
    final q = query.trim().toLowerCase();
    final all = [
      for (final sku in _catalog)
        if (q.isEmpty ||
            _catalogLabel(sku).toLowerCase().contains(q) ||
            sku.toLowerCase().contains(q))
          sku,
    ];
    final start = page * pageSize;
    if (start >= all.length) return const SuperSuggestionsPage<String>.empty();
    final end = (start + pageSize).clamp(0, all.length);
    return SuperSuggestionsPage<String>(
      items: all.sublist(start, end),
      hasMore: end < all.length,
    );
  }

  static const List<String> _localVendors = [
    'Al-Faisal Trading',
    'Najd Logistics',
    'Gulf Steel Co.',
  ];

  static const List<String> _remoteVendors = [
    'Arabian Cement Partners',
    'Desert Rose Supplies',
    'Eastern Hardware LLC',
    'Falcon Freight Services',
    'Granite & Marble Hub',
    'Horizon Electricals',
    'Ibn Sina Pharma Dist.',
    'Jeddah Port Clearing',
    'Kingdom Office Supplies',
    'Levant Timber Imports',
    'Madinah Glassworks',
    'Northern Pipes & Fittings',
  ];

  static final List<String> _directory = [..._remoteVendors, ..._localVendors];

  SuperAutoSuggestionsItem<String> _vendorSuggestion(
    BuildContext context,
    List<String> items,
    int index,
    String vendor,
  ) {
    final l10n = SuperExampleLocalization.of(context);
    final local = _localVendors.contains(vendor);
    return SuperAutoSuggestionsItem<String>(
      value: vendor,
      titleText: vendor,
      descriptionText: local ? l10n.localRiyadh : l10n.serverRemote,
      iconData: local ? Icons.storefront_outlined : Icons.cloud_outlined,
    );
  }

  SuperAutoSuggestionsItem<String> _directorySuggestion(
    BuildContext context,
    List<String> items,
    int index,
    String vendor,
  ) => SuperAutoSuggestionsItem<String>(
    value: vendor,
    titleText: vendor,
    descriptionText: SuperExampleLocalization.of(context).directoryEntry,
    iconData: Icons.business_outlined,
  );

  Future<List<String>> _fetchRemote(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 650));
    final q = query.trim().toLowerCase();
    return [
      for (final name in _remoteVendors)
        if (name.toLowerCase().contains(q)) name,
    ];
  }

  bool _boundReadOnly = false;

  final GlobalKey<FormState> _erpFormKey = GlobalKey<FormState>();
  late final SuperAutoSuggestionsController<String> _erpController =
      SuperAutoSuggestionsController<String>();
  String? _savedDocumentReference;
  String _lastInputEvent = '';

  late final SuperAutoSuggestionsController<String> _lockedController =
      SuperAutoSuggestionsController<String>(initialValue: _accounts.first);

  late final SuperAutoSuggestionsController<String> _recentsController =
      SuperAutoSuggestionsController<String>();

  late final SuperAutoSuggestionsController<String> _boundController =
      SuperAutoSuggestionsController<String>(initialValue: '4000');

  final FocusNode _fixableFocusNode = FocusNode();
  final GlobalKey<FormFieldState<String>> _fixableFormFieldKey =
      GlobalKey<FormFieldState<String>>();
  late final SuperAutoSuggestionsController<String> _fixableController =
      SuperAutoSuggestionsController<String>(
        initialValue: '1020',
        focusNode: _fixableFocusNode,
        formFieldKey: _fixableFormFieldKey,
      );

  @override
  void dispose() {
    _lockedController.dispose();
    _recentsController.dispose();
    _boundController.dispose();
    _erpController.dispose();
    _fixableController.dispose();
    _fixableFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = SuperExampleLocalization.of(context);
    final theme = SuperMaterialThemeData.of(context);
    final t = theme.superTheme;
    final typography = context.superTextTheme;
    final spacing = t.spacing;
    final lastInputEvent = _lastInputEvent.isEmpty
        ? l10n.noSelectionEventYet
        : _lastInputEvent;

    return Scaffold(
      appBar: SuperAppBar(
        title: Text(l10n.autoSuggestionBox),
        subtitle: Text(
          l10n.autoSuggestionBox,
          style: typography.eyebrow.copyWith(color: theme.colorScheme.primary),
        ),
      ),
      body: SingleChildScrollView(
        child: SuperScaffold(
          maxWidth: 1120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'v1.6.0',
                style: typography.eyebrow.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: spacing.space2),
              Text(
                l10n.accountLookup,
                style: typography.h1.copyWith(color: t.fg1),
              ),
              SizedBox(height: spacing.space8),
              SuperSectionCard2(
                collapsible: false,
                title: l10n.postToAccount,
                subtitle: l10n.searchChartAccounts,
                marker: theme.tokens.markerColor(SuperMarker.identity),
                child: SuperAutoSuggestionsBox<String>(
                  source: SuperAutoSuggestionSources.list<String>(_accounts),
                  suggestionBuilder: _accountSuggestion,
                  hintText: l10n.accountsReceivableExample,
                  onSelectionChanged: (items) {},
                ),
              ),
              SizedBox(height: spacing.section),
              SuperSectionCard2(
                collapsible: false,
                title: l10n.tagCostCenters,
                subtitle: l10n.assignCostCenters,
                marker: theme.tokens.markerColor(SuperMarker.ledger),
                child: SuperAutoSuggestionsBox<String>(
                  source: SuperAutoSuggestionSources.list<String>(_accounts),
                  suggestionBuilder: _accountSuggestion,
                  multiSelect: true,
                  hintText: l10n.selectAccounts,
                ),
              ),
              SizedBox(height: spacing.section),
              SuperSectionCard2(
                collapsible: false,
                title: l10n.quickFilter,
                subtitle: l10n.fuzzyMatchHint,
                marker: theme.tokens.markerColor(SuperMarker.notes),
                child: SuperAutoSuggestionsBox<String>(
                  source: SuperAutoSuggestionSources.fuzzy<String>(_cities),
                  suggestionBuilder: _citySuggestion,
                  highlightMatch: AutoSuggestionMatch.fuzzy,
                  hintText: l10n.rdhExample,
                ),
              ),
              SizedBox(height: spacing.section),
              SuperSectionCard2(
                collapsible: false,
                title: l10n.selectVendor,
                subtitle: l10n.vendorRemoteDescription,
                marker: theme.tokens.markerColor(SuperMarker.identity),
                child: SuperAutoSuggestionsBox<String>(
                  source: SuperAutoSuggestionSources.remoteFallback<String>(
                    initialItems: _localVendors,
                    fetch: _fetchRemote,
                    remoteThreshold: 3,
                    remoteMinChars: 1,
                  ),
                  suggestionBuilder: _vendorSuggestion,
                  hintText: l10n.vendorExample,
                  onSelectionChanged: (items) {},
                ),
              ),
              SizedBox(height: spacing.section),
              SuperSectionCard2(
                collapsible: false,
                title: l10n.vendorDirectory,
                subtitle: l10n.advancedSearchShortcutDescription,
                marker: theme.tokens.markerColor(SuperMarker.ledger),
                child: SuperAutoSuggestionsBox<String>(
                  source: SuperAutoSuggestionSources.list<String>(_directory),
                  suggestionBuilder: _directorySuggestion,
                  mode: SuperAutoSuggestionsMode.both,
                  hintText: l10n.searchDirectory,
                  onSelectionChanged: (items) {},
                ),
              ),
              SizedBox(height: spacing.section),
              SuperSectionCard2(
                collapsible: false,
                title: l10n.postToAccount,
                subtitle: l10n.requiredCustomValidator,
                marker: theme.tokens.markerColor(SuperMarker.identity),
                child: SuperAutoSuggestionsBox<String>(
                  source: SuperAutoSuggestionSources.list<String>(_accounts),
                  suggestionBuilder: _accountSuggestion,
                  decoration: InputDecoration(
                    labelText: l10n.debitAccount,
                    helperText: l10n.pickAccountTypes,
                  ),
                  required: true,
                  validator: (value) {
                    if (value == null) return null;
                    return _accounts.contains(value)
                        ? null
                        : l10n.pickAccountFromList;
                  },
                  hintText: l10n.accountsReceivableExample,
                  onSelectionChanged: (items) {},
                ),
              ),
              SizedBox(height: spacing.section),
              SuperSectionCard2(
                collapsible: false,
                title: l10n.lockedAccount,
                subtitle: l10n.disabledFieldDescription,
                marker: theme.tokens.markerColor(SuperMarker.notes),
                child: SuperAutoSuggestionsBox<String>(
                  controller: _lockedController,
                  source: SuperAutoSuggestionSources.list<String>(_accounts),
                  suggestionBuilder: _accountSuggestion,
                  decoration: InputDecoration(
                    labelText: l10n.reconciliationAccount,
                  ),
                  disabled: true,
                ),
              ),
              SizedBox(height: spacing.section),
              SuperSectionCard2(
                collapsible: false,
                title: l10n.themedField,
                subtitle: l10n.themedFieldDescription,
                marker: theme.tokens.markerColor(SuperMarker.ledger),
                child: SuperAutoSuggestionsBox<String>(
                  source: SuperAutoSuggestionSources.list<String>(_accounts),
                  suggestionBuilder: _accountSuggestion,
                  decoration: InputDecoration(
                    labelText: l10n.ledgerAccount,
                  ),
                  hintText: l10n.customFocusedStyleHint,
                  theme: SuperAutoSuggestionsBoxThemeData.of(context).copyWith(
                    focusedStyle: SuperAutoSuggestionsBoxFocusedStyle(
                      fillColor: const Color(0x141DB88A),
                      border: BorderSide(color: t.tokens.success, width: 1.6),
                      fontStyle: const TextStyle(fontWeight: FontWeight.w600),
                      cursorColor: t.tokens.success,
                    ),
                  ),
                  onSelectionChanged: (items) {},
                ),
              ),
              SizedBox(height: spacing.section),
              SuperSectionCard2(
                collapsible: false,
                title: l10n.recentAccounts,
                subtitle: l10n.recentAccountsDescription,
                marker: theme.tokens.markerColor(SuperMarker.identity),
                child: SuperAutoSuggestionsBox<String>(
                  controller: _recentsController,
                  source: SuperAutoSuggestionSources.list<String>(_accounts),
                  suggestionBuilder: _accountSuggestion,
                  showRecents: true,
                  maxRecents: 4,
                  decoration: InputDecoration(labelText: l10n.account),
                  hintText: l10n.searchAccounts,
                  onSelectionChanged: (items) {},
                ),
              ),
              SizedBox(height: spacing.section),
              SuperSectionCard2(
                collapsible: false,
                title: l10n.projectTag,
                subtitle: l10n.createProjectDescription,
                marker: theme.tokens.markerColor(SuperMarker.notes),
                child: SuperAutoSuggestionsBox<String>(
                  source: SuperAutoSuggestionSources.list<String>(_projects),
                  suggestionBuilder: _projectSuggestion,
                  decoration: InputDecoration(labelText: l10n.project),
                  hintText: l10n.seafrontVillasExample,
                  onCreate: (query) async {
                    await Future<void>.delayed(
                      const Duration(milliseconds: 400),
                    );
                    return query;
                  },
                  onSelectionChanged: (items) {},
                ),
              ),
              SizedBox(height: spacing.section),
              SuperSectionCard2(
                collapsible: false,
                title: l10n.itemCatalog,
                subtitle: l10n.itemCatalogDescription,
                marker: theme.tokens.markerColor(SuperMarker.ledger),
                child: SuperAutoSuggestionsBox<String>(
                  source: SuperAutoSuggestionSources.paged<String>(
                    _fetchCatalogPage,
                    resolveFrom: _catalog,
                  ),
                  suggestionBuilder: _catalogSuggestion,
                  decoration: InputDecoration(labelText: l10n.item),
                  maxVisibleRows: 7,
                  hintText: l10n.search64Items,
                  onSelectionChanged: (items) {},
                ),
              ),
              SizedBox(height: spacing.section),
              SuperSectionCard2(
                collapsible: false,
                title: l10n.boundAccount,
                subtitle: l10n.boundAccountDescription,
                marker: theme.tokens.markerColor(SuperMarker.identity),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SuperAutoSuggestionsBox<String>(
                      controller: _boundController,
                      source: SuperAutoSuggestionSources.list<String>(
                        _accounts,
                      ),
                      suggestionBuilder: _accountSuggestion,
                      decoration: InputDecoration(
                        labelText: l10n.ledgerAccount,
                      ),
                      readOnly: _boundReadOnly,
                      hintText: l10n.pickOrBindCode,
                      onSelectionChanged: (items) {},
                    ),
                    SizedBox(height: spacing.space3),
                    Wrap(
                      spacing: spacing.space2,
                      runSpacing: spacing.space2,
                      children: [
                        SuperButton(
                          label: l10n.bind1020,
                          variant: SuperButtonVariant.secondary,
                          onPressed: () =>
                              _boundController.selectByValue('1020'),
                        ),
                        SuperButton(
                          label: l10n.bind4000,
                          variant: SuperButtonVariant.secondary,
                          onPressed: () =>
                              _boundController.selectByValue('4000'),
                        ),
                        SuperButton(
                          label: _boundReadOnly ? l10n.edit : l10n.lockReadOnly,
                          variant: SuperButtonVariant.secondary,
                          onPressed: () =>
                              setState(() => _boundReadOnly = !_boundReadOnly),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: spacing.section),
              SuperSectionCard2(
                collapsible: false,
                title: l10n.erpDocumentReference,
                subtitle: l10n.erpReferenceDescription,
                marker: theme.tokens.markerColor(SuperMarker.notes),
                child: Form(
                  key: _erpFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SuperAutoSuggestionsBox<String>(
                        controller: _erpController,
                        source: SuperAutoSuggestionSources.list<String>(
                          _documentReferences,
                        ),
                        suggestionBuilder: _documentReferenceSuggestion,
                        decoration: InputDecoration(
                          labelText: l10n.documentReference,
                        ),
                        hintText: l10n.inv1042Example,
                        keyboardType: TextInputType.text,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[A-Za-z0-9-]'),
                          ),
                          LengthLimitingTextInputFormatter(16),
                        ],
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.start,
                        textInputAction: TextInputAction.done,
                        textCapitalization: TextCapitalization.characters,
                        showShadowHint: true,
                        completeShadowHintOnTab: true,
                        keyboardAppearance: Theme.of(context).brightness,
                        autocorrect: false,
                        enableSuggestions: false,
                        enableIMEPersonalizedLearning: false,
                        maxLength: 16,
                        onTap: () =>
                            setState(() => _lastInputEvent = l10n.fieldTapped),
                        onTapOutside: (_) => setState(
                          () => _lastInputEvent = l10n.pointerDownOutside,
                        ),
                        onTapUpOutside: (_) => setState(
                          () => _lastInputEvent = l10n.pointerUpOutside,
                        ),
                        required: true,
                        onSelectionChanged: (items) => setState(
                          () => _lastInputEvent = items.isEmpty
                              ? l10n.selectionCleared
                              : l10n.selectedValue(items.last),
                        ),
                      ),
                      SizedBox(height: spacing.space3),
                      Wrap(
                        spacing: spacing.space2,
                        runSpacing: spacing.space2,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          SuperButton(
                            label: l10n.validateAndSave,
                            variant: SuperButtonVariant.secondary,
                            onPressed: () {
                              final valid =
                                  _erpFormKey.currentState?.validate() ?? false;
                              if (!valid) return;
                              setState(() {
                                _savedDocumentReference =
                                    _erpController.selected;
                                _lastInputEvent = l10n.formValidated;
                              });
                            },
                          ),
                          Text(
                            _savedDocumentReference == null
                                ? lastInputEvent
                                : l10n.savedStatus(_savedDocumentReference!, lastInputEvent),
                            style: typography.label.copyWith(color: t.fg2),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: spacing.section),
              SuperSectionCard2(
                collapsible: false,
                title: l10n.fixableAccount,
                subtitle: l10n.fixableDescription,
                marker: theme.tokens.markerColor(SuperMarker.identity),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SuperAutoSuggestionsBox<String>(
                      controller: _fixableController,
                      source: SuperAutoSuggestionSources.list<String>(
                        _accounts,
                      ),
                      suggestionBuilder: _accountSuggestion,
                      decoration: InputDecoration(
                        labelText: l10n.settlementAccount,
                        helperText: l10n.lockAfterSelecting,
                      ),
                      allowFixed: true,
                      hintText: l10n.pickThenFix,
                    ),
                    SizedBox(height: spacing.space3),
                    Wrap(
                      spacing: spacing.space2,
                      runSpacing: spacing.space2,
                      children: [
                        SuperButton(
                          label: l10n.focusField,
                          variant: SuperButtonVariant.secondary,
                          onPressed: _fixableFocusNode.requestFocus,
                        ),
                        SuperButton(
                          label: l10n.validateField,
                          variant: SuperButtonVariant.secondary,
                          onPressed: () =>
                              _fixableFormFieldKey.currentState?.validate(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: spacing.section),
              SuperSectionCard2(
                collapsible: false,
                title: l10n.inputDecoration,
                subtitle: l10n.inputDecorationDescription,
                marker: theme.tokens.markerColor(SuperMarker.notes),
                child: SuperAutoSuggestionsBox<String>(
                  source: SuperAutoSuggestionSources.list<String>(_accounts),
                  suggestionBuilder: _accountSuggestion,
                  decoration: InputDecoration(
                    labelText: l10n.cashAccount,
                    helperText: l10n.standardInputHelper,
                    hintText: l10n.searchByAccount,
                    prefixIcon: const Icon(Icons.account_balance_outlined),
                  ),
                  onSelectionChanged: (items) {},
                ),
              ),
              SizedBox(height: spacing.section),
            ],
          ),
        ),
      ),
    );
  }
}
