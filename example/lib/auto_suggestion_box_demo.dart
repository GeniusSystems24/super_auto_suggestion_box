// ============================================================
// example/lib/auto_suggestion_box_demo.dart
// ------------------------------------------------------------
// Runnable gallery for SuperAutoSuggestionsBox. The examples use raw String values
// for all source data and create SuperAutoSuggestionsItem metadata only in builders.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:super_auto_suggestion_box/super_auto_suggestion_box.dart';

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

  static String _accountLabel(String code) => _accountMeta[code]?.label ?? code;

  static SuperAutoSuggestionsItem<String> _accountSuggestion(
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

  static SuperAutoSuggestionsItem<String> _projectSuggestion(
    List<String> items,
    int index,
    String project,
  ) => SuperAutoSuggestionsItem<String>(
    value: project,
    titleText: project,
    descriptionText: 'Project tag',
    iconData: Icons.sell_outlined,
  );

  static final List<String> _catalog = [
    for (var i = 1; i <= 64; i++) 'SKU-${i.toString().padLeft(4, '0')}',
  ];

  static String _catalogLabel(String sku) => 'Item ${sku.split('-').last}';

  static SuperAutoSuggestionsItem<String> _catalogSuggestion(
    List<String> items,
    int index,
    String sku,
  ) {
    final number = int.tryParse(sku.split('-').last) ?? index + 1;
    return SuperAutoSuggestionsItem<String>(
      value: sku,
      titleText: _catalogLabel(sku),
      descriptionText: '$sku - Warehouse A',
      trailingText: '${(number * 7) % 90 + 3} in stock',
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

  static SuperAutoSuggestionsItem<String> _vendorSuggestion(
    List<String> items,
    int index,
    String vendor,
  ) {
    final local = _localVendors.contains(vendor);
    return SuperAutoSuggestionsItem<String>(
      value: vendor,
      titleText: vendor,
      descriptionText: local ? 'Local - Riyadh' : 'Server - remote',
      iconData: local ? Icons.storefront_outlined : Icons.cloud_outlined,
    );
  }

  static SuperAutoSuggestionsItem<String> _directorySuggestion(
    List<String> items,
    int index,
    String vendor,
  ) => SuperAutoSuggestionsItem<String>(
    value: vendor,
    titleText: vendor,
    descriptionText: 'Directory entry',
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
  String _lastInputEvent = 'No selection event yet';

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
    final theme = SuperMaterialThemeData.of(context);
    final t = theme.superTheme;
    final typography = context.superTextTheme;
    final spacing = t.spacing;

    return Scaffold(
      appBar: SuperAppBar(
        title: const Text('Auto Suggestion Box'),
        subtitle: Text(
          'AUTO SUGGESTION BOX',
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
                'v1.2.0',
                style: typography.eyebrow.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: spacing.space2),
              Text(
                'Account Lookup',
                style: typography.h1.copyWith(color: t.fg1),
              ),
              SizedBox(height: spacing.space8),
              SuperSectionCard2(
                collapsible: false,
                title: 'Post To Account',
                subtitle: 'Search the chart of accounts by name or code',
                marker: theme.tokens.markerColor(SuperMarker.identity),
                child: SuperAutoSuggestionsBox<String>(
                  source: SuperAutoSuggestionSources.list<String>(_accounts),
                  suggestionBuilder: _accountSuggestion,
                  hintText: 'e.g. Accounts Receivable',
                  onSelectionChanged: (items) {},
                ),
              ),
              SizedBox(height: spacing.section),
              SuperSectionCard2(
                collapsible: false,
                title: 'Tag Cost Centers',
                subtitle: 'Assign one or more cost centers to this entry',
                marker: theme.tokens.markerColor(SuperMarker.ledger),
                child: SuperAutoSuggestionsBox<String>(
                  source: SuperAutoSuggestionSources.list<String>(_accounts),
                  suggestionBuilder: _accountSuggestion,
                  multiSelect: true,
                  hintText: 'Select cost centers...',
                ),
              ),
              SizedBox(height: spacing.section),
              SuperSectionCard2(
                collapsible: false,
                title: 'Quick Filter',
                subtitle: 'Fuzzy match - type loosely',
                marker: theme.tokens.markerColor(SuperMarker.notes),
                child: SuperAutoSuggestionsBox<String>(
                  source: SuperAutoSuggestionSources.fuzzy<String>(_cities),
                  suggestionBuilder: _citySuggestion,
                  highlightMatch: AutoSuggestionMatch.fuzzy,
                  hintText: 'e.g. rdh',
                ),
              ),
              SizedBox(height: spacing.section),
              SuperSectionCard2(
                collapsible: false,
                title: 'Select Vendor',
                subtitle:
                    'Local vendors show instantly; server search runs when local matches are few',
                marker: theme.tokens.markerColor(SuperMarker.identity),
                child: SuperAutoSuggestionsBox<String>(
                  source: SuperAutoSuggestionSources.remoteFallback<String>(
                    initialItems: _localVendors,
                    fetch: _fetchRemote,
                    remoteThreshold: 3,
                    remoteMinChars: 1,
                  ),
                  suggestionBuilder: _vendorSuggestion,
                  hintText: 'e.g. cement, freight, glass...',
                  onSelectionChanged: (items) {},
                ),
              ),
              SizedBox(height: spacing.section),
              SuperSectionCard2(
                collapsible: false,
                title: 'Vendor Directory',
                subtitle:
                    'Focus the field and press Ctrl / Cmd + F to open Advanced Search',
                marker: theme.tokens.markerColor(SuperMarker.ledger),
                child: SuperAutoSuggestionsBox<String>(
                  source: SuperAutoSuggestionSources.list<String>(_directory),
                  suggestionBuilder: _directorySuggestion,
                  advancedSearch: true,
                  hintText: 'Search the directory... (Cmd/Ctrl+F)',
                  onSelectionChanged: (items) {},
                ),
              ),
              SizedBox(height: spacing.section),
              SuperSectionCard2(
                collapsible: false,
                title: 'Post To Account',
                subtitle:
                    'Required field with a custom validator - leave it empty and tab away',
                marker: theme.tokens.markerColor(SuperMarker.identity),
                child: SuperAutoSuggestionsBox<String>(
                  source: SuperAutoSuggestionSources.list<String>(_accounts),
                  suggestionBuilder: _accountSuggestion,
                  decoration: const InputDecoration(
                    labelText: 'Debit Account',
                    helperText:
                        'Pick an asset, liability, equity, income or expense account',
                  ),
                  required: true,
                  validator: (value) {
                    if (value == null) return null;
                    return _accounts.contains(value)
                        ? null
                        : 'Pick an account from the list';
                  },
                  hintText: 'e.g. Accounts Receivable',
                  onSelectionChanged: (items) {},
                ),
              ),
              SizedBox(height: spacing.section),
              SuperSectionCard2(
                collapsible: false,
                title: 'Locked Account',
                subtitle:
                    'A disabled field blocks typing and opening the overlay',
                marker: theme.tokens.markerColor(SuperMarker.notes),
                child: SuperAutoSuggestionsBox<String>(
                  controller: _lockedController,
                  source: SuperAutoSuggestionSources.list<String>(_accounts),
                  suggestionBuilder: _accountSuggestion,
                  decoration: const InputDecoration(
                    labelText: 'Reconciliation Account',
                  ),
                  disabled: true,
                ),
              ),
              SizedBox(height: spacing.section),
              SuperSectionCard2(
                collapsible: false,
                title: 'Themed Field',
                subtitle:
                    'A theme assigned directly to one box - green focused fill, border and bold text',
                marker: theme.tokens.markerColor(SuperMarker.ledger),
                child: SuperAutoSuggestionsBox<String>(
                  source: SuperAutoSuggestionSources.list<String>(_accounts),
                  suggestionBuilder: _accountSuggestion,
                  decoration: const InputDecoration(
                    labelText: 'Ledger Account',
                  ),
                  hintText: 'Focus me to see the custom focused style',
                  theme: AutoSuggestionsBoxThemeData.of(context).copyWith(
                    focusedStyle: AutoSuggestionsBoxFocusedStyle(
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
                title: 'Recent Accounts',
                subtitle:
                    'Pick a few, clear the field and reopen - recent picks pin to the top',
                marker: theme.tokens.markerColor(SuperMarker.identity),
                child: SuperAutoSuggestionsBox<String>(
                  controller: _recentsController,
                  source: SuperAutoSuggestionSources.list<String>(_accounts),
                  suggestionBuilder: _accountSuggestion,
                  showRecents: true,
                  maxRecents: 4,
                  decoration: const InputDecoration(labelText: 'Account'),
                  hintText: 'Search accounts...',
                  onSelectionChanged: (items) {},
                ),
              ),
              SizedBox(height: spacing.section),
              SuperSectionCard2(
                collapsible: false,
                title: 'Project Tag',
                subtitle: 'Type a missing name and press Enter to create it',
                marker: theme.tokens.markerColor(SuperMarker.notes),
                child: SuperAutoSuggestionsBox<String>(
                  source: SuperAutoSuggestionSources.list<String>(_projects),
                  suggestionBuilder: _projectSuggestion,
                  decoration: const InputDecoration(labelText: 'Project'),
                  hintText: 'e.g. Seafront Villas',
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
                title: 'Item Catalog',
                subtitle:
                    'Large master data - 12 rows per page; scroll the dropdown to load more',
                marker: theme.tokens.markerColor(SuperMarker.ledger),
                child: SuperAutoSuggestionsBox<String>(
                  source: SuperAutoSuggestionSources.paged<String>(
                    _fetchCatalogPage,
                    resolveFrom: _catalog,
                  ),
                  suggestionBuilder: _catalogSuggestion,
                  decoration: const InputDecoration(labelText: 'Item'),
                  maxVisibleRows: 7,
                  hintText: 'Search 64 items...',
                  onSelectionChanged: (items) {},
                ),
              ),
              SizedBox(height: spacing.section),
              SuperSectionCard2(
                collapsible: false,
                title: 'Bound Account',
                subtitle:
                    'Bind by stored code, then lock to a read-only posted view',
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
                      decoration: const InputDecoration(
                        labelText: 'Ledger Account',
                      ),
                      readOnly: _boundReadOnly,
                      hintText: 'Pick or bind by code',
                      onSelectionChanged: (items) {},
                    ),
                    SizedBox(height: spacing.space3),
                    Wrap(
                      spacing: spacing.space2,
                      runSpacing: spacing.space2,
                      children: [
                        SuperButton(
                          label: 'Bind 1020',
                          variant: SuperButtonVariant.secondary,
                          onPressed: () =>
                              _boundController.selectByValue('1020'),
                        ),
                        SuperButton(
                          label: 'Bind 4000',
                          variant: SuperButtonVariant.secondary,
                          onPressed: () =>
                              _boundController.selectByValue('4000'),
                        ),
                        SuperButton(
                          label: _boundReadOnly ? 'Edit' : 'Lock (read-only)',
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
                title: 'ERP Document Reference',
                subtitle:
                    'Type a prefix, press Tab to accept completion, then Tab again to move focus',
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
                        decoration: const InputDecoration(
                          labelText: 'Document Reference',
                        ),
                        hintText: 'e.g. INV-1042',
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
                            setState(() => _lastInputEvent = 'Field tapped'),
                        onTapOutside: (_) => setState(
                          () => _lastInputEvent = 'Pointer down outside',
                        ),
                        onTapUpOutside: (_) => setState(
                          () => _lastInputEvent = 'Pointer up outside',
                        ),
                        required: true,
                        onSelectionChanged: (items) => setState(
                          () => _lastInputEvent = items.isEmpty
                              ? 'Selection cleared'
                              : 'Selected: ${items.last}',
                        ),
                      ),
                      SizedBox(height: spacing.space3),
                      Wrap(
                        spacing: spacing.space2,
                        runSpacing: spacing.space2,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          SuperButton(
                            label: 'Validate & Save',
                            variant: SuperButtonVariant.secondary,
                            onPressed: () {
                              final valid =
                                  _erpFormKey.currentState?.validate() ?? false;
                              if (!valid) return;
                              setState(() {
                                _savedDocumentReference =
                                    _erpController.selected;
                                _lastInputEvent = 'Form validated';
                              });
                            },
                          ),
                          Text(
                            _savedDocumentReference == null
                                ? _lastInputEvent
                                : 'Saved: $_savedDocumentReference - $_lastInputEvent',
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
                title: 'Fixable Account',
                subtitle:
                    'Use the small label action to protect or unlock the current value',
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
                      decoration: const InputDecoration(
                        labelText: 'Settlement Account',
                        helperText: 'Lock the field after selecting an account',
                      ),
                      allowFixed: true,
                      hintText: 'Pick an account, then fix it',
                    ),
                    SizedBox(height: spacing.space3),
                    Wrap(
                      spacing: spacing.space2,
                      runSpacing: spacing.space2,
                      children: [
                        SuperButton(
                          label: 'Focus field',
                          variant: SuperButtonVariant.secondary,
                          onPressed: _fixableFocusNode.requestFocus,
                        ),
                        SuperButton(
                          label: 'Validate field',
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
                title: 'Input Decoration',
                subtitle:
                    'Label, helper, and placeholder copy use Flutter standard InputDecoration',
                marker: theme.tokens.markerColor(SuperMarker.notes),
                child: SuperAutoSuggestionsBox<String>(
                  source: SuperAutoSuggestionSources.list<String>(_accounts),
                  suggestionBuilder: _accountSuggestion,
                  decoration: const InputDecoration(
                    labelText: 'Cash Account',
                    helperText: 'Standard InputDecoration helper text',
                    hintText: 'Search by account code or name',
                    prefixIcon: Icon(Icons.account_balance_outlined),
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
