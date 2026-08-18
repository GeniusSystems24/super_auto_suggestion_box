// ============================================================
// features/auto_suggestion_box/presentation/controllers/super_auto_suggestions_controller.dart
// ------------------------------------------------------------
// The MVC controller: the single source of truth for one box. Its public API is
// raw `T` values. The widget attaches the view metadata builder needed for
// rendering, filtering, selection labels, and value resolution.
// ============================================================

import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../domain/entities/super_auto_suggestions_item.dart';
import '../../domain/repositories/super_auto_suggestions_source.dart';

class SuperAutoSuggestionsController<T> extends ChangeNotifier {
  SuperAutoSuggestionsController({
    TextEditingController? textController,
    T? initialValue,
    this.allowFreeText = true,
    List<T>? initialSelected,
    bool isFixed = false,
    this.focusNode,
    this.isHiden = false,
    this.formFieldKey,
  }) : _initialValue = initialValue,
       _ownsText = textController == null,
       isFixed = ValueNotifier<bool>(isFixed),
       text = textController ?? TextEditingController() {
    if (initialSelected != null) _selectedItems.addAll(initialSelected);
    text.addListener(_onTextChanged);
    this.isFixed.addListener(_onFixedChanged);
    _lastText = text.text;
  }

  late SuperAutoSuggestionsSource<T> _source;
  final T? _initialValue;
  bool _viewBound = false;
  final bool _ownsText;

  void _bindViewAdapter(
    SuperAutoSuggestionsSource<T> source,
    AutoSuggestionBuilder<T> builder, {
    required Duration debounce,
    required int minChars,
    required int maxResults,
    required bool multiSelect,
    required bool showRecents,
    required int maxRecents,
    required List<T>? initialRecents,
    required String recentsGroupLabel,
    required ValueChanged<List<T>>? onRecentsChanged,
  }) {
    _source = source;
    _debounce = debounce;
    _minChars = minChars;
    _maxResults = maxResults;
    _multiSelect = multiSelect;
    _showRecents = showRecents;
    _maxRecents = maxRecents;
    _recentsGroupLabel = recentsGroupLabel;
    _onRecentsChanged = onRecentsChanged;
    bindSuperAutoSuggestionsSourceView(_source, builder);
    if (!_viewBound) {
      _viewBound = true;
      if (initialRecents != null) {
        _recents.addAll(initialRecents.take(_maxRecents));
      }
      final initialValue = _initialValue;
      if (initialValue != null) {
        final resolved = _source.resolve(initialValue) ?? initialValue;
        _selected = resolved;
        _committed = resolved;
        _committedText = _source.suggestionFor(resolved).displayText;
        _setTextInternal(_committedText!);
      }
    }
    final committed = _committed;
    if (committed != null) {
      final resolved = _source.resolve(committed) ?? committed;
      _selected = resolved;
      _committed = resolved;
      _committedText = _source.suggestionFor(resolved).displayText;
      _setTextInternal(_committedText!);
    }
    _run(_queryString(), immediate: true);
  }

  /// The field's text controller (shared with the `TextField` in the view).
  final TextEditingController text;

  /// Guards user and controller-driven mutations when set to `true`.
  final ValueNotifier<bool> isFixed;

  /// Optional focus node associated with this field.
  FocusNode? focusNode;

  /// Optional key for the inner [FormField], exposing its [FormFieldState].
  GlobalKey<FormFieldState<T>>? formFieldKey;

  /// Optional flag the UI can use to hide/show the field.
  ///
  /// The misspelling is retained for compatibility with the existing API.
  bool isHiden;

  /// Debounce window before an async query fires (sync sources ignore it).
  Duration _debounce = const Duration(milliseconds: 180);

  /// Do not query until at least this many characters are typed (0 = always).
  int _minChars = 0;

  /// Hard cap on how many rows the overlay shows.
  int _maxResults = 50;

  /// Whether committing arbitrary typed text (not a suggestion) is allowed.
  bool allowFreeText;

  /// When true the box keeps a set of chosen raw items.
  bool _multiSelect = false;

  /// Surface a Recent section while the query is empty.
  bool _showRecents = false;

  /// How many recents to retain (most-recent-first). 0 disables tracking.
  int _maxRecents = 5;

  /// The group header shown above the recents section. The view binds a
  /// localized default when the widget keeps its default label.
  String _recentsGroupLabel = 'Recent';

  /// Fired whenever the raw recents list changes.
  ValueChanged<List<T>>? _onRecentsChanged;

  // -- state ---------------------------------------------------------------
  List<T> _results = const [];
  List<SuperAutoSuggestionsItem<T>> _suggestions = const [];
  int _highlighted = -1;
  bool _open = false;
  bool _loading = false;
  bool _loadingMore = false;
  Object? _error;
  T? _selected;
  T? _committed;
  String? _committedText;
  String _activeQuery = '';

  int _seq = 0;
  Timer? _debounceTimer;
  String _lastText = '';
  bool _muteText = false;
  bool _disposed = false;
  final List<T> _selectedItems = [];
  final List<T> _recents = [];

  // -- pagination ---------------------------------------------------------
  String _pagedQuery = '';
  int _page = 0;
  bool _hasMore = false;
  bool _isLoadingPage = false;
  List<T> _pagedItems = const [];

  // -- reads --------------------------------------------------------------
  String get query => text.text;

  /// The effective query used for matching/highlighting: the field text from
  /// the first character up to the caret.
  String get effectiveQuery => _activeQuery;

  /// Raw result items currently shown by the overlay.
  List<T> get results => List.unmodifiable(_results);

  /// Built suggestion rows for the current [results].
  List<SuperAutoSuggestionsItem<T>> get suggestions =>
      List.unmodifiable(_suggestions);

  bool get hasResults => _results.isNotEmpty;
  int get highlightedIndex => _highlighted;

  /// The highlighted raw item, if any.
  T? get highlighted => (_highlighted >= 0 && _highlighted < _results.length)
      ? _results[_highlighted]
      : null;

  /// The highlighted render/search metadata, if any.
  SuperAutoSuggestionsItem<T>? get highlightedSuggestion =>
      (_highlighted >= 0 && _highlighted < _suggestions.length)
      ? _suggestions[_highlighted]
      : null;

  bool get isOpen => _open;
  bool get isLoading => _loading;

  /// True while a progressive source's remote `loadMore` is in flight.
  bool get isLoadingMore => _loadingMore;
  Object? get error => _error;

  /// Recently committed raw items (most-recent-first), when [_showRecents] is on.
  List<T> get recents => List.unmodifiable(_recents);

  /// Built suggestion rows for [recents].
  List<SuperAutoSuggestionsItem<T>> get recentSuggestions =>
      List.unmodifiable(_buildSuggestions(_recents));

  /// Whether the backing source paginates (infinite scroll).
  bool get isPaged => _source.isPaged;

  /// Whether at least one more page can be loaded for the current query.
  bool get hasMore => _hasMore;

  /// True while the next page is being fetched.
  bool get isLoadingPage => _isLoadingPage;

  /// The last committed raw selection (null after free-text commit or clear).
  T? get selected => _selected;

  /// The built suggestion row for [selected], if any.
  SuperAutoSuggestionsItem<T>? get selectedSuggestion =>
      _selected == null ? null : suggestionFor(_selected as T);

  /// The last committed raw selection restored on blur.
  T? get committed => _committed;

  /// The built suggestion row for [committed], if any.
  SuperAutoSuggestionsItem<T>? get committedSuggestion =>
      _committed == null ? null : suggestionFor(_committed as T);

  /// The committed payload value. With the raw API this is the selected value.
  T? get value => selectedSuggestion?.value;

  /// The chosen raw rows (multi-select), in pick order.
  List<T> get selectedItems => List.unmodifiable(_selectedItems);

  /// Compatibility alias for [selectedItems].
  List<T> get selectedValues => selectedItems;

  bool isHighlighted(int i) => i == _highlighted;

  /// Build the suggestion metadata for the current result at [index].
  SuperAutoSuggestionsItem<T> suggestionAt(int index) => _suggestions[index];

  /// Build suggestion metadata for a raw [item].
  SuperAutoSuggestionsItem<T> suggestionFor(T item) {
    final resultIndex = _indexOfRaw(_results, item);
    if (resultIndex >= 0 && resultIndex < _suggestions.length) {
      return _suggestions[resultIndex];
    }
    return _source.suggestionFor(item);
  }

  String _queryString() {
    final full = text.text;
    final sel = text.selection;
    final caret = sel.isValid && sel.extentOffset >= 0
        ? sel.extentOffset.clamp(0, full.length)
        : full.length;
    return full.substring(0, caret);
  }

  int _indexOfRaw(List<T> items, T item) {
    for (var i = 0; i < items.length; i++) {
      if (identical(items[i], item) || items[i] == item) return i;
    }
    return -1;
  }

  List<SuperAutoSuggestionsItem<T>> _buildSuggestions(List<T> items) =>
      _source.suggestionsFor(items);

  T _valueFor(T item) => suggestionFor(item).value;

  int _indexBySuggestionValue(List<T> items, T value) {
    for (var i = 0; i < items.length; i++) {
      if (_source.suggestionAt(items, i).value == value) {
        return i;
      }
    }
    return -1;
  }

  bool isSelectedValue(T value) =>
      _indexBySuggestionValue(_selectedItems, value) >= 0;

  /// Toggle [item] in the multi-select set. Returns true if now selected.
  bool toggleSelected(T item) {
    if (isFixed.value) return isSelectedValue(_valueFor(item));
    final value = _valueFor(item);
    final i = _indexBySuggestionValue(_selectedItems, value);
    final nowSelected = i < 0;
    if (nowSelected) {
      _selectedItems.add(item);
      _pushRecent(item);
    } else {
      _selectedItems.removeAt(i);
    }
    _notify();
    return nowSelected;
  }

  /// Remove a value from the multi-select set.
  void removeSelectedValue(T value) {
    if (isFixed.value) return;
    final i = _indexBySuggestionValue(_selectedItems, value);
    if (i < 0) return;
    _selectedItems.removeAt(i);
    _notify();
  }

  /// Replace the whole multi-select set.
  void setSelectedItems(List<T> items) {
    if (isFixed.value) return;
    _selectedItems
      ..clear()
      ..addAll(items);
    _notify();
  }

  /// Clear the multi-select set.
  void clearSelection() {
    if (isFixed.value) return;
    if (_selectedItems.isEmpty) return;
    _selectedItems.clear();
    _notify();
  }

  // -- recents ------------------------------------------------------------
  void _pushRecent(T item) {
    if (!_showRecents || _maxRecents <= 0) return;
    final value = _valueFor(item);
    final i = _indexBySuggestionValue(_recents, value);
    if (i >= 0) _recents.removeAt(i);
    _recents.insert(0, item);
    while (_recents.length > _maxRecents) {
      _recents.removeLast();
    }
    _onRecentsChanged?.call(recents);
  }

  /// Replace the recents list.
  void setRecents(List<T> items) {
    _recents
      ..clear()
      ..addAll(items.take(_maxRecents));
    _onRecentsChanged?.call(recents);
    if (_activeQuery.trim().isEmpty) refresh();
  }

  /// Clear the recents list.
  void clearRecents() {
    if (_recents.isEmpty) return;
    _recents.clear();
    _onRecentsChanged?.call(recents);
    if (_activeQuery.trim().isEmpty) refresh();
  }

  // -- record binding -----------------------------------------------------
  /// Resolve a stored [value] back to its raw item via the source and commit it.
  T? selectByValue(T value, {bool addToRecents = false}) {
    if (isFixed.value) return null;
    T? found = _source.resolve(value);
    found ??= _firstByValue(_results, value) ?? _firstByValue(_recents, value);
    if (found == null) return null;
    if (_multiSelect) {
      if (!isSelectedValue(value)) {
        _selectedItems.add(found);
        _notify();
      }
    } else {
      select(found);
    }
    if (addToRecents) _pushRecent(found);
    return found;
  }

  T? _firstByValue(List<T> list, T value) {
    final i = _indexBySuggestionValue(list, value);
    return i < 0 ? null : list[i];
  }

  void _setResults(List<T> list) {
    final resultItems = <T>[];
    final resultSuggestions = <SuperAutoSuggestionsItem<T>>[];

    if (_showRecents && _recents.isNotEmpty && _activeQuery.trim().isEmpty) {
      final recentSuggestions = _buildSuggestions(_recents);
      final recentValues = <T>{};
      for (var i = 0; i < _recents.length; i++) {
        final suggestion = recentSuggestions[i];
        recentValues.add(suggestion.value);
        resultItems.add(_recents[i]);
        resultSuggestions.add(suggestion.copyWith(group: _recentsGroupLabel));
      }

      final baseSuggestions = _buildSuggestions(list);
      for (var i = 0; i < list.length; i++) {
        final suggestion = baseSuggestions[i];
        if (recentValues.contains(suggestion.value)) continue;
        resultItems.add(list[i]);
        resultSuggestions.add(
          suggestion.copyWith(group: suggestion.group ?? 'All'),
        );
      }
    } else {
      resultItems.addAll(list);
      resultSuggestions.addAll(_buildSuggestions(list));
    }

    if (!_source.isPaged && resultItems.length > _maxResults) {
      _results = resultItems.sublist(0, _maxResults);
      _suggestions = resultSuggestions.sublist(0, _maxResults);
    } else {
      _results = resultItems;
      _suggestions = resultSuggestions;
    }
  }

  // -- opening / closing --------------------------------------------------
  void open() {
    if (_open) return;
    _open = true;
    _run(_queryString(), immediate: true);
    _notify();
  }

  void close() {
    if (!_open) return;
    _open = false;
    _highlighted = -1;
    _debounceTimer?.cancel();
    _notify();
  }

  void toggle() => _open ? close() : open();

  // -- typing -------------------------------------------------------------
  void _onTextChanged() {
    if (_muteText) return;
    final query = _queryString();
    final textChanged = text.text != _lastText;
    if (!textChanged && query == _activeQuery) return;
    _lastText = text.text;
    if (textChanged) {
      final selected = _selected;
      if (selected != null &&
          suggestionFor(selected).displayText != text.text) {
        _selected = null;
      }
    }
    if (!_open) _open = true;
    _run(query);
  }

  /// Programmatically set the field text without triggering a query churn loop.
  void setText(String value, {bool moveCursorToEnd = true}) {
    if (isFixed.value) return;
    _setTextInternal(value, moveCursorToEnd: moveCursorToEnd);
  }

  void _setTextInternal(String value, {bool moveCursorToEnd = true}) {
    _muteText = true;
    text.value = TextEditingValue(
      text: value,
      selection: moveCursorToEnd
          ? TextSelection.collapsed(offset: value.length)
          : text.selection,
    );
    _lastText = value;
    _muteText = false;
  }

  void _run(String raw, {bool immediate = false}) {
    _debounceTimer?.cancel();
    _activeQuery = raw;
    final q = raw.trim();
    if (q.length < _minChars) {
      _setResults(const []);
      _highlighted = _results.isEmpty ? -1 : 0;
      _loading = false;
      _loadingMore = false;
      _notify();
      return;
    }
    final mySeq = ++_seq;

    void deliver(List<T> list) {
      if (_disposed || mySeq != _seq) return;
      _setResults(list);
      _highlighted = _results.isEmpty ? -1 : 0;
      _loading = false;
      _error = null;
      _notify();
    }

    if (_source.isPaged) {
      _startPaged(raw, mySeq, immediate: immediate);
      return;
    }

    final prog = _source.progressive(raw);
    if (prog != null) {
      deliver(prog.items);
      if (prog.loadMore != null) {
        _loadingMore = true;
        _notify();
        final loadMore = prog.loadMore!;
        void fire() {
          loadMore()
              .then((list) {
                if (_disposed || mySeq != _seq) return;
                _setResults(list);
                if (_highlighted >= _results.length) {
                  _highlighted = _results.isEmpty ? -1 : 0;
                }
                _loadingMore = false;
                _error = null;
                _notify();
              })
              .catchError((Object _) {
                if (_disposed || mySeq != _seq) return;
                _loadingMore = false;
                _notify();
              });
        }

        if (immediate || _debounce == Duration.zero) {
          fire();
        } else {
          _debounceTimer = Timer(_debounce, fire);
        }
      } else {
        _loadingMore = false;
      }
      return;
    }

    final result = _source.query(raw);
    if (result is Future<List<T>>) {
      _loading = true;
      _loadingMore = false;
      _notify();
      void fire() {
        result.then(deliver).catchError((Object e) {
          if (_disposed || mySeq != _seq) return;
          _error = e;
          _loading = false;
          _setResults(const []);
          _highlighted = -1;
          _notify();
        });
      }

      if (immediate || _debounce == Duration.zero) {
        fire();
      } else {
        _debounceTimer = Timer(_debounce, fire);
      }
    } else {
      _loadingMore = false;
      deliver(result);
    }
  }

  void _startPaged(String raw, int mySeq, {bool immediate = false}) {
    _pagedQuery = raw;
    _page = 0;
    _hasMore = false;
    _pagedItems = const [];
    _isLoadingPage = false;
    _loading = true;
    _loadingMore = false;
    _notify();
    void fire() {
      _source
          .fetchPage(raw, 0)
          .then((page) {
            if (_disposed || mySeq != _seq) return;
            _pagedItems = List<T>.of(page.items);
            _hasMore = page.hasMore;
            _loading = false;
            _error = null;
            _setResults(_pagedItems);
            _highlighted = _results.isEmpty ? -1 : 0;
            _notify();
          })
          .catchError((Object e) {
            if (_disposed || mySeq != _seq) return;
            _error = e;
            _loading = false;
            _hasMore = false;
            _pagedItems = const [];
            _setResults(const []);
            _highlighted = -1;
            _notify();
          });
    }

    if (immediate || _debounce == Duration.zero) {
      fire();
    } else {
      _debounceTimer = Timer(_debounce, fire);
    }
  }

  /// Fetch and append the next page from a paged source.
  void loadNextPage() {
    if (!_source.isPaged || !_hasMore || _isLoadingPage || _loading) return;
    final next = _page + 1;
    final mySeq = _seq;
    _isLoadingPage = true;
    _notify();
    _source
        .fetchPage(_pagedQuery, next)
        .then((page) {
          if (_disposed || mySeq != _seq) return;
          _page = next;
          final seen = <T>{
            for (var i = 0; i < _pagedItems.length; i++)
              _source.suggestionAt(_pagedItems, i).value,
          };
          for (var i = 0; i < page.items.length; i++) {
            final item = page.items[i];
            final value = _source.suggestionAt(page.items, i).value;
            if (seen.add(value)) _pagedItems.add(item);
          }
          _hasMore = page.hasMore;
          _isLoadingPage = false;
          _setResults(_pagedItems);
          _notify();
        })
        .catchError((Object _) {
          if (_disposed || mySeq != _seq) return;
          _isLoadingPage = false;
          _hasMore = false;
          _notify();
        });
  }

  /// Force a re-query of the current text.
  void refresh() => _run(_queryString(), immediate: true);

  // -- keyboard navigation ------------------------------------------------
  void moveHighlight(int delta) {
    if (!_open) {
      open();
      return;
    }
    if (_results.isEmpty) return;
    var i = _highlighted;
    final n = _results.length;
    for (var step = 0; step < n; step++) {
      i = (i + delta) % n;
      if (i < 0) i += n;
      if (_suggestions[i].enabled) break;
    }
    _highlighted = i;
    _notify();
  }

  void highlightAt(int i) {
    if (i == _highlighted) return;
    _highlighted = (i >= 0 && i < _results.length) ? i : -1;
    _notify();
  }

  // -- committing ---------------------------------------------------------
  /// Commit [item]: writes its label into the field and closes the overlay.
  T select(T item) {
    if (isFixed.value) return item;
    final suggestion = suggestionFor(item);
    _selected = item;
    _committed = item;
    _committedText = suggestion.displayText;
    setText(suggestion.displayText);
    _open = false;
    _highlighted = -1;
    _pushRecent(item);
    _notify();
    return item;
  }

  /// Commit whatever is highlighted.
  T? commitHighlighted() {
    final h = highlighted;
    final s = highlightedSuggestion;
    if (h != null && s != null && s.enabled) return select(h);
    return null;
  }

  /// Accept the current free text as the committed baseline.
  void acceptFreeText() {
    if (isFixed.value) return;
    _selected = null;
    _committed = null;
    _committedText = text.text;
  }

  /// Revert the field to the last committed value.
  void restoreCommitted() {
    if (isFixed.value) return;
    if (_committedText == null) return;
    _selected = _committed;
    if (text.text != _committedText) setText(_committedText!);
    _highlighted = -1;
    _loadingMore = false;
    _notify();
  }

  /// Clear the field, selection and results.
  void clear() {
    if (isFixed.value) return;
    setText('');
    _selected = null;
    _committed = null;
    _committedText = '';
    _setResults(const []);
    _highlighted = -1;
    _error = null;
    _notify();
    _run('', immediate: true);
  }

  @override
  void dispose() {
    _disposed = true;
    _seq++;
    _debounceTimer?.cancel();
    text.removeListener(_onTextChanged);
    isFixed.removeListener(_onFixedChanged);
    isFixed.dispose();
    if (_ownsText) text.dispose();
    super.dispose();
  }

  void _onFixedChanged() {
    if (isFixed.value) close();
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }
}

/// Binds the widget-owned metadata builder to a controller.
///
/// This is hidden from the package barrel and is used by `SuperAutoSuggestionsBox`
/// so `SuperAutoSuggestionsController` does not expose `suggestionBuilder` in its
/// public constructor or class API.
void bindSuperAutoSuggestionsControllerView<T>(
  SuperAutoSuggestionsController<T> controller,
  SuperAutoSuggestionsSource<T> source,
  AutoSuggestionBuilder<T> builder, {
  required Duration debounce,
  required int minChars,
  required int maxResults,
  required bool multiSelect,
  required bool showRecents,
  required int maxRecents,
  required List<T>? initialRecents,
  required String recentsGroupLabel,
  required ValueChanged<List<T>>? onRecentsChanged,
}) {
  controller._bindViewAdapter(
    source,
    builder,
    debounce: debounce,
    minChars: minChars,
    maxResults: maxResults,
    multiSelect: multiSelect,
    showRecents: showRecents,
    maxRecents: maxRecents,
    initialRecents: initialRecents,
    recentsGroupLabel: recentsGroupLabel,
    onRecentsChanged: onRecentsChanged,
  );
}

/// Deprecated name for [SuperAutoSuggestionsController].
@Deprecated('Use SuperAutoSuggestionsController instead.')
typedef AutoSuggestionsBoxController<T> = SuperAutoSuggestionsController<T>;
