// ============================================================
// features/auto_suggestion_box/domain/entities/super_auto_suggestions_item.dart
// ------------------------------------------------------------
// The pure data the box renders. A [SuperAutoSuggestionsItem] is one row — a typed
// [value] plus the [titleText] shown and matched against. [HighlightSpan] is a
// `[start, end)` slice of a titleText that matched a query, used by the view to
// bold the hit. No I/O, no Flutter framework beyond IconData (a UI affordance
// intrinsic to the row).
// ============================================================

import 'package:flutter/widgets.dart' show IconData, Widget, immutable;

/// Builds the render/search metadata for [element] at [index] inside [items].
///
/// Public APIs accept raw `T` values; the package calls this builder whenever
/// it needs the [SuperAutoSuggestionsItem] representation for filtering,
/// display, selection, grouping, or value resolution.
typedef AutoSuggestionBuilder<T> =
    SuperAutoSuggestionsItem<T> Function(List<T> items, int index, T element);

/// One suggestion row. [value] is what the host receives on select;
/// [titleText] is the text shown and matched against.
@immutable
class SuperAutoSuggestionsItem<T> {
  final T value;

  /// Plain-text title used for display, matching, and field completion.
  final String? titleText;

  /// Custom title content supplied by [SuperAutoSuggestionsItem.build].
  final Widget? title;

  /// Optional plain-text supporting content.
  final String? descriptionText;

  /// Optional custom supporting content.
  final Widget? description;

  /// Optional plain-text trailing metadata.
  final String? trailingText;

  /// Optional custom trailing content.
  final Widget? trailing;

  /// Optional leading glyph data.
  final IconData? iconData;

  /// Optional custom leading content.
  final Widget? icon;

  final String? group;
  final List<String> keywords;
  final bool enabled;

  /// Creates a suggestion row from strings and optional icon data.
  const SuperAutoSuggestionsItem({
    required this.value,
    required this.titleText,
    this.descriptionText,
    this.trailingText,
    this.iconData,
    this.group,
    this.keywords = const [],
    this.enabled = true,
  }) : title = null,
       description = null,
       trailing = null,
       icon = null;

  /// Creates a suggestion row from custom widgets.
  const SuperAutoSuggestionsItem.build({
    required this.value,
    required this.title,
    this.description,
    this.trailing,
    this.icon,
    this.group,
    this.keywords = const [],
    this.enabled = true,
  }) : titleText = null,
       descriptionText = null,
       trailingText = null,
       iconData = null;

  /// Text used by search, completion, and the editable field.
  ///
  /// Widget-built rows fall back to the raw value because arbitrary widgets do
  /// not expose searchable text.
  String get displayText => titleText ?? value.toString();

  String get haystack => ([displayText, ...keywords]).join(' ').toLowerCase();

  SuperAutoSuggestionsItem<T> copyWith({
    T? value,
    String? titleText,
    String? descriptionText,
    String? trailingText,
    IconData? iconData,
    Widget? title,
    Widget? description,
    Widget? trailing,
    Widget? icon,
    String? group,
    List<String>? keywords,
    bool? enabled,
  }) {
    if (this.title != null) {
      return SuperAutoSuggestionsItem<T>.build(
        value: value ?? this.value,
        title: title ?? this.title!,
        description: description ?? this.description,
        trailing: trailing ?? this.trailing,
        icon: icon ?? this.icon,
        group: group ?? this.group,
        keywords: keywords ?? this.keywords,
        enabled: enabled ?? this.enabled,
      );
    }
    return SuperAutoSuggestionsItem<T>(
      value: value ?? this.value,
      titleText: titleText ?? this.titleText!,
      descriptionText: descriptionText ?? this.descriptionText,
      trailingText: trailingText ?? this.trailingText,
      iconData: iconData ?? this.iconData,
      group: group ?? this.group,
      keywords: keywords ?? this.keywords,
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is SuperAutoSuggestionsItem<T> &&
      other.value == value &&
      other.displayText == displayText;

  @override
  int get hashCode => Object.hash(value, displayText);
}

/// Deprecated name for [SuperAutoSuggestionsItem].
@Deprecated('Use SuperAutoSuggestionsItem instead.')
typedef AutoSuggestions<T> = SuperAutoSuggestionsItem<T>;

/// Deprecated singular name retained for compatibility with versions through
/// 1.0.0.
@Deprecated('Use SuperAutoSuggestionsItem instead.')
typedef AutoSuggestion<T> = SuperAutoSuggestionsItem<T>;

/// A `[start, end)` slice of title text that matched the query.
@immutable
class HighlightSpan {
  final int start;
  final int end;
  const HighlightSpan(this.start, this.end);
}
