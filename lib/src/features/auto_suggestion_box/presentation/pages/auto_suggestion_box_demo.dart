// ============================================================
// features/auto_suggestion_box/presentation/pages/auto_suggestion_box_demo.dart
// ------------------------------------------------------------
// A self-contained gallery page for the AutoSuggestionsBox. Demonstrates:
//   1.  single-select, grouped, highlighted, with a trailing balance column
//   2.  multi-select
//   3.  fuzzy match (ranked) over a small list
//   4.  progressive REMOTE FALLBACK — local rows show instantly, and when the
//       local match count is small a simulated network call streams more in
//       behind a "loading more" indicator
//   5.  ADVANCED SEARCH (Ctrl/⌘+F) — a modal search surface over a large dataset
//   6.  required + validator   7. disabled   8. per-field theme + focusedStyle
//   9.  RECENTS — recently-picked rows pin to a "Recent" section when empty
//   10. INLINE CREATE — "＋ Create …" adds missing master data (onCreate)
//   11. PAGED — infinite-scroll over a 64-row catalog, 12 rows per page
//   12. RECORD BINDING (selectByValue) + READ-ONLY view mode
// Used by the example app and as a visual reference.
// ============================================================

import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../data/datasources/suggestion_sources.dart';
import '../../domain/entities/auto_suggestion.dart';
import '../../domain/entities/match_strategy.dart';
import '../../domain/entities/suggestions_page.dart';
import '../controllers/auto_suggestions_box_controller.dart';
import '../widgets/auto_suggestions_box.dart';
import '../widgets/auto_suggestions_box_theme.dart';

class AutoSuggestionBoxDemo extends StatefulWidget {
  const AutoSuggestionBoxDemo({super.key});

  @override
  State<AutoSuggestionBoxDemo> createState() => _AutoSuggestionBoxDemoState();
}

class _AutoSuggestionBoxDemoState extends State<AutoSuggestionBoxDemo> {
  static final List<AutoSuggestion<String>> _accounts = [
    const AutoSuggestion(
      value: '1010',
      label: 'Cash on Hand',
      description: '1010 · Current Assets',
      trailing: '12,400.00',
      group: 'Assets',
      icon: Icons.payments_outlined,
    ),
    const AutoSuggestion(
      value: '1020',
      label: 'Bank — Operating',
      description: '1020 · Current Assets',
      trailing: '285,120.50',
      group: 'Assets',
      icon: Icons.account_balance_outlined,
    ),
    const AutoSuggestion(
      value: '1200',
      label: 'Accounts Receivable',
      description: '1200 · Current Assets',
      trailing: '94,300.00',
      group: 'Assets',
      icon: Icons.receipt_long_outlined,
    ),
    const AutoSuggestion(
      value: '2010',
      label: 'Accounts Payable',
      description: '2010 · Current Liabilities',
      trailing: '47,890.00',
      group: 'Liabilities',
      icon: Icons.request_quote_outlined,
    ),
    const AutoSuggestion(
      value: '2100',
      label: 'VAT Payable',
      description: '2100 · Current Liabilities',
      trailing: '8,215.75',
      group: 'Liabilities',
      icon: Icons.account_balance_wallet_outlined,
    ),
    const AutoSuggestion(
      value: '3000',
      label: "Owner's Equity",
      description: '3000 · Equity',
      trailing: '500,000.00',
      group: 'Equity',
      icon: Icons.savings_outlined,
    ),
    const AutoSuggestion(
      value: '4000',
      label: 'Sales Revenue',
      description: '4000 · Income',
      trailing: '612,540.00',
      group: 'Income',
      icon: Icons.trending_up_outlined,
    ),
    const AutoSuggestion(
      value: '5000',
      label: 'Cost of Goods Sold',
      description: '5000 · Expenses',
      trailing: '288,900.00',
      group: 'Expenses',
      icon: Icons.inventory_2_outlined,
    ),
    const AutoSuggestion(
      value: '5200',
      label: 'Salaries & Wages',
      description: '5200 · Expenses',
      trailing: '96,000.00',
      group: 'Expenses',
      icon: Icons.badge_outlined,
    ),
  ];

  // Existing project tags for the inline-create demo.
  static final List<AutoSuggestion<String>> _projects = [
    const AutoSuggestion(
      value: 'p-north',
      label: 'North Tower',
      icon: Icons.sell_outlined,
    ),
    const AutoSuggestion(
      value: 'p-marina',
      label: 'Marina Retail',
      icon: Icons.sell_outlined,
    ),
    const AutoSuggestion(
      value: 'p-airport',
      label: 'Airport Expansion',
      icon: Icons.sell_outlined,
    ),
  ];

  // A large item catalog served one page at a time (simulated server).
  static final List<AutoSuggestion<String>> _catalog = [
    for (var i = 1; i <= 64; i++)
      AutoSuggestion(
        value: 'SKU-${i.toString().padLeft(4, '0')}',
        label: 'Item ${i.toString().padLeft(4, '0')}',
        description: 'SKU-${i.toString().padLeft(4, '0')} · Warehouse A',
        trailing: '${(i * 7) % 90 + 3} in stock',
        icon: Icons.inventory_2_outlined,
      ),
  ];

  Future<SuggestionsPage<String>> _fetchCatalogPage(
    String query,
    int page,
  ) async {
    await Future<void>.delayed(
      const Duration(milliseconds: 500),
    ); // simulate latency
    const pageSize = 12;
    final q = query.trim().toLowerCase();
    final all = [
      for (final s in _catalog)
        if (q.isEmpty ||
            s.label.toLowerCase().contains(q) ||
            s.value.toLowerCase().contains(q))
          s,
    ];
    final start = page * pageSize;
    if (start >= all.length) return const SuggestionsPage<String>.empty();
    final end = (start + pageSize).clamp(0, all.length);
    return SuggestionsPage<String>(
      items: all.sublist(start, end),
      hasMore: end < all.length,
    );
  }

  // A handful of "local" vendors held in memory; the long tail lives "on the
  // server" and is fetched only when the local matches run thin.
  static final List<AutoSuggestion<String>> _localVendors = [
    const AutoSuggestion(
      value: 'V-001',
      label: 'Al-Faisal Trading',
      description: 'Local · Riyadh',
      icon: Icons.storefront_outlined,
    ),
    const AutoSuggestion(
      value: 'V-002',
      label: 'Najd Logistics',
      description: 'Local · Riyadh',
      icon: Icons.local_shipping_outlined,
    ),
    const AutoSuggestion(
      value: 'V-003',
      label: 'Gulf Steel Co.',
      description: 'Local · Dammam',
      icon: Icons.factory_outlined,
    ),
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

  // A larger directory for the advanced-search example.
  static final List<AutoSuggestion<String>> _directory = [
    for (var i = 0; i < _remoteVendors.length; i++)
      AutoSuggestion(
        value: 'D-${i + 1}',
        label: _remoteVendors[i],
        description: 'Directory entry',
        icon: Icons.business_outlined,
      ),
    ..._localVendors,
  ];

  Future<List<AutoSuggestion<String>>> _fetchRemote(String query) async {
    await Future<void>.delayed(
      const Duration(milliseconds: 650),
    ); // simulate latency
    final q = query.trim().toLowerCase();
    return [
      for (final name in _remoteVendors)
        if (name.toLowerCase().contains(q))
          AutoSuggestion(
            value: 'R-$name',
            label: name,
            description: 'Server · remote',
            icon: Icons.cloud_outlined,
          ),
    ];
  }

  // Live validity of the "Post To Account (required)" field, surfaced beneath it.
  String? _accountError;

  // Whether the "Bound Account" field is locked to its read-only view.
  bool _boundReadOnly = false;

  // A stable, pre-filled controller for the disabled-field example.
  late final AutoSuggestionsBoxController<String> _lockedController =
      AutoSuggestionsBoxController<String>(
        source: SuggestionSources.list<String>(_accounts),
        initialValue: _accounts.first,
      );

  // Recents-enabled controller: picks pin to a “Recent” section on the empty field.
  late final AutoSuggestionsBoxController<String> _recentsController =
      AutoSuggestionsBoxController<String>(
        source: SuggestionSources.list<String>(_accounts),
        showRecents: true,
        maxRecents: 4,
      );

  // A bound field for the read-only / selectByValue example.
  late final AutoSuggestionsBoxController<String> _boundController =
      AutoSuggestionsBoxController<String>(
        source: SuggestionSources.list<String>(_accounts),
        initialValue: _accounts.firstWhere((a) => a.value == '4000'),
      );

  @override
  void dispose() {
    _lockedController.dispose();
    _recentsController.dispose();
    _boundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.superTheme;
    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(SuperThemeData.of(context).tokens.space10),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: SuperThemeData.of(context).tokens.contentColumn,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'AUTO SUGGESTION BOX',
                    style: SuperText.eyebrow.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: SuperThemeData.of(context).tokens.space2),
                  Text(
                    'Account Lookup',
                    style: SuperText.h1.copyWith(color: t.fg1),
                  ),
                  SizedBox(height: SuperThemeData.of(context).tokens.space8),

                  // 1 — Single-select, grouped, with highlight.
                  SectionCard(
                    title: 'Post To Account',
                    subtitle: 'Search the chart of accounts by name or code',
                    marker: SuperMarker.identity,
                    child: AutoSuggestionsBox<String>(
                      items: _accounts,
                      hintText: 'e.g. Accounts Receivable',
                      onSelected: (s) {},
                    ),
                  ),
                  SizedBox(height: SuperThemeData.of(context).tokens.space8),

                  // 2 — Multi-select.
                  SectionCard(
                    title: 'Tag Cost Centers',
                    subtitle: 'Assign one or more cost centers to this entry',
                    marker: SuperMarker.ledger,
                    child: AutoSuggestionsBox<String>(
                      items: _accounts,
                      multiSelect: true,
                      hintText: 'Select cost centers…',
                    ),
                  ),
                  SizedBox(height: SuperThemeData.of(context).tokens.space8),

                  // 3 — Fuzzy strategy over plain strings.
                  SectionCard(
                    title: 'Quick Filter',
                    subtitle: 'Fuzzy match — type loosely',
                    marker: SuperMarker.notes,
                    child: AutoSuggestionsBox<String>(
                      source: SuggestionSources.fuzzy<String>(const [
                        AutoSuggestion(value: 'RUH', label: 'Riyadh'),
                        AutoSuggestion(value: 'JED', label: 'Jeddah'),
                        AutoSuggestion(value: 'DMM', label: 'Dammam'),
                        AutoSuggestion(value: 'MKC', label: 'Mecca'),
                        AutoSuggestion(value: 'MED', label: 'Medina'),
                        AutoSuggestion(value: 'KHB', label: 'Khobar'),
                        AutoSuggestion(value: 'TUU', label: 'Tabuk'),
                        AutoSuggestion(value: 'AHB', label: 'Abha'),
                      ]),
                      highlightMatch: AutoSuggestionMatch.fuzzy,
                      hintText: 'e.g. rdh',
                    ),
                  ),
                  SizedBox(height: SuperThemeData.of(context).tokens.space8),

                  // 4 — Progressive remote fallback.
                  SectionCard(
                    title: 'Select Vendor',
                    subtitle:
                        'Local vendors show instantly; the server is queried only when local matches are few',
                    marker: SuperMarker.identity,
                    child: AutoSuggestionsBox<String>(
                      source: SuggestionSources.remoteFallback<String>(
                        initialItems: _localVendors,
                        fetch: _fetchRemote,
                        remoteThreshold: 3, // fetch when ≤ 3 local matches
                        remoteMinChars: 1,
                      ),
                      hintText: 'e.g. cement, freight, glass…',
                      onSelected: (s) {},
                    ),
                  ),
                  SizedBox(height: SuperThemeData.of(context).tokens.space8),

                  // 5 — Advanced search (Ctrl/⌘+F).
                  SectionCard(
                    title: 'Vendor Directory',
                    subtitle:
                        'Focus the field and press Ctrl / ⌘ + F to open Advanced Search',
                    marker: SuperMarker.ledger,
                    child: AutoSuggestionsBox<String>(
                      items: _directory,
                      advancedSearch: true,
                      hintText: 'Search the directory…  (⌘F)',
                      onSelected: (s) {},
                    ),
                  ),
                  SizedBox(height: SuperThemeData.of(context).tokens.space8),

                  // 6 — Required + validator (v0.6.0). Validity surfaces through
                  // the suffix error badge; onValidity feeds a live status line.
                  SectionCard(
                    title: 'Post To Account',
                    subtitle:
                        'Required field with a custom validator — leave it empty and tab away',
                    marker: SuperMarker.identity,
                    child: AutoSuggestionsBox<String>(
                      items: _accounts,
                      label: 'Debit Account',
                      required: true,
                      hint:
                          'Pick an asset, liability, equity, income or expense account',
                      validator: (value) {
                        if (value.trim().isEmpty)
                          return null; // required handles empty
                        final match = _accounts.any((a) => a.label == value);
                        return match ? null : 'Pick an account from the list';
                      },
                      onValidity: (err) => setState(() => _accountError = err),
                      hintText: 'e.g. Accounts Receivable',
                      onSelected: (s) {},
                    ),
                  ),
                  SizedBox(height: SuperThemeData.of(context).tokens.space2),
                  Text(
                    _accountError == null
                        ? 'STATUS · VALID'
                        : 'STATUS · ${_accountError!.toUpperCase()}',
                    style: SuperText.label.copyWith(
                      color: _accountError == null
                          ? SuperThemeData.of(context).tokens.success
                          : Theme.of(context).colorScheme.error,
                    ),
                  ),
                  SizedBox(height: SuperThemeData.of(context).tokens.space8),

                  // 7 — Disabled (v0.6.0). Dimmed, non-interactive, no errors.
                  SectionCard(
                    title: 'Locked Account',
                    subtitle:
                        'A disabled field blocks typing and opening the overlay',
                    marker: SuperMarker.notes,
                    child: AutoSuggestionsBox<String>(
                      items: _accounts,
                      label: 'Reconciliation Account',
                      disabled: true,
                      controller: _lockedController,
                    ),
                  ),
                  SizedBox(height: SuperThemeData.of(context).tokens.space8),

                  // 8 — Field-level custom theme + focusedStyle (v0.6.0).
                  SectionCard(
                    title: 'Themed Field',
                    subtitle:
                        'A theme assigned directly to one box — green focused fill, border & bold text',
                    marker: SuperMarker.ledger,
                    child: AutoSuggestionsBox<String>(
                      items: _accounts,
                      label: 'Ledger Account',
                      hintText: 'Focus me to see the custom focused style',
                      theme: AutoSuggestionsBoxThemeData.of(context).copyWith(
                        focusedStyle: AutoSuggestionsBoxFocusedStyle(
                          fillColor: Color(0x141DB88A),
                          border: BorderSide(
                            color: SuperThemeData.of(context).tokens.success,
                            width: 1.6,
                          ),
                          fontStyle: TextStyle(fontWeight: FontWeight.w600),
                          cursorColor: SuperThemeData.of(
                            context,
                          ).tokens.success,
                        ),
                      ),
                      onSelected: (s) {},
                    ),
                  ),
                  SizedBox(height: SuperThemeData.of(context).tokens.space8),

                  // 9 — Recently-used (recents pin to the top on the empty field).
                  SectionCard(
                    title: 'Recent Accounts',
                    subtitle:
                        'Pick a few, clear the field (×) and reopen — your recent picks pin to the top',
                    marker: SuperMarker.identity,
                    child: AutoSuggestionsBox<String>(
                      controller: _recentsController,
                      label: 'Account',
                      hintText: 'Search accounts…',
                      onSelected: (s) {},
                    ),
                  ),
                  SizedBox(height: SuperThemeData.of(context).tokens.space8),

                  // 10 — Inline create (add missing master data without leaving).
                  SectionCard(
                    title: 'Project Tag',
                    subtitle:
                        'Type a name that does not exist and press Enter to “＋ Create” it',
                    marker: SuperMarker.notes,
                    child: AutoSuggestionsBox<String>(
                      items: _projects,
                      label: 'Project',
                      hintText: 'e.g. Seafront Villas',
                      onCreate: (q) async {
                        await Future<void>.delayed(
                          const Duration(milliseconds: 400),
                        ); // simulate a POST
                        return AutoSuggestion<String>(
                          value:
                              'p-${q.toLowerCase().replaceAll(RegExp(r"\s+"), "-")}',
                          label: q,
                          description: 'New project',
                          icon: Icons.sell_outlined,
                        );
                      },
                      onSelected: (s) {},
                    ),
                  ),
                  SizedBox(height: SuperThemeData.of(context).tokens.space8),

                  // 11 — Server-side pagination / infinite scroll over a big catalog.
                  SectionCard(
                    title: 'Item Catalog',
                    subtitle:
                        'Large master data — 12 rows per page; scroll the dropdown to load more',
                    marker: SuperMarker.ledger,
                    child: AutoSuggestionsBox<String>(
                      source: SuggestionSources.paged<String>(
                        _fetchCatalogPage,
                        resolveFrom: _catalog,
                      ),
                      label: 'Item',
                      maxVisibleRows: 7,
                      hintText: 'Search 64 items…',
                      onSelected: (s) {},
                    ),
                  ),
                  SizedBox(height: SuperThemeData.of(context).tokens.space8),

                  // 12 — Record binding (selectByValue) + read-only view mode.
                  SectionCard(
                    title: 'Bound Account',
                    subtitle:
                        'Bind by stored code, then lock to a read-only (posted) view',
                    marker: SuperMarker.identity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AutoSuggestionsBox<String>(
                          controller: _boundController,
                          label: 'Ledger Account',
                          readOnly: _boundReadOnly,
                          hintText: 'Pick or bind by code',
                          onSelected: (s) {},
                        ),
                        SizedBox(
                          height: SuperThemeData.of(context).tokens.space3,
                        ),
                        Wrap(
                          spacing: SuperThemeData.of(context).tokens.space2,
                          runSpacing: SuperThemeData.of(context).tokens.space2,
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
                              label: _boundReadOnly
                                  ? 'Edit'
                                  : 'Lock (read-only)',
                              variant: SuperButtonVariant.secondary,
                              onPressed: () => setState(
                                () => _boundReadOnly = !_boundReadOnly,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
