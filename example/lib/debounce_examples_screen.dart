import 'package:flutter/material.dart';
import 'package:super_auto_suggestion_box/super_auto_suggestion_box.dart';

/// Demonstrates that local matching is immediate while only remote fetch work
/// is debounced. It also compares different [SuperAutoSuggestionsBox.minResult]
/// thresholds.
class DebounceExamplesScreen extends StatefulWidget {
  const DebounceExamplesScreen({super.key});

  @override
  State<DebounceExamplesScreen> createState() => _DebounceExamplesScreenState();
}

class _DebounceExamplesScreenState extends State<DebounceExamplesScreen> {
  static const _allItems = <String>[
    'ACC-1000 · Cash',
    'ACC-1010 · Cash Clearing',
    'ACC-1020 · Bank',
    'ACC-1100 · Accounts Receivable',
    'ACC-1200 · Inventory',
    'ACC-1300 · Prepaid Expenses',
    'ACC-2000 · Accounts Payable',
    'ACC-4000 · Sales Revenue',
    'ACC-5000 · Cost of Sales',
  ];

  static const _localItems = <String>[
    'ACC-1000 · Cash',
    'ACC-1010 · Cash Clearing',
    'ACC-1020 · Bank',
    'ACC-1100 · Accounts Receivable',
  ];

  late final SuperAutoSuggestionsSource<String> _noDebounceSource;
  late final SuperAutoSuggestionsSource<String> _normalDebounceSource;
  late final SuperAutoSuggestionsSource<String> _slowDebounceSource;

  late final SuperAutoSuggestionsSource<String> _minResult0Source;
  late final SuperAutoSuggestionsSource<String> _minResult2Source;
  late final SuperAutoSuggestionsSource<String> _minResult5Source;

  int _noDebounceFetches = 0;
  int _normalDebounceFetches = 0;
  int _slowDebounceFetches = 0;

  int _minResult0Fetches = 0;
  int _minResult2Fetches = 0;
  int _minResult5Fetches = 0;

  @override
  void initState() {
    super.initState();
    _noDebounceSource = _buildAsyncSource(() => _noDebounceFetches++);
    _normalDebounceSource = _buildAsyncSource(() => _normalDebounceFetches++);
    _slowDebounceSource = _buildAsyncSource(() => _slowDebounceFetches++);

    _minResult0Source = _buildHybridSource(() => _minResult0Fetches++);
    _minResult2Source = _buildHybridSource(() => _minResult2Fetches++);
    _minResult5Source = _buildHybridSource(() => _minResult5Fetches++);
  }

  SuperAutoSuggestionsSource<String> _buildAsyncSource(VoidCallback onFetch) {
    return SuperAutoSuggestionSources.async<String>(
      (context, query) async {
        if (mounted) setState(onFetch);

        final locale = Localizations.localeOf(context).languageCode;
        debugPrint('async fetch(locale: $locale, query: $query)');

        await Future<void>.delayed(const Duration(milliseconds: 250));
        return _matches(_allItems, query);
      },
      // These rows are matched immediately, before the remote debounce starts.
      initialItems: _localItems,
      match: AutoSuggestionMatch.contains,
    );
  }

  SuperAutoSuggestionsSource<String> _buildHybridSource(VoidCallback onFetch) {
    return SuperAutoSuggestionSources.hybrid<String>(
      initialItems: _localItems,
      fetch: (context, query) async {
        if (mounted) setState(onFetch);

        final locale = Localizations.localeOf(context).languageCode;
        debugPrint('hybrid fetch(locale: $locale, query: $query)');

        await Future<void>.delayed(const Duration(milliseconds: 250));
        return _matches(_allItems, query);
      },
      remoteMinChars: 1,
    );
  }

  static List<String> _matches(List<String> source, String query) {
    final normalized = query.trim().toLowerCase();
    return [
      for (final item in source)
        if (normalized.isEmpty || item.toLowerCase().contains(normalized)) item,
    ];
  }

  SuperAutoSuggestionsItem<String> _suggestionBuilder(
    BuildContext context,
    List<String> items,
    int index,
    String item,
  ) {
    return SuperAutoSuggestionsItem<String>(
      value: item,
      titleText: item,
      icon: Icon(
        Icons.account_balance_outlined,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isArabic
              ? 'أمثلة Debounce و minResult'
              : 'Debounce & minResult examples',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                isArabic
                    ? 'المطابقة المحلية لا تمر عبر debounce. جرّب cash لرؤية النتائج المحلية فوراً، ثم جرّب sales أو inventory لرؤية نتيجة المصدر الخارجي بعد مدة debounce.'
                    : 'Local matching is never debounced. Try cash to see local results immediately, then try sales or inventory to see remote results after the debounce window.',
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isArabic
                ? 'مقارنة مدة Debounce للطلبات الخارجية'
                : 'Remote-fetch debounce comparison',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            isArabic
                ? 'جميع الحقول أدناه تطابق البيانات المحلية فوراً. الاختلاف الوحيد هو متى يبدأ fetch الخارجي.'
                : 'Every field below matches its local cache immediately. The only difference is when the remote fetch actually starts.',
          ),
          const SizedBox(height: 16),
          _DebounceCase(
            title: isArabic ? 'بدون تأخير · 0ms' : 'No debounce · 0ms',
            description: isArabic
                ? 'النتائج المحلية فورية، والطلب الخارجي يبدأ مباشرة عند الحاجة.'
                : 'Local results are immediate; required remote work starts immediately.',
            debounce: Duration.zero,
            source: _noDebounceSource,
            fetchCount: _noDebounceFetches,
            suggestionBuilder: _suggestionBuilder,
          ),
          const SizedBox(height: 16),
          _DebounceCase(
            title: isArabic ? 'متوازن · 300ms' : 'Balanced · 300ms',
            description: isArabic
                ? 'المطابقة المحلية فورية، بينما fetch الخارجي ينتظر 300ms.'
                : 'Local matching is immediate while remote fetch waits 300ms.',
            debounce: const Duration(milliseconds: 300),
            source: _normalDebounceSource,
            fetchCount: _normalDebounceFetches,
            suggestionBuilder: _suggestionBuilder,
          ),
          const SizedBox(height: 16),
          _DebounceCase(
            title: isArabic ? 'محافظ · 800ms' : 'Conservative · 800ms',
            description: isArabic
                ? 'حتى مع 800ms تظهر النتائج المحلية فوراً؛ التأخير يخص fetch فقط.'
                : 'Even with 800ms, local matches appear immediately; only fetch is delayed.',
            debounce: const Duration(milliseconds: 800),
            source: _slowDebounceSource,
            fetchCount: _slowDebounceFetches,
            suggestionBuilder: _suggestionBuilder,
          ),
          const SizedBox(height: 36),
          Text(
            isArabic ? 'أمثلة minResult' : 'minResult examples',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            isArabic
                ? 'اكتب cash. توجد نتيجتان محليتان وتظهران فوراً في الحالات الثلاث. minResult = 0 لن ينفذ fetch، بينما 2 و5 سينفذانه بعد debounce.'
                : 'Type cash. Two local matches appear immediately in all three cases. minResult = 0 will not fetch, while 2 and 5 will start remote fetch after debounce.',
          ),
          const SizedBox(height: 16),
          _MinResultCase(
            minResult: 0,
            source: _minResult0Source,
            fetchCount: _minResult0Fetches,
            suggestionBuilder: _suggestionBuilder,
            description: isArabic
                ? 'القيمة الافتراضية: fetch فقط عندما لا توجد نتائج محلية.'
                : 'Default: fetch only when there are no local matches.',
          ),
          const SizedBox(height: 16),
          _MinResultCase(
            minResult: 2,
            source: _minResult2Source,
            fetchCount: _minResult2Fetches,
            suggestionBuilder: _suggestionBuilder,
            description: isArabic
                ? 'النتائج المحلية تظهر فوراً، ثم fetch عند وجود نتيجتين أو أقل.'
                : 'Local matches appear immediately, then fetch runs for two or fewer matches.',
          ),
          const SizedBox(height: 16),
          _MinResultCase(
            minResult: 5,
            source: _minResult5Source,
            fetchCount: _minResult5Fetches,
            suggestionBuilder: _suggestionBuilder,
            description: isArabic
                ? 'النتائج المحلية تظهر فوراً، ثم fetch عند وجود خمس نتائج أو أقل.'
                : 'Local matches appear immediately, then fetch runs for five or fewer matches.',
          ),
        ],
      ),
    );
  }
}

class _DebounceCase extends StatelessWidget {
  const _DebounceCase({
    required this.title,
    required this.description,
    required this.debounce,
    required this.source,
    required this.fetchCount,
    required this.suggestionBuilder,
  });

  final String title;
  final String description;
  final Duration debounce;
  final SuperAutoSuggestionsSource<String> source;
  final int fetchCount;
  final SuperAutoSuggestionBuilder<String> suggestionBuilder;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(description),
            const SizedBox(height: 8),
            Text('fetch count: $fetchCount'),
            const SizedBox(height: 12),
            SuperAutoSuggestionsBox<String>(
              source: source,
              suggestionBuilder: suggestionBuilder,
              debounce: debounce,
              minResult: 0,
              mode: SuperAutoSuggestionsMode.textBox,
              decoration: const InputDecoration(
                labelText: 'Local + remote account search',
                hintText: 'Try cash, then sales...',
              ),
              onSelectionChanged: (_) {},
            ),
          ],
        ),
      ),
    );
  }
}

class _MinResultCase extends StatelessWidget {
  const _MinResultCase({
    required this.minResult,
    required this.source,
    required this.fetchCount,
    required this.suggestionBuilder,
    required this.description,
  });

  final int minResult;
  final SuperAutoSuggestionsSource<String> source;
  final int fetchCount;
  final SuperAutoSuggestionBuilder<String> suggestionBuilder;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'minResult: $minResult',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(description),
            const SizedBox(height: 8),
            Text('fetch count: $fetchCount'),
            const SizedBox(height: 12),
            SuperAutoSuggestionsBox<String>(
              source: source,
              suggestionBuilder: suggestionBuilder,
              debounce: const Duration(milliseconds: 300),
              minResult: minResult,
              mode: SuperAutoSuggestionsMode.textBox,
              decoration: const InputDecoration(
                labelText: 'Hybrid account search',
                hintText: 'Try: cash, bank, account, sales',
              ),
              onSelectionChanged: (_) {},
            ),
          ],
        ),
      ),
    );
  }
}
