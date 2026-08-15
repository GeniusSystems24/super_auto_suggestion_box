// ============================================================
// features/auto_suggestion_box/presentation/widgets/super_auto_suggestions_box.dart
// ------------------------------------------------------------
// The VIEW. A text field with an anchored suggestions overlay. Type to filter,
// up/down to move through matches, Tab to complete, Enter / tap to pick, and
// Esc to dismiss; when
// free-text is allowed an unmatched value commits as-is on Enter. The matched
// substring of each row is highlighted (see AutoSuggestionsHighlight).
//
// Rendering is a thin view over the controller: every gesture and key is
// forwarded there and the widget rebuilds from its state. The overlay is an
// OverlayPortal linked to the field via CompositedTransform*, so it tracks
// scroll/resize and auto-flips above when there isn't room below.
// ============================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';

import '../../../../core/core.dart';
import '../../domain/entities/super_auto_suggestions_item.dart';
import '../../domain/entities/match_strategy.dart';
import '../../domain/repositories/super_auto_suggestions_source.dart';
import '../controllers/super_auto_suggestions_controller.dart';
import 'auto_suggestions_box_theme.dart';
import 'auto_suggestions_highlight.dart';

/// A synchronous validator for the box: returns an error message, or null when
/// valid. Receives the field's current committed / typed text.
typedef AutoSuggestionsValidator = String? Function(String value);

/// Reports the field's current error (null == valid) to a host on every change.
typedef AutoSuggestionsValidityChanged = void Function(String? error);

/// A view-only text controller that paints the remaining characters of the
/// active suggestion after the real editable value. The shadow text is never
/// inserted into [value], so selection, validation, saving, and filtering keep
/// operating on exactly what the user typed.
class _ShadowHintTextEditingController extends TextEditingController {
  _ShadowHintTextEditingController.fromValue(TextEditingValue super.value)
    : super.fromValue();

  String _shadowSuffix = '';
  TextStyle? _shadowStyle;

  void updateShadowHint({required String suffix, TextStyle? style}) {
    _shadowSuffix = suffix;
    _shadowStyle = style;
  }

  /// RenderEditable measures the complete painted span, including the visual
  /// suffix. Clamp pointer-derived selections to the real editable value so a
  /// tap on the shadow text can never create an out-of-range selection.
  @override
  set value(TextEditingValue newValue) {
    final maxOffset = newValue.text.length;
    final selection = newValue.selection;
    final composing = newValue.composing;

    final clampedSelection = selection.isValid
        ? TextSelection(
            baseOffset: selection.baseOffset.clamp(0, maxOffset).toInt(),
            extentOffset: selection.extentOffset.clamp(0, maxOffset).toInt(),
            affinity: selection.affinity,
            isDirectional: selection.isDirectional,
          )
        : selection;
    final clampedComposing = composing.isValid
        ? TextRange(
            start: composing.start.clamp(0, maxOffset).toInt(),
            end: composing.end.clamp(0, maxOffset).toInt(),
          )
        : composing;

    super.value = newValue.copyWith(
      selection: clampedSelection,
      composing: clampedComposing,
    );
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final editableSpan = super.buildTextSpan(
      context: context,
      style: style,
      withComposing: withComposing,
    );
    if (_shadowSuffix.isEmpty) return editableSpan;

    return TextSpan(
      style: style,
      children: <InlineSpan>[
        editableSpan,
        TextSpan(text: _shadowSuffix, style: _shadowStyle),
      ],
    );
  }
}

class SuperAutoSuggestionsBox<T> extends StatefulWidget {
  /// Required source of raw suggestion data.
  final SuperAutoSuggestionsSource<T> source;

  /// Builds suggestion metadata for raw values.
  final AutoSuggestionBuilder<T> suggestionBuilder;

  /// An externally-owned controller. When null, one is created and disposed
  /// with the widget. Suggestion data remains configured through [source].
  final SuperAutoSuggestionsController<T>? controller;

  /// Fired when a row is picked (tap or Enter on a highlighted match).
  final ValueChanged<T>? onSelected;

  /// Enable multi-select: tapping / Enter toggles a row in a set and the overlay
  /// stays open (rows show a checkbox; a count shows in the field). Read the set
  /// from the controller's `selectedItems`, or listen via [onSelectionChanged].
  final bool multiSelect;

  /// Delay before asynchronous source queries are fired.
  final Duration debounce;

  /// Minimum query length required before suggestions are requested.
  final int minChars;

  /// Maximum number of non-paged suggestions displayed.
  final int maxResults;

  /// Whether recent selections are shown for an empty query.
  final bool showRecents;

  /// Maximum number of recent selections retained.
  final int maxRecents;

  /// Initial recent raw values.
  final List<T>? initialRecents;

  /// Group title applied to recent suggestions.
  final String recentsGroupLabel;

  /// Called whenever the recent raw values change.
  final ValueChanged<List<T>>? onRecentsChanged;

  /// Fired (multi-select) whenever the chosen set changes, with the full set.
  final ValueChanged<List<T>>? onSelectionChanged;

  /// Fired on every text change.
  final ValueChanged<String>? onChanged;

  /// Fired when Enter is pressed with no highlighted match and free text is
  /// allowed (a "submit raw query" affordance).
  final ValueChanged<String>? onSubmitted;

  /// Placeholder shown when empty.
  final String? hintText;

  /// Shows the untyped remainder of the currently highlighted prefix match as
  /// faint inline text while the user is typing.
  ///
  /// For example, typing `INV-1` while `INV-1042` is highlighted renders
  /// `042` as a non-editable shadow hint. The shadow is only visual: it is not
  /// included in [onChanged], validation, [onSave], or the controller value.
  /// Pressing Enter keeps the existing behavior and commits the highlighted row.
  final bool showShadowHint;

  /// Completes the real field value from the visible shadow hint when the user
  /// presses Tab. Enabled by default for fast keyboard-first ERP data entry.
  ///
  /// Shift+Tab is never intercepted. When no shadow hint is visible, Tab keeps
  /// its normal focus-traversal behavior (or calls [onTabNext], when provided).
  final bool completeShadowHintOnTab;

  /// Optional style for the shadow suffix. It is merged over the effective
  /// field text style. By default the package uses the theme's tertiary
  /// foreground color while preserving the field's font metrics.
  final TextStyle? shadowHintStyle;

  /// Additional Material input configuration.
  ///
  /// Use [InputDecoration.labelText] for the label above the field and
  /// [InputDecoration.helperText] for supporting text below it, and
  /// [InputDecoration.prefixIcon] for the leading widget. Component borders,
  /// fill, sizing, and suffix widgets remain theme-controlled.
  final InputDecoration? decoration;

  /// Field label rendered above the box (optional).
  @Deprecated('Use decoration: InputDecoration(labelText: ...) instead.')
  final String? label;

  /// Shows a compact lock/unlock action at the trailing edge of the label row.
  /// The action toggles [SuperAutoSuggestionsController.isFixed].
  final bool allowFixed;

  /// Leading widget inside the field (defaults to a search icon).
  @Deprecated('Use decoration: InputDecoration(prefixIcon: ...) instead.')
  final Widget? leading;

  /// Show the clear (×) button when there's text.
  final bool clearButton;

  /// How matches are highlighted in each row.
  final AutoSuggestionMatch highlightMatch;

  /// Highlight the matched substring in bold/accent.
  final bool highlightMatches;

  /// Open the overlay when the field gains focus.
  final bool openOnFocus;

  /// Max rows visible before the overlay scrolls.
  final int maxVisibleRows;

  /// Fixed field width (otherwise fills the parent).
  final double? width;

  final bool enabled;

  /// Disable all interaction: dims the field to 55%, blocks typing / opening the
  /// overlay, and suppresses validation errors. Consistent with
  /// `super_form_field`'s `disabled`. Takes precedence over [enabled].
  final bool disabled;

  /// Read-only **view mode**: shows the committed value in normal (non-dimmed)
  /// styling but blocks typing, the overlay, and the clear / chevron affordances
  /// — the ERP "review / posted" state for a bound field. Unlike [disabled] it
  /// keeps full contrast (not greyed). [disabled] takes precedence over it.
  final bool readOnly;

  /// Marks the field mandatory: appends a red `*` to the [label] and adds an
  /// implicit “this field is required” validator (fails while empty).
  final bool required;

  /// A custom validator run against the field text. Its message (or the
  /// [required] message) surfaces through the suffix error badge — never inline,
  /// matching the `super_form_field` rule.
  final AutoSuggestionsValidator? validator;

  /// Message used by the [required] validator.
  final String requiredMessage;

  /// Fired whenever the field's validity changes, with the current error (or
  /// null when valid).
  final AutoSuggestionsValidityChanged? onValidity;

  /// Show the error before the field has been touched (e.g. on a submit sweep).
  final bool forceError;

  /// Helper text shown beneath the control. Hidden whenever an error shows.
  @Deprecated('Use decoration: InputDecoration(helperText: ...) instead.')
  final String? hint;

  /// Vertical density — comfortable (42px) or compact (36px), matching
  /// `super_form_field`.
  final FieldDensity density;

  /// A theme assigned directly to this field, overriding the ambient
  /// [AutoSuggestionsBoxThemeData] from the enclosing `Theme`. Use it to restyle
  /// one box (fill, border, focused style…) without touching app-wide theming.
  final AutoSuggestionsBoxThemeData? theme;

  final bool autofocus;
  final FocusNode? focusNode;

  /// The keyboard configuration used by the editable text field.
  ///
  /// ERP examples include [TextInputType.number] for account codes and
  /// [TextInputType.text] for mixed document references such as `INV-1042`.
  final TextInputType? keyboardType;

  /// Formatters applied to user-entered query text before suggestions are
  /// filtered. Useful for enforcing numeric codes, uppercase identifiers, and
  /// maximum lengths. Programmatic controller updates are not reformatted.
  final List<TextInputFormatter>? inputFormatters;

  /// Explicit direction for the editable value, independent of the surrounding
  /// interface direction. This is useful when an RTL ERP displays LTR account,
  /// SKU, IBAN, or document codes.
  final TextDirection? textDirection;

  /// Alignment of the editable query within the field.
  final TextAlign textAlign;

  /// Vertical alignment of the editable query within the fixed-height field.
  final TextAlignVertical? textAlignVertical;

  /// The action button shown by software keyboards.
  final TextInputAction? textInputAction;

  /// Capitalization behavior for newly entered text.
  final TextCapitalization textCapitalization;

  /// Called whenever the platform submits the field, including software-keyboard
  /// actions. Unlike the legacy [onSubmitted], this callback is invoked after
  /// any submit attempt, whether it selects a highlighted row, creates a row,
  /// or accepts free text.
  final ValueChanged<String>? onFieldSubmitted;

  /// Called when the editable field is tapped. The suggestions overlay still
  /// opens automatically when the field is interactive.
  final GestureTapCallback? onTap;

  /// Called for pointer-down events outside the underlying text field.
  /// Overlay dismissal remains managed by the suggestion box so row taps are
  /// not cancelled prematurely.
  final TapRegionCallback? onTapOutside;

  /// Called for pointer-up events outside the underlying text field.
  final TapRegionUpCallback? onTapUpOutside;

  /// Called when editing completes. When null, Flutter applies its default
  /// focus behavior for the selected [textInputAction].
  final VoidCallback? onEditingComplete;

  /// Called by `FormState.save()` with the current query/committed label.
  ///
  /// The public name intentionally follows the package convention while it is
  /// forwarded to `TextFormField.onSaved`.
  final FormFieldSetter<String>? onSave;

  /// Keyboard brightness override, primarily for iOS.
  final Brightness? keyboardAppearance;

  /// Whether taps are reported even when the field already owns focus.
  final bool onTapAlwaysCalled;

  /// Controls automatic capitalization-independent spelling correction.
  final bool autocorrect;

  /// Whether the platform may show predictive suggestions. Disable for exact
  /// ERP identifiers such as account codes, SKUs, and voucher numbers.
  final bool enableSuggestions;

  /// Whether the IME may learn personalized input from this field.
  final bool enableIMEPersonalizedLearning;

  /// Smart punctuation behavior for dashes.
  final SmartDashesType? smartDashesType;

  /// Smart punctuation behavior for quotes.
  final SmartQuotesType? smartQuotesType;

  /// Autofill hints forwarded to the platform.
  final Iterable<String>? autofillHints;

  /// Maximum number of user-entered characters. The visual counter is hidden to
  /// preserve the design-system field height; enforcement still applies.
  final int? maxLength;

  /// How [maxLength] is enforced.
  final MaxLengthEnforcement? maxLengthEnforcement;

  /// Whether to display the text cursor.
  final bool? showCursor;

  /// Width of the text cursor.
  final double cursorWidth;

  /// Optional cursor height override.
  final double? cursorHeight;

  /// Optional cursor corner radius.
  final Radius? cursorRadius;

  /// Enables selection handles, copy, and paste.
  final bool enableInteractiveSelection;

  /// Platform-specific selection controls override.
  final TextSelectionControls? selectionControls;

  /// Padding used when Flutter scrolls the field above the software keyboard.
  final EdgeInsets scrollPadding;

  /// Scroll physics for the editable text viewport.
  final ScrollPhysics? scrollPhysics;

  /// Mouse cursor used over the editable field on desktop and web.
  final MouseCursor? mouseCursor;

  /// Whether this field may request focus.
  final bool canRequestFocus;

  /// Embed mode: drop the outer border + fill and tighten padding so the box
  /// sits flush inside a host surface (e.g. an EditableTable cell). The overlay
  /// dropdown is unchanged.
  final bool bare;

  /// Override the field's min height (defaults to [AutoSuggestionsBoxThemeData.fieldHeight]).
  final double? fieldHeight;

  /// Base text style for the typed value (size/family). Falls back to the DS body.
  final TextStyle? textStyle;

  /// Pressing Escape calls this (used by embedders like a table cell to cancel
  /// the edit). When null, Escape just closes the overlay.
  final VoidCallback? onEscape;

  /// Pressing Tab / Shift+Tab calls these to move to the next/previous cell.
  /// Forward Tab first accepts a visible shadow hint when
  /// [completeShadowHintOnTab] is enabled; the callback runs on the next Tab.
  /// When null, Tab performs normal focus traversal.
  final VoidCallback? onTabNext;
  final VoidCallback? onTabPrev;

  /// When the field gains focus, scroll it into view inside the nearest
  /// scrollable ancestor (so a box low in a long form / list isn't left under
  /// the fold or the keyboard, and the overlay has room to open). Uses
  /// `Scrollable.ensureVisible`. Set false to opt out.
  final bool scrollOnFocus;

  /// When the field loses focus without a fresh pick, restore the last
  /// committed value (revert any unconfirmed typing). No-op if nothing was ever
  /// committed. Disable to keep free-typed text on blur.
  final bool restoreOnBlur;

  /// Enable the **Advanced Search View**: pressing Ctrl/⌘+F while the field is
  /// focused opens a larger modal search surface over the same results.
  final bool advancedSearch;

  /// Custom builder for the advanced-search surface (defaults to a built-in
  /// dialog). Receives the live controller; commit via `controller.select(...)`.
  final Widget Function(BuildContext, SuperAutoSuggestionsController<T>)?
  advancedSearchBuilder;

  /// Custom row renderer (overrides the default label/description/icon row).
  final Widget Function(
    BuildContext,
    T item,
    SuperAutoSuggestionsItem<T> suggestion,
    bool highlighted,
  )?
  itemBuilder;

  /// Shown inside the overlay when a non-empty query has no matches.
  final Widget Function(BuildContext, String query)? emptyBuilder;

  /// Shown inside the overlay while an async source is loading and there are no
  /// results yet (e.g. a skeleton). When null, a default spinner row is used.
  /// (A small spinner also always appears in the field's suffix while loading.)
  final Widget Function(BuildContext, String query)? loadingBuilder;

  /// Inline **create**: when set and the typed query matches no existing row, a
  /// “＋ Create …” action appears at the foot of the overlay (and Enter triggers
  /// it instead of a free-text submit). Return the new raw item to commit
  /// it — synchronously or as a `Future` (a spinner shows while awaiting) — or
  /// null to cancel. Lets users add missing master data (a new vendor / item /
  /// account) without leaving the field.
  final FutureOr<T?> Function(String query)? onCreate;

  /// Builds the create action's trailing label from the query (defaults to the
  /// query itself, rendered as `Create “…”`).
  final String Function(String query)? createLabelBuilder;

  const SuperAutoSuggestionsBox({
    super.key,
    required this.source,
    required this.suggestionBuilder,
    this.controller,
    this.onSelected,
    this.multiSelect = false,
    this.debounce = const Duration(milliseconds: 180),
    this.minChars = 0,
    this.maxResults = 50,
    this.showRecents = false,
    this.maxRecents = 5,
    this.initialRecents,
    this.recentsGroupLabel = 'Recent',
    this.onRecentsChanged,
    this.onSelectionChanged,
    this.onChanged,
    this.onSubmitted,
    this.hintText,
    this.showShadowHint = true,
    this.completeShadowHintOnTab = true,
    this.shadowHintStyle,
    this.decoration,
    this.label,
    this.allowFixed = false,
    this.leading,
    this.clearButton = true,
    this.highlightMatch = AutoSuggestionMatch.contains,
    this.highlightMatches = true,
    this.openOnFocus = true,
    this.maxVisibleRows = 8,
    this.width,
    this.enabled = true,
    this.disabled = false,
    this.readOnly = false,
    this.required = false,
    this.validator,
    this.requiredMessage = 'This field is required',
    this.onValidity,
    this.forceError = false,
    this.hint,
    this.density = FieldDensity.comfortable,
    this.theme,
    this.autofocus = false,
    this.focusNode,
    this.keyboardType,
    this.inputFormatters,
    this.textDirection,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.onFieldSubmitted,
    this.onTap,
    this.onTapOutside,
    this.onTapUpOutside,
    this.onEditingComplete,
    this.onSave,
    this.keyboardAppearance,
    this.onTapAlwaysCalled = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.enableIMEPersonalizedLearning = true,
    this.smartDashesType,
    this.smartQuotesType,
    this.autofillHints,
    this.maxLength,
    this.maxLengthEnforcement,
    this.showCursor,
    this.cursorWidth = 2.0,
    this.cursorHeight,
    this.cursorRadius,
    this.enableInteractiveSelection = true,
    this.selectionControls,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.scrollPhysics,
    this.mouseCursor,
    this.canRequestFocus = true,
    this.bare = false,
    this.fieldHeight,
    this.textStyle,
    this.onEscape,
    this.onTabNext,
    this.onTabPrev,
    this.scrollOnFocus = false,
    this.restoreOnBlur = true,
    this.advancedSearch = false,
    this.advancedSearchBuilder,
    this.itemBuilder,
    this.emptyBuilder,
    this.loadingBuilder,
    this.onCreate,
    this.createLabelBuilder,
  }) : assert(minChars >= 0),
       assert(maxResults >= 0),
       assert(maxRecents >= 0);

  @override
  State<SuperAutoSuggestionsBox<T>> createState() =>
      _AutoSuggestionsBoxState<T>();
}

/// Deprecated name for [SuperAutoSuggestionsBox].
@Deprecated('Use SuperAutoSuggestionsBox instead.')
typedef AutoSuggestionsBox<T> = SuperAutoSuggestionsBox<T>;

class _AutoSuggestionsBoxState<T> extends State<SuperAutoSuggestionsBox<T>> {
  late SuperAutoSuggestionsController<T> _c;
  bool _ownsController = false;

  /// The editable controller mounted in TextFormField. It mirrors the public
  /// controller's text value so shadow rendering also works when callers supply
  /// a plain external [TextEditingController].
  late _ShadowHintTextEditingController _fieldText;
  bool _syncingTextControllers = false;

  final _overlay = OverlayPortalController();
  final _link = LayerLink();
  final _fieldKey = GlobalKey();

  late FocusNode _focus;
  bool _ownsFocus = false;
  final _scroll = ScrollController();
  // Attached to whichever overlay row is currently highlighted, so we can scroll
  // it into view using real geometry (group headers / variable heights included).
  final GlobalKey _hlRowKey = GlobalKey();
  Timer? _blurTimer; // delays close-on-blur so a row tap can complete first
  bool _suppressReopen =
      false; // skip openOnFocus once (after a pick re-focuses)
  bool _advancedOpen = false; // the advanced-search dialog is showing
  bool _touched = false; // has the field been blurred at least once
  String? _lastReportedError; // last error handed to onValidity
  bool _creating = false; // an onCreate call is in flight

  @override
  void initState() {
    super.initState();
    _c = widget.controller ?? _buildController();
    _ownsController = widget.controller == null;
    _bindController();
    _c.addListener(_onModel);
    _attachFieldTextController();

    _focus = widget.focusNode ?? _c.focusNode ?? FocusNode();
    _ownsFocus = widget.focusNode == null && _c.focusNode == null;
    _focus.addListener(_onFocus);

    _c.text.addListener(_onTextForValidity);
    // Report initial validity after the first frame (so a host onValidity that
    // calls setState never runs during build).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _reportValidity();
    });
  }

  SuperAutoSuggestionsController<T> _buildController() =>
      SuperAutoSuggestionsController<T>();

  void _bindController() {
    bindSuperAutoSuggestionsControllerView(
      _c,
      widget.source,
      widget.suggestionBuilder,
      debounce: widget.debounce,
      minChars: widget.minChars,
      maxResults: widget.maxResults,
      multiSelect: widget.multiSelect,
      showRecents: widget.showRecents,
      maxRecents: widget.maxRecents,
      initialRecents: widget.initialRecents,
      recentsGroupLabel: widget.recentsGroupLabel,
      onRecentsChanged: widget.onRecentsChanged,
    );
  }

  void _attachFieldTextController() {
    _fieldText = _ShadowHintTextEditingController.fromValue(_c.text.value);
    _fieldText.addListener(_syncFieldTextToController);
    _c.text.addListener(_syncControllerTextToField);
  }

  void _detachFieldTextController() {
    _fieldText.removeListener(_syncFieldTextToController);
    _c.text.removeListener(_syncControllerTextToField);
    _fieldText.dispose();
  }

  void _syncFieldTextToController() {
    if (_syncingTextControllers || _fieldText.value == _c.text.value) return;

    // Hide a stale completion immediately. The source/controller notification
    // that follows computes a new suffix for the newly formatted value.
    _fieldText.updateShadowHint(suffix: '');
    _syncingTextControllers = true;
    try {
      _c.text.value = _fieldText.value;
    } finally {
      _syncingTextControllers = false;
    }
  }

  void _syncControllerTextToField() {
    if (_syncingTextControllers || _fieldText.value == _c.text.value) return;
    _syncingTextControllers = true;
    try {
      _fieldText.value = _c.text.value;
    } finally {
      _syncingTextControllers = false;
    }
  }

  /// Returns the visual completion suffix for the highlighted row. Inline
  /// completion is deliberately limited to prefix matches and a caret at the
  /// end of the value, preventing misleading text for contains/fuzzy results or
  /// edits made in the middle of a code.
  String get _shadowHintSuffix {
    if (!widget.showShadowHint ||
        widget.multiSelect ||
        !widget.enabled ||
        widget.disabled ||
        widget.readOnly ||
        _c.isFixed.value ||
        !_focus.hasFocus) {
      return '';
    }

    final value = _fieldText.value;
    final query = value.text;
    final selection = value.selection;
    final composing = value.composing;
    if (query.isEmpty ||
        !selection.isValid ||
        !selection.isCollapsed ||
        selection.extentOffset != query.length ||
        (composing.isValid && !composing.isCollapsed)) {
      return '';
    }

    final suggestion = _c.highlightedSuggestion;
    if (suggestion == null || !suggestion.enabled) return '';

    final completion = suggestion.displayText;

    if (completion.length <= query.length ||
        !completion.toLowerCase().startsWith(query.toLowerCase())) {
      return '';
    }
    return completion.substring(query.length);
  }

  void _updateShadowHint(TextStyle baseStyle, AutoSuggestionsBoxThemeData t) {
    final style = widget.shadowHintStyle == null
        ? baseStyle.copyWith(color: t.fg3.withValues(alpha: 0.72))
        : baseStyle.merge(widget.shadowHintStyle);
    _fieldText.updateShadowHint(suffix: _shadowHintSuffix, style: style);
  }

  /// Promotes the currently painted shadow suffix into the real editable value.
  /// Returns false when inline completion is unavailable so callers can preserve
  /// normal focus traversal.
  bool _completeShadowHint() {
    final suffix = _shadowHintSuffix;
    if (suffix.isEmpty) return false;

    final completedText = '${_fieldText.text}$suffix';
    _fieldText.updateShadowHint(suffix: '');
    _fieldText.value = TextEditingValue(
      text: completedText,
      selection: TextSelection.collapsed(offset: completedText.length),
    );
    return true;
  }

  // ── validation ──
  /// The raw error for the current value (independent of touched state).
  String? get _error {
    final text = _c.query;
    if (widget.required) {
      final empty = widget.multiSelect
          ? _c.selectedItems.isEmpty
          : text.trim().isEmpty;
      if (empty) return widget.requiredMessage;
    }
    return widget.validator?.call(text);
  }

  /// The error to actually display — gated on touched / forceError, suppressed
  /// while disabled.
  String? get _visibleError {
    if (widget.disabled) return null;
    if (!_touched && !widget.forceError) return null;
    return _error;
  }

  void _onTextForValidity() => _reportValidity();

  void _reportValidity() {
    final e = _error;
    if (e != _lastReportedError) {
      _lastReportedError = e;
      widget.onValidity?.call(e);
    }
  }

  void _onFocus() {
    if (mounted) setState(() {}); // repaint focused fill/border + touched error
    if (_focus.hasFocus) {
      _blurTimer?.cancel();
      if (_suppressReopen) {
        _suppressReopen = false; // consume: don't reopen right after a pick
      } else if (widget.openOnFocus &&
          !widget.disabled &&
          !widget.readOnly &&
          !_c.isFixed.value) {
        _c.open();
      }
      if (widget.scrollOnFocus) _scrollIntoView();
    } else {
      _touched = true; // first blur → validation may now surface
      if (_advancedOpen) {
        return; // focus moved into the advanced dialog — ignore
      }
      // Delay the close so a mouse click on a row (which blurs the field on
      // pointer-down) still lands its tap on pointer-up. A row tap calls
      // _pick → requestFocus, which cancels this timer.
      _blurTimer?.cancel();
      _blurTimer = Timer(const Duration(milliseconds: 200), () {
        if (!mounted || _focus.hasFocus) return;
        _c.close();
        // Left without picking: revert unconfirmed typing to the committed value
        // (or clear the multi-select search box).
        if (widget.multiSelect) {
          _c.setText('');
        } else if (widget.restoreOnBlur) {
          _c.restoreCommitted();
        }
      });
    }
  }

  /// Bring the field into view inside the nearest scrollable ancestor, after the
  /// current frame (so the overlay/keyboard insets are accounted for).
  void _scrollIntoView() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_focus.hasFocus) return;
      final ctx = _fieldKey.currentContext;
      if (ctx == null) return;
      final scrollable = Scrollable.maybeOf(ctx);
      if (scrollable == null) return; // no scrollable ancestor — nothing to do
      Scrollable.ensureVisible(
        ctx,
        alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
        duration: AutoSuggestionsBoxThemeData.durBase,
        curve: AutoSuggestionsBoxThemeData.curveStandard,
      );
    });
  }

  void _onModel() {
    if (_c.isOpen && !_overlay.isShowing) {
      _overlay.show();
    } else if (!_c.isOpen && _overlay.isShowing) {
      _overlay.hide();
    }
    if (_c.isOpen) _ensureHighlightVisible();
    _reportValidity();
    if (mounted) setState(() {});
  }

  /// Keep the highlighted row visible inside the overlay as the user arrows
  /// through it. Measures the highlighted row's real position (so group headers
  /// and variable row heights are handled) and animates only when it's off-view.
  void _ensureHighlightVisible() {
    if (_c.highlightedIndex < 0) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      final ctx = _hlRowKey.currentContext;
      if (ctx == null) {
        // Target row isn't built yet (e.g. a last↔first wrap). Snap toward the
        // matching end so the next frame can fine-tune.
        if (!_scroll.hasClients) return;
        final i = _c.highlightedIndex;
        if (i == 0) {
          _scroll.jumpTo(0);
        } else if (i == _c.results.length - 1) {
          _scroll.jumpTo(_scroll.position.maxScrollExtent);
        }
        return;
      }
      final box = ctx.findRenderObject();
      if (box is! RenderBox || !box.attached) return;
      final viewport = RenderAbstractViewport.maybeOf(box);
      if (viewport == null) return;

      // Scroll offsets that align the row's top to the viewport top, and bottom
      // to the viewport bottom; between them the row is fully visible.
      final toTop = viewport.getOffsetToReveal(box, 0.0).offset;
      final toBottom = viewport.getOffsetToReveal(box, 1.0).offset;
      final lo = toBottom < toTop ? toBottom : toTop;
      final hi = toBottom < toTop ? toTop : toBottom;
      final current = _scroll.offset;

      // The row is fully visible while the scroll offset is within [lo, hi].
      double? target;
      if (current < lo) {
        target = lo; // row sits below the fold → scroll down to reveal it
      } else if (current > hi) {
        target = hi; // row sits above the fold → scroll up to reveal it
      }
      if (target == null) return; // already fully visible — don't move

      final max = _scroll.position.maxScrollExtent;
      _scroll.animateTo(
        target.clamp(0.0, max),
        duration: AutoSuggestionsBoxThemeData.durFast,
        curve: AutoSuggestionsBoxThemeData.curveStandard,
      );
    });
  }

  @override
  void didUpdateWidget(covariant SuperAutoSuggestionsBox<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller &&
        widget.controller != null) {
      _c.removeListener(_onModel);
      _c.text.removeListener(_onTextForValidity);
      _detachFieldTextController();
      if (_ownsController) _c.dispose();
      _c = widget.controller!;
      _ownsController = false;
      _bindController();
      _c.addListener(_onModel);
      _attachFieldTextController();
      _c.text.addListener(_onTextForValidity);
    } else if (widget.source != oldWidget.source ||
        widget.suggestionBuilder != oldWidget.suggestionBuilder ||
        widget.debounce != oldWidget.debounce ||
        widget.minChars != oldWidget.minChars ||
        widget.maxResults != oldWidget.maxResults ||
        widget.multiSelect != oldWidget.multiSelect ||
        widget.showRecents != oldWidget.showRecents ||
        widget.maxRecents != oldWidget.maxRecents ||
        widget.initialRecents != oldWidget.initialRecents ||
        widget.recentsGroupLabel != oldWidget.recentsGroupLabel ||
        widget.onRecentsChanged != oldWidget.onRecentsChanged) {
      _bindController();
    }
  }

  @override
  void dispose() {
    _blurTimer?.cancel();
    _c.text.removeListener(_onTextForValidity);
    _c.removeListener(_onModel);
    _detachFieldTextController();
    if (_ownsController) _c.dispose();
    _focus.removeListener(_onFocus);
    if (_ownsFocus) _focus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  // ── keyboard ──
  KeyEventResult _onKey(FocusNode node, KeyEvent e) {
    if (e is! KeyDownEvent && e is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (widget.disabled || widget.readOnly || _c.isFixed.value) {
      return KeyEventResult.ignored;
    }
    // Ctrl/⌘+F → open the advanced search surface.
    if (e.logicalKey == LogicalKeyboardKey.keyF &&
        (HardwareKeyboard.instance.isControlPressed ||
            HardwareKeyboard.instance.isMetaPressed)) {
      if (widget.advancedSearch) {
        _openAdvanced();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }
    switch (e.logicalKey) {
      case LogicalKeyboardKey.arrowDown:
        _c.moveHighlight(1);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowUp:
        _c.moveHighlight(-1);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.enter:
      case LogicalKeyboardKey.numpadEnter:
        _handleFieldSubmitted(_c.query);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.escape:
        if (widget.onEscape != null) {
          if (_c.isOpen) _c.close();
          widget.onEscape!();
          return KeyEventResult.handled;
        }
        if (_c.isOpen) {
          _c.close();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      case LogicalKeyboardKey.tab:
        final shift = HardwareKeyboard.instance.isShiftPressed;
        if (!shift && widget.completeShadowHintOnTab && _completeShadowHint()) {
          return KeyEventResult.handled;
        }
        final cb = shift ? widget.onTabPrev : widget.onTabNext;
        if (cb != null) {
          if (_c.isOpen) _c.close();
          cb();
          return KeyEventResult.handled;
        }
        if (_c.isOpen) _c.close();
        return KeyEventResult.ignored; // let focus traversal proceed
    }
    return KeyEventResult.ignored;
  }

  void _pick(T item) => _choose(item);

  /// Applies the component's submit semantics, then reports the resulting query
  /// through [SuperAutoSuggestionsBox.onFieldSubmitted]. This path is shared by
  /// physical Enter keys and software-keyboard actions.
  void _handleFieldSubmitted(String _) {
    if (widget.disabled ||
        widget.readOnly ||
        _c.isFixed.value ||
        !widget.enabled) {
      return;
    }

    final highlighted = _c.highlighted;
    final highlightedSuggestion = _c.highlightedSuggestion;
    if (highlighted != null &&
        highlightedSuggestion != null &&
        highlightedSuggestion.enabled) {
      _choose(highlighted);
    } else if (_canCreate) {
      _startCreate(); // “＋ Create …” takes submit before free-text acceptance.
    } else if (_c.allowFreeText && !widget.multiSelect) {
      _c.acceptFreeText();
      widget.onSubmitted?.call(_c.query);
      _c.close();
    }

    widget.onFieldSubmitted?.call(_c.query);
  }

  /// Open the Advanced Search surface (Ctrl/⌘+F). Reuses the live controller so
  /// a pick made there commits straight back into the field.
  Future<void> _openAdvanced() async {
    if (_advancedOpen) return;
    _advancedOpen = true;
    _c.open();
    final t = _resolveTheme(context);
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (ctx) =>
          widget.advancedSearchBuilder?.call(ctx, _c) ??
          _AdvancedSearchDialog<T>(
            controller: _c,
            theme: t,
            title:
                widget.decoration?.labelText ??
                // ignore: deprecated_member_use_from_same_package
                widget.label ??
                widget.hintText ??
                'Advanced Search',
            multiSelect: widget.multiSelect,
            highlightMatch: widget.highlightMatch,
            onPick: (item) {
              if (widget.multiSelect) {
                _c.toggleSelected(item);
                widget.onSelectionChanged?.call(_c.selectedItems);
                widget.onSelected?.call(item);
              } else {
                _c.select(item);
                widget.onSelected?.call(item);
                Navigator.of(ctx).pop();
              }
            },
          ),
    );
    _advancedOpen = false;
    if (mounted) {
      _suppressReopen = true; // don't auto-pop the inline overlay on refocus
      _focus.requestFocus();
    }
  }

  /// Unified selection entry point for both tap and Enter. In multi-select it
  /// toggles membership and keeps the overlay open; otherwise it commits the
  /// value and closes. Always returns focus to the field.
  void _choose(T item) {
    final suggestion = _c.suggestionFor(item);
    if (!suggestion.enabled) return;
    _blurTimer?.cancel();
    if (widget.multiSelect) {
      _c.toggleSelected(item);
      widget.onSelectionChanged?.call(_c.selectedItems);
      widget.onSelected?.call(item);
      _focus.requestFocus(); // keep searching; overlay stays open
    } else {
      _c.select(item); // writes the label + closes the overlay
      widget.onSelected?.call(item);
      if (!_focus.hasFocus) {
        _suppressReopen = true; // a mouse pick will re-focus
      }
      _focus.requestFocus();
    }
  }

  // ── inline create ──
  /// Whether a "＋ Create" action should be offered: an `onCreate` is wired, the
  /// query is non-empty, and no existing row matches it exactly (case-insensitive).
  bool get _canCreate {
    if (widget.onCreate == null) return false;
    final q = _c.query.trim();
    if (q.isEmpty) return false;
    final lower = q.toLowerCase();
    for (final s in _c.suggestions) {
      if (s.displayText.toLowerCase() == lower) return false;
    }
    return true;
  }

  /// The label shown in the create action (`createLabelBuilder` or the query).
  String get _createLabel =>
      widget.createLabelBuilder?.call(_c.query.trim()) ?? _c.query.trim();

  /// Invoke `onCreate`, showing a spinner while it resolves; commit the returned
  /// suggestion (if any) exactly as a normal pick.
  Future<void> _startCreate() async {
    final create = widget.onCreate;
    final q = _c.query.trim();
    if (create == null || q.isEmpty || _creating) return;
    _blurTimer?.cancel();
    setState(() => _creating = true);
    T? created;
    try {
      created = await create(q);
    } finally {
      if (mounted) setState(() => _creating = false);
    }
    if (!mounted || created == null) return;
    _choose(created);
  }

  /// Resolve the effective theme: a directly-assigned [SuperAutoSuggestionsBox.theme]
  /// wins over the ambient extension (which falls back to the dark preset).
  AutoSuggestionsBoxThemeData _resolveTheme(BuildContext context) =>
      widget.theme ?? AutoSuggestionsBoxThemeData.of(context);

  @override
  Widget build(BuildContext context) {
    if (_c.isHiden) return const SizedBox.shrink();
    final t = _resolveTheme(context);
    final error = _visibleError;
    final field = _buildField(t, error);
    final label =
        widget.decoration?.labelText ??
        // ignore: deprecated_member_use_from_same_package
        widget.label;
    final helper =
        widget.decoration?.helperText ??
        // ignore: deprecated_member_use_from_same_package
        widget.hint;
    return SizedBox(
      width: widget.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null || widget.allowFixed) ...[
            Row(
              children: [
                if (label != null)
                  Expanded(
                    child: _FieldLabel(
                      text: label,
                      required: widget.required,
                      color: t.fg2,
                    ),
                  )
                else
                  const Spacer(),
                if (widget.allowFixed)
                  _FixedButton(controller: _c, color: t.fg3),
              ],
            ),
            const SizedBox(height: 8),
          ],
          CompositedTransformTarget(
            link: _link,
            child: OverlayPortal(
              controller: _overlay,
              overlayChildBuilder: (ctx) => _buildOverlay(ctx, t),
              child: field,
            ),
          ),
          // Hint sits beneath the control and is hidden whenever an error shows
          // (errors surface only through the suffix badge — never inline).
          if (helper != null && error == null) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 2),
              child: Text(
                helper,
                style: TextStyle(
                  fontFamily: (SuperMaterialThemeData.of(
                    context,
                  ).textTheme).bodyMedium?.fontFamily,
                  fontSize: 12,
                  height: 1.35,
                  color: t.fg3,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildField(AutoSuggestionsBoxThemeData t, String? error) {
    final focused = _focus.hasFocus;
    final bare = widget.bare;
    final disabled = widget.disabled;
    final readOnly = (widget.readOnly || _c.isFixed.value) && !disabled;
    final interactive = widget.enabled && !disabled && !readOnly;
    final hasError = error != null;
    final fs = t.focusedStyle;
    final cs = Theme.of(context).colorScheme;

    final minH =
        widget.fieldHeight ??
        (widget.density == FieldDensity.compact
            ? AutoSuggestionsBoxThemeData.fieldCompact
            : AutoSuggestionsBoxThemeData.fieldHeight);

    // Text style — merge focused fontStyle override when focused.
    var baseStyle =
        (widget.textStyle ??
                TextStyle(
                  fontFamily: (SuperMaterialThemeData.of(
                    context,
                  ).textTheme).bodyMedium?.fontFamily,
                  fontSize: 14,
                  color: t.fg1,
                  height: 1.2,
                ))
            .copyWith(color: t.fg1);
    if (focused && fs.fontStyle != null) {
      baseStyle = baseStyle.merge(fs.fontStyle);
    }
    _updateShadowHint(baseStyle, t);

    // ── Border helpers ──
    const double bw = AutoSuggestionsBoxThemeData.fieldBorderWidth;
    OutlineInputBorder ob(Color c) => bare
        ? const OutlineInputBorder(borderSide: BorderSide.none)
        : OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              AutoSuggestionsBoxThemeData.radiusSm,
            ),
            borderSide: BorderSide(color: c, width: bw),
          );

    final Color enabledBorderColor = hasError ? cs.error : t.border;
    final Color focusedBorderColor = hasError
        ? cs.error
        : (fs.border?.color ?? t.borderFocus);
    final Color disabledBorderColor = t.border;

    // ── Fill ──
    final Color fillColor = (bare || disabled)
        ? Colors.transparent
        : focused
        ? (fs.fillColor ?? t.fieldBgFocus)
        : t.fieldBg;

    // ── Prefix icon ──
    final Widget leadingWidget =
        widget.decoration?.prefixIcon ??
        // ignore: deprecated_member_use_from_same_package
        widget.leading ??
        (bare
            ? const SizedBox.shrink()
            : Icon(
                Icons.search_rounded,
                size: 18,
                color: focused ? t.borderFocus : t.fg3,
              ));
    final bool hasLeading =
        !(leadingWidget is SizedBox &&
            leadingWidget.width == 0 &&
            leadingWidget.height == 0);

    // ── Suffix row ──
    final suffixWidgets = <Widget>[
      ..._suffixChildren(t, _c.query.isNotEmpty, interactive),
      if (hasError) ...[
        const SizedBox(width: 4),
        _ErrorBadge(error: error, cs: cs),
      ],
      const SizedBox(width: 4),
    ];

    final decoration = InputDecoration(
      hintText: widget.decoration?.hintText ?? widget.hintText,
      hintStyle:
          widget.decoration?.hintStyle ??
          baseStyle.copyWith(color: t.fg3, fontWeight: FontWeight.w400),
      counterText: widget.maxLength == null ? null : '',
      // Leading icon
      prefixIcon: hasLeading
          ? Padding(
              padding: const EdgeInsetsDirectional.only(start: 10, end: 6),
              child: leadingWidget,
            )
          : null,
      prefixIconConstraints: hasLeading
          ? widget.decoration?.prefixIconConstraints ??
                const BoxConstraints(minWidth: 0, minHeight: 0)
          : null,
      // Suffix row
      suffixIcon: Padding(
        padding: const EdgeInsetsDirectional.only(end: 2),
        child: Row(mainAxisSize: MainAxisSize.min, children: suffixWidgets),
      ),
      suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      // Fill
      filled: !bare && !disabled,
      fillColor: fillColor,
      // Sizing
      contentPadding: EdgeInsets.symmetric(
        horizontal: bare ? 9 : 12,
        vertical: 0,
      ),
      // Borders — fully specified; overrides the ambient inputDecorationTheme.
      border: ob(enabledBorderColor),
      enabledBorder: ob(enabledBorderColor),
      focusedBorder: ob(focusedBorderColor),
      disabledBorder: ob(disabledBorderColor),
      errorBorder: ob(cs.error),
      focusedErrorBorder: ob(cs.error),
    );

    final field = KeyedSubtree(
      key: _fieldKey,
      child: Focus(
        onKeyEvent: _onKey,
        child: TextFormField(
          key: _c.formFieldKey,
          controller: _fieldText,
          focusNode: _focus,
          enabled: widget.enabled && !disabled,
          readOnly: readOnly,
          autofocus: widget.autofocus,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          textDirection: widget.textDirection,
          textAlign: widget.textAlign,
          textAlignVertical: widget.textAlignVertical,
          textInputAction: widget.textInputAction,
          textCapitalization: widget.textCapitalization,
          keyboardAppearance: widget.keyboardAppearance,
          onTapAlwaysCalled: widget.onTapAlwaysCalled,
          autocorrect: widget.autocorrect,
          enableSuggestions: widget.enableSuggestions,
          enableIMEPersonalizedLearning: widget.enableIMEPersonalizedLearning,
          smartDashesType: widget.smartDashesType,
          smartQuotesType: widget.smartQuotesType,
          autofillHints: widget.autofillHints,
          maxLength: widget.maxLength,
          maxLengthEnforcement: widget.maxLengthEnforcement,
          showCursor: widget.showCursor,
          cursorWidth: widget.cursorWidth,
          cursorHeight: widget.cursorHeight,
          cursorRadius: widget.cursorRadius,
          enableInteractiveSelection: widget.enableInteractiveSelection,
          selectionControls: widget.selectionControls,
          scrollPadding: widget.scrollPadding,
          scrollPhysics: widget.scrollPhysics,
          mouseCursor: widget.mouseCursor,
          canRequestFocus: widget.canRequestFocus,
          onChanged: (v) {
            widget.onChanged?.call(v);
            if (interactive && !_c.isOpen) _c.open();
          },
          onTap: widget.enabled && !disabled
              ? () {
                  widget.onTap?.call();
                  if (interactive) _c.open();
                }
              : null,
          onTapOutside: widget.onTapOutside,
          onTapUpOutside: widget.onTapUpOutside,
          onEditingComplete: widget.onEditingComplete,
          onFieldSubmitted: _handleFieldSubmitted,
          onSaved: widget.onSave,
          style: baseStyle,
          cursorColor: fs.cursorColor ?? t.borderFocus,
          decoration: decoration,
        ),
      ),
    );

    return Opacity(
      opacity: disabled ? 0.55 : 1.0,
      child: SizedBox(height: minH, child: field),
    );
  }

  /// The trailing adornments (count pill · spinner · clear / chevron) spliced
  /// into the field row. Taps are inert while the field is non-interactive.
  List<Widget> _suffixChildren(
    AutoSuggestionsBoxThemeData t,
    bool hasText,
    bool interactive,
  ) {
    final children = <Widget>[];
    // Multi-select: a count pill of how many rows are chosen.
    if (widget.multiSelect && _c.selectedItems.isNotEmpty) {
      children.add(
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '${_c.selectedItems.length}',
              style: TextStyle(
                fontFamily: (SuperMaterialThemeData.of(
                  context,
                ).textTheme).bodyMedium?.fontFamily,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }
    if (_c.isLoading) {
      children.add(
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 4),
          child: SizedBox(
            width: 15,
            height: 15,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      );
    }
    if (widget.clearButton && hasText && interactive) {
      children.add(
        _IconBtn(
          icon: Icons.close_rounded,
          color: t.fg3,
          hoverColor: t.fg1,
          onTap: () {
            _c.clear();
            _focus.requestFocus();
          },
        ),
      );
    } else {
      children.add(
        _IconBtn(
          icon: _c.isOpen
              ? Icons.expand_less_rounded
              : Icons.expand_more_rounded,
          color: t.fg3,
          hoverColor: t.fg1,
          onTap: interactive
              ? () {
                  _c.toggle();
                  _focus.requestFocus();
                }
              : () {},
        ),
      );
    }
    return children;
  }

  // ── overlay ──
  Widget _buildOverlay(BuildContext ctx, AutoSuggestionsBoxThemeData t) {
    final box = _fieldKey.currentContext?.findRenderObject() as RenderBox?;
    final fieldSize =
        box?.size ?? const Size(280, AutoSuggestionsBoxThemeData.fieldHeight);
    final fieldW = widget.width ?? fieldSize.width;

    // Decide flip: place above when there isn't room below.
    final media = MediaQuery.of(ctx);
    final fieldTopLeft = box?.localToGlobal(Offset.zero) ?? Offset.zero;
    final spaceBelow =
        media.size.height -
        (fieldTopLeft.dy + fieldSize.height) -
        media.viewInsets.bottom;
    final desired = _overlayHeight(t);
    final flipUp = spaceBelow < desired + 16 && fieldTopLeft.dy > spaceBelow;

    final followerAnchor = flipUp ? Alignment.bottomLeft : Alignment.topLeft;
    final targetAnchor = flipUp ? Alignment.topLeft : Alignment.bottomLeft;
    const gap = AutoSuggestionsBoxThemeData.overlayGap;

    return Stack(
      children: [
        // tap-outside scrim to dismiss
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => _c.close(),
          ),
        ),
        CompositedTransformFollower(
          link: _link,
          showWhenUnlinked: false,
          offset: Offset(0, flipUp ? -gap : gap),
          followerAnchor: followerAnchor,
          targetAnchor: targetAnchor,
          child: Align(
            alignment: flipUp ? Alignment.bottomLeft : Alignment.topLeft,
            child: AutoSuggestionsPanel<T>(
              width: fieldW.clamp(
                180.0,
                AutoSuggestionsBoxThemeData.overlayMaxWidth,
              ),
              theme: t,
              controller: _c,
              scroll: _scroll,
              maxVisibleRows: widget.maxVisibleRows,
              highlightMatch: widget.highlightMatch,
              highlightMatches: widget.highlightMatches,
              itemBuilder: widget.itemBuilder,
              emptyBuilder: widget.emptyBuilder,
              loadingBuilder: widget.loadingBuilder,
              hlKey: _hlRowKey,
              multiSelect: widget.multiSelect,
              onPick: _pick,
              onHover: _c.highlightAt,
              createLabel: _canCreate ? _createLabel : null,
              creating: _creating,
              onCreate: _startCreate,
            ),
          ),
        ),
      ],
    );
  }

  double _overlayHeight(AutoSuggestionsBoxThemeData t) {
    final rows = _c.results.length.clamp(0, widget.maxVisibleRows);
    return (rows == 0 ? 56 : rows * AutoSuggestionsBoxThemeData.rowHeight + 10)
        .toDouble();
  }
}

// ── the dropdown panel ──
class AutoSuggestionsPanel<T> extends StatelessWidget {
  final double width;
  final AutoSuggestionsBoxThemeData theme;
  final SuperAutoSuggestionsController<T> controller;
  final ScrollController scroll;
  final int maxVisibleRows;
  final AutoSuggestionMatch highlightMatch;
  final bool highlightMatches;
  final Widget Function(BuildContext, T, SuperAutoSuggestionsItem<T>, bool)? itemBuilder;
  final Widget Function(BuildContext, String)? emptyBuilder;
  final Widget Function(BuildContext, String)? loadingBuilder;
  final GlobalKey hlKey;
  final bool multiSelect;
  final ValueChanged<T> onPick;
  final ValueChanged<int> onHover;

  /// When non-null, a “＋ Create …” footer for this text is shown under the list.
  final String? createLabel;

  /// True while the `onCreate` call is in flight (footer shows a spinner).
  final bool creating;

  /// Invoked when the create footer is tapped.
  final VoidCallback? onCreate;

  const AutoSuggestionsPanel({
    super.key,
    required this.width,
    required this.theme,
    required this.controller,
    required this.scroll,
    required this.maxVisibleRows,
    required this.highlightMatch,
    required this.highlightMatches,
    required this.itemBuilder,
    required this.emptyBuilder,
    required this.loadingBuilder,
    required this.hlKey,
    required this.multiSelect,
    required this.onPick,
    required this.onHover,
    this.createLabel,
    this.creating = false,
    this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final results = controller.results;
    final q = controller.effectiveQuery;
    final maxH = maxVisibleRows * AutoSuggestionsBoxThemeData.rowHeight + 10;

    Widget body;
    if (controller.isLoading && results.isEmpty) {
      // Async source is fetching and nothing to show yet.
      body =
          loadingBuilder?.call(context, q) ??
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                SizedBox(
                  width: 15,
                  height: 15,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  q.trim().isEmpty ? 'Loading…' : 'Searching “$q”…',
                  style: TextStyle(
                    fontFamily: (SuperMaterialThemeData.of(
                      context,
                    ).textTheme).bodyMedium?.fontFamily,
                    fontSize: 13,
                    color: t.fg2,
                  ),
                ),
              ],
            ),
          );
    } else if (results.isEmpty) {
      body =
          emptyBuilder?.call(context, q) ??
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Icon(Icons.search_off_rounded, size: 16, color: t.fg3),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    q.trim().isEmpty ? 'Type to search' : 'No matches for “$q”',
                    style: TextStyle(
                      fontFamily: (SuperMaterialThemeData.of(
                        context,
                      ).textTheme).bodyMedium?.fontFamily,
                      fontSize: 13,
                      color: t.fg2,
                    ),
                  ),
                ),
              ],
            ),
          );
    } else {
      body = ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxH.toDouble()),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progressive remote fetch in flight: a thin indicator ABOVE the
            // already-visible local rows.
            if (controller.isLoadingMore)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: t.accentWash(0.06),
                  border: Border(bottom: BorderSide(color: t.border)),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 13,
                      height: 13,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Text(
                      'Loading more from server…',
                      style: TextStyle(
                        fontFamily: (SuperMaterialThemeData.of(
                          context,
                        ).textTheme).bodyMedium?.fontFamily,
                        fontSize: 11.5,
                        color: t.fg2,
                      ),
                    ),
                  ],
                ),
              ),
            Flexible(
              child: NotificationListener<ScrollNotification>(
                onNotification: (n) {
                  // Infinite scroll: pull the next page as the list nears bottom.
                  if (controller.isPaged &&
                      controller.hasMore &&
                      !controller.isLoadingPage) {
                    final m = n.metrics;
                    if (m.axis == Axis.vertical &&
                        m.pixels >= m.maxScrollExtent - 120) {
                      controller.loadNextPage();
                    }
                  }
                  return false;
                },
                child: Scrollbar(
                  controller: scroll,
                  child: ListView.builder(
                    controller: scroll,
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    shrinkWrap: true,
                    itemCount:
                        results.length + (controller.isLoadingPage ? 1 : 0),
                    itemBuilder: (ctx, i) {
                      if (i >= results.length) return _PageLoadingRow(theme: t);
                      final item = results[i];
                      final s = controller.suggestionAt(i);
                      final isHl = controller.isHighlighted(i);
                      final showGroup =
                          s.group != null &&
                          (i == 0 ||
                              controller.suggestionAt(i - 1).group != s.group);
                      final row = _Row<T>(
                        key: isHl ? hlKey : null,
                        theme: t,
                        item: item,
                        suggestion: s,
                        query: q,
                        highlighted: isHl,
                        highlightMatch: highlightMatch,
                        highlightMatches: highlightMatches,
                        custom: itemBuilder,
                        multiSelect: multiSelect,
                        selected:
                            multiSelect && controller.isSelectedValue(s.value),
                        onTap: () => onPick(item),
                        onHover: () => onHover(i),
                      );
                      if (!showGroup) return row;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                              14,
                              i == 0 ? 4 : 9,
                              14,
                              5,
                            ),
                            child: Text(
                              s.group!.toUpperCase(),
                              style: TextStyle(
                                fontFamily: (SuperMaterialThemeData.of(
                                  context,
                                ).textTheme).bodyMedium?.fontFamily,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.7,
                                color: t.groupFg,
                              ),
                            ),
                          ),
                          row,
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Material(
      type: MaterialType.transparency,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: t.overlayBg,
          borderRadius: BorderRadius.circular(
            AutoSuggestionsBoxThemeData.radiusLg,
          ),
          border: Border.all(color: t.border),
          boxShadow: AutoSuggestionsBoxThemeData.overlayShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            body,
            if (createLabel != null)
              _CreateFooter(
                theme: t,
                label: createLabel!,
                creating: creating,
                showEnterHint: controller.results.isEmpty,
                onTap: onCreate,
              ),
          ],
        ),
      ),
    );
  }
}

// ── one suggestion row ──
class _Row<T> extends StatelessWidget {
  final AutoSuggestionsBoxThemeData theme;
  final T item;
  final SuperAutoSuggestionsItem<T> suggestion;
  final String query;
  final bool highlighted;
  final AutoSuggestionMatch highlightMatch;
  final bool highlightMatches;
  final Widget Function(BuildContext, T, SuperAutoSuggestionsItem<T>, bool)? custom;
  final bool multiSelect;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onHover;

  const _Row({
    super.key,
    required this.theme,
    required this.item,
    required this.suggestion,
    required this.query,
    required this.highlighted,
    required this.highlightMatch,
    required this.highlightMatches,
    required this.custom,
    required this.multiSelect,
    required this.selected,
    required this.onTap,
    required this.onHover,
  });

  Widget _checkbox(AutoSuggestionsBoxThemeData t, BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Container(
      width: 18,
      height: 18,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? accent : Colors.transparent,
        border: Border.all(color: selected ? accent : t.fg3, width: 1.6),
        borderRadius: BorderRadius.circular(
          AutoSuggestionsBoxThemeData.radiusSm,
        ),
      ),
      child: selected
          ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final s = suggestion;
    final enabled = s.enabled;

    final inner =
        custom?.call(context, item, s, highlighted) ??
        Row(
          children: [
            if (s.icon != null || s.iconData != null) ...[
              s.icon ??
                  Icon(
                    s.iconData,
                    size: 17,
                    color: highlighted
                        ? Theme.of(context).colorScheme.primary
                        : t.fg3,
                  ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  s.title ??
                      AutoSuggestionsHighlight(
                        text: s.displayText,
                        query: query,
                        match: highlightMatch,
                        enabled: highlightMatches,
                        baseStyle: TextStyle(
                          fontFamily: (SuperMaterialThemeData.of(
                            context,
                          ).textTheme).bodyMedium?.fontFamily,
                          fontSize: 13.5,
                          height: 1.2,
                          color: enabled ? t.fg1 : t.fg3,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  if (s.description != null ||
                      s.descriptionText != null) ...[
                    const SizedBox(height: 1),
                    s.description ??
                        Text(
                          s.descriptionText!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: (SuperMaterialThemeData.of(
                              context,
                            ).textTheme).bodyMedium?.fontFamily,
                            fontSize: 11.5,
                            height: 1.2,
                            color: t.fg2,
                          ),
                        ),
                  ],
                ],
              ),
            ),
            if (s.trailing != null || s.trailingText != null) ...[
              const SizedBox(width: 10),
              s.trailing ??
                  Text(
                    s.trailingText!,
                    style: TextStyle(
                      fontFamily: (SuperMaterialThemeData.of(
                        context,
                      ).textTheme).mono.fontFamily,
                      fontSize: 12,
                      height: 1.2,
                      color: enabled ? t.fg2 : t.fg3,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
            ],
            if (highlighted && enabled) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.subdirectory_arrow_left_rounded,
                size: 14,
                color: t.fg3,
              ),
            ],
          ],
        );

    // In multi-select prepend a checkbox so the chosen state is explicit.
    final content = multiSelect
        ? Row(
            children: [
              _checkbox(t, context),
              const SizedBox(width: 11),
              Expanded(child: inner),
            ],
          )
        : inner;

    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => onHover(),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: AutoSuggestionsBoxThemeData.durFast,
          height: AutoSuggestionsBoxThemeData.rowHeight,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: highlighted
                ? t.hover
                : (selected ? t.accentWash(0.06) : Colors.transparent),
            border: BorderDirectional(
              start: BorderSide(
                color: (highlighted || selected) && enabled
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                width: 2.5,
              ),
            ),
          ),
          child: content,
        ),
      ),
    );
  }
}

// ── the "＋ Create …" footer (inline create; see SuperAutoSuggestionsBox.onCreate) ──
class _CreateFooter extends StatefulWidget {
  final AutoSuggestionsBoxThemeData theme;
  final String label;
  final bool creating;
  final bool showEnterHint;
  final VoidCallback? onTap;
  const _CreateFooter({
    required this.theme,
    required this.label,
    required this.creating,
    this.showEnterHint = true,
    this.onTap,
  });

  @override
  State<_CreateFooter> createState() => _CreateFooterState();
}

class _CreateFooterState extends State<_CreateFooter> {
  bool _h = false;
  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    return MouseRegion(
      cursor: widget.creating
          ? SystemMouseCursors.wait
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _h = true),
      onExit: (_) => setState(() => _h = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.creating ? null : widget.onTap,
        child: AnimatedContainer(
          duration: AutoSuggestionsBoxThemeData.durFast,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: _h ? t.accentWash(0.12) : t.accentWash(0.05),
            border: Border(top: BorderSide(color: t.border)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: widget.creating
                    ? CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : Icon(
                        Icons.add_rounded,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: 'Create ',
                    style: TextStyle(
                      fontFamily: (SuperMaterialThemeData.of(
                        context,
                      ).textTheme).bodyMedium?.fontFamily,
                      fontSize: 13,
                      color: t.fg2,
                    ),
                    children: [
                      TextSpan(
                        text: '“${widget.label}”',
                        style: TextStyle(
                          fontFamily: (SuperMaterialThemeData.of(
                            context,
                          ).textTheme).bodyMedium?.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: t.fg1,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              if (widget.showEnterHint)
                Text(
                  'ENTER',
                  style: TextStyle(
                    fontFamily: (SuperMaterialThemeData.of(
                      context,
                    ).textTheme).bodyMedium?.fontFamily,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: t.fg3,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── bottom "loading more…" row appended while a paged source fetches ──
class _PageLoadingRow extends StatelessWidget {
  final AutoSuggestionsBoxThemeData theme;
  const _PageLoadingRow({required this.theme});
  @override
  Widget build(BuildContext context) {
    final t = theme;
    return Container(
      height: AutoSuggestionsBoxThemeData.rowHeight,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 13,
            height: 13,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 9),
          Text(
            'Loading more…',
            style: TextStyle(
              fontFamily: (SuperMaterialThemeData.of(
                context,
              ).textTheme).bodyMedium?.fontFamily,
              fontSize: 11.5,
              color: t.fg2,
            ),
          ),
        ],
      ),
    );
  }
}

// ── tiny hover-aware icon button used in the field suffix ──
class _IconBtn extends StatefulWidget {
  final IconData icon;
  final Color color;
  final Color hoverColor;
  final VoidCallback onTap;
  const _IconBtn({
    required this.icon,
    required this.color,
    required this.hoverColor,
    required this.onTap,
  });
  @override
  State<_IconBtn> createState() => _IconBtnState();
}

class _IconBtnState extends State<_IconBtn> {
  bool _h = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _h = true),
      onExit: (_) => setState(() => _h = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(
            widget.icon,
            size: 17,
            color: _h ? widget.hoverColor : widget.color,
          ),
        ),
      ),
    );
  }
}

// ── uppercase field label with optional required asterisk ──
// Matches super_form_field's FieldShell label: ALL CAPS, 11/700, ~0.05em
// tracking, with a danger-red `*` when required.
class _FieldLabel extends StatelessWidget {
  const _FieldLabel({
    required this.text,
    required this.required,
    required this.color,
  });

  final String text;
  final bool required;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontFamily: (SuperMaterialThemeData.of(
        context,
      ).textTheme).bodyMedium?.fontFamily,
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.55,
      color: color,
    );
    if (!required) return Text(text.toUpperCase(), style: style);
    return Text.rich(
      TextSpan(
        text: text.toUpperCase(),
        style: style,
        children: [
          TextSpan(
            text: ' *',
            style: style.copyWith(color: Theme.of(context).colorScheme.error),
          ),
        ],
      ),
    );
  }
}

class _FixedButton<T> extends StatelessWidget {
  const _FixedButton({required this.controller, required this.color});

  final SuperAutoSuggestionsController<T> controller;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: controller.isFixed,
      builder: (context, fixed, _) => Tooltip(
        message: fixed ? 'Unfix' : 'Fix',
        child: IconButton(
          visualDensity: VisualDensity.compact,
          constraints: const BoxConstraints.tightFor(width: 26, height: 26),
          padding: EdgeInsets.zero,
          iconSize: 14,
          color: fixed ? Theme.of(context).colorScheme.primary : color,
          onPressed: () => controller.isFixed.value = !fixed,
          icon: Icon(fixed ? Icons.lock_rounded : Icons.lock_open_rounded),
        ),
      ),
    );
  }
}

// ── validator-error affordance ──
// A danger alert icon whose hover / long-press tooltip carries the full error
// text. This is the ONLY way the box surfaces validation — never inline text
// under the control (matching the super_form_field rule).
class _ErrorBadge extends StatelessWidget {
  const _ErrorBadge({required this.error, required this.cs});

  final String error;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: error,
      preferBelow: false,
      waitDuration: const Duration(milliseconds: 120),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.error,
        borderRadius: BorderRadius.circular(
          AutoSuggestionsBoxThemeData.radiusMd,
        ),
      ),
      textStyle: TextStyle(
        fontFamily: (SuperMaterialThemeData.of(
          context,
        ).textTheme).bodyMedium?.fontFamily,
        fontSize: 12,
        height: 1.45,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(Icons.error_outline_rounded, size: 18, color: cs.error),
      ),
    );
  }
}

// ============================================================
// Advanced Search View (Ctrl/⌘+F)
// ------------------------------------------------------------
// A larger modal surface over the SAME controller: a big search field plus a
// tall results list. Reuses [_Row] so rows look identical to the inline overlay.
// Picking commits straight back into the field (single-select pops the dialog;
// multi-select keeps it open and toggles the set).
// ============================================================
class _AdvancedSearchDialog<T> extends StatefulWidget {
  final SuperAutoSuggestionsController<T> controller;
  final AutoSuggestionsBoxThemeData theme;
  final String title;
  final bool multiSelect;
  final AutoSuggestionMatch highlightMatch;
  final ValueChanged<T> onPick;
  const _AdvancedSearchDialog({
    required this.controller,
    required this.theme,
    required this.title,
    required this.multiSelect,
    required this.highlightMatch,
    required this.onPick,
  });

  @override
  State<_AdvancedSearchDialog<T>> createState() =>
      _AdvancedSearchDialogState<T>();
}

class _AdvancedSearchDialogState<T> extends State<_AdvancedSearchDialog<T>> {
  late final TextEditingController _text = widget.controller.text;
  final FocusNode _focus = FocusNode(debugLabel: 'AdvancedSearch');
  final ScrollController _scroll = ScrollController();

  SuperAutoSuggestionsController<T> get _c => widget.controller;

  @override
  void initState() {
    super.initState();
    _c.addListener(_onModel);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focus.requestFocus();
      _text.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _text.text.length,
      );
    });
  }

  void _onModel() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _c.removeListener(_onModel);
    _focus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  KeyEventResult _onKey(FocusNode n, KeyEvent e) {
    if (e is! KeyDownEvent && e is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    switch (e.logicalKey) {
      case LogicalKeyboardKey.arrowDown:
        _c.moveHighlight(1);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowUp:
        _c.moveHighlight(-1);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.enter:
      case LogicalKeyboardKey.numpadEnter:
        final h = _c.highlighted;
        final s = _c.highlightedSuggestion;
        if (h != null && s != null && s.enabled) widget.onPick(h);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.escape:
        Navigator.of(context).maybePop();
        return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    final results = _c.results;
    final q = _c.effectiveQuery;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640, maxHeight: 620),
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: t.overlayBg,
                borderRadius: BorderRadius.circular(
                  AutoSuggestionsBoxThemeData.radiusLg,
                ),
                border: Border.all(color: t.border),
                boxShadow: AutoSuggestionsBoxThemeData.overlayShadow,
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 14, 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ADVANCED SEARCH',
                                style: TextStyle(
                                  fontFamily: (SuperMaterialThemeData.of(
                                    context,
                                  ).textTheme).bodyMedium?.fontFamily,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.0,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                widget.title,
                                style: TextStyle(
                                  fontFamily: (SuperMaterialThemeData.of(
                                    context,
                                  ).textTheme).h1.fontFamily,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.4,
                                  color: t.fg1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _IconBtn(
                          icon: Icons.close_rounded,
                          color: t.fg3,
                          hoverColor: t.fg1,
                          onTap: () => Navigator.of(context).maybePop(),
                        ),
                      ],
                    ),
                  ),
                  // search field
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                    child: Focus(
                      onKeyEvent: _onKey,
                      child: Container(
                        height: 48,
                        padding: const EdgeInsetsDirectional.only(
                          start: 14,
                          end: 8,
                        ),
                        decoration: BoxDecoration(
                          color: t.fieldBg,
                          borderRadius: BorderRadius.circular(
                            AutoSuggestionsBoxThemeData.radiusMd,
                          ),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search_rounded, size: 19, color: t.fg3),
                            const SizedBox(width: 11),
                            Expanded(
                              child: TextField(
                                controller: _text,
                                focusNode: _focus,
                                onChanged: _c.setText,
                                style: TextStyle(
                                  fontFamily: (SuperMaterialThemeData.of(
                                    context,
                                  ).textTheme).bodyMedium?.fontFamily,
                                  fontSize: 15,
                                  color: t.fg1,
                                ),
                                cursorColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                decoration: InputDecoration(
                                  isCollapsed: true,
                                  border: InputBorder.none,
                                  hintText: 'Search…',
                                  hintStyle: TextStyle(
                                    fontSize: 15,
                                    color: t.fg3,
                                  ),
                                ),
                              ),
                            ),
                            if (_c.isLoading)
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_c.isLoadingMore)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      color: t.accentWash(0.06),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 13,
                            height: 13,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 9),
                          Text(
                            'Loading more from server…',
                            style: TextStyle(
                              fontFamily: (SuperMaterialThemeData.of(
                                context,
                              ).textTheme).bodyMedium?.fontFamily,
                              fontSize: 11.5,
                              color: t.fg2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Divider(height: 1, color: t.border),
                  // results
                  Flexible(
                    child: results.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 48),
                            child: Text(
                              _c.isLoading ? 'Searching…' : 'No matches',
                              style: TextStyle(
                                fontFamily: (SuperMaterialThemeData.of(
                                  context,
                                ).textTheme).bodyMedium?.fontFamily,
                                fontSize: 13,
                                color: t.fg3,
                              ),
                            ),
                          )
                        : Scrollbar(
                            controller: _scroll,
                            child: ListView.builder(
                              controller: _scroll,
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              itemCount: results.length,
                              itemBuilder: (ctx, i) {
                                final item = results[i];
                                final s = _c.suggestionAt(i);
                                return _Row<T>(
                                  theme: t,
                                  item: item,
                                  suggestion: s,
                                  query: q,
                                  highlighted: _c.isHighlighted(i),
                                  highlightMatch: widget.highlightMatch,
                                  highlightMatches: true,
                                  custom: null,
                                  multiSelect: widget.multiSelect,
                                  selected:
                                      widget.multiSelect &&
                                      _c.isSelectedValue(s.value),
                                  onTap: () => widget.onPick(item),
                                  onHover: () => _c.highlightAt(i),
                                );
                              },
                            ),
                          ),
                  ),
                  // footer hint
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: t.fieldBg,
                      border: Border(top: BorderSide(color: t.border)),
                    ),
                    child: Text(
                      '↑ ↓ TO NAVIGATE   ⏎ TO SELECT   ESC TO CLOSE',
                      style: TextStyle(
                        fontFamily: (SuperMaterialThemeData.of(
                          context,
                        ).textTheme).bodyMedium?.fontFamily,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: t.fg3,
                      ),
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
