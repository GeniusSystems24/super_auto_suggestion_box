// ============================================================
// features/auto_suggestion_box/domain/entities/super_auto_suggestions_item.dart
// ------------------------------------------------------------
// The render/search metadata for one raw suggestion value.
// ============================================================

import 'dart:async' show Stream;

import 'package:flutter/widgets.dart' show IconData, Widget, immutable;

/// Builds the render/search metadata for [element] at [index] inside [items].
///
/// Public APIs accept raw `T` values; the package calls this builder whenever
/// it needs the [SuperAutoSuggestionsItem] representation for filtering,
/// display, selection, grouping, or value resolution.
typedef AutoSuggestionBuilder<T> =
    SuperAutoSuggestionsItem<T> Function(List<T> items, int index, T element);

/// One suggestion row.
///
/// [value] is the raw value returned to the host. [titleText] remains the
/// searchable, display, and field-completion title when provided. Supporting content can be
/// supplied either as plain metadata ([descriptionText], [trailingText],
/// [iconData]) or as custom widgets ([description], [trailing], [icon]).
@immutable
class SuperAutoSuggestionsItem<T> {
  final T value;

  /// Plain-text title used for display, matching, and field completion.
  final String? titleText;

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

  /// Optional stream associated with the enabled state.
  ///
  /// Each event represents the current enabled state for the suggestion.
  final Stream<bool>? enabledSnapshot;

  /// Creates render/search metadata for one suggestion.
  ///
  /// [titleText] remains the canonical searchable/committed title. For
  /// supporting UI, custom [description], [trailing], and [icon] widgets can be
  /// supplied directly without using a separate named constructor.
  const SuperAutoSuggestionsItem({
    required this.value,
    required this.titleText,
    this.descriptionText,
    this.description,
    this.trailingText,
    this.trailing,
    this.iconData,
    this.icon,
    this.group,
    this.keywords = const [],
    this.enabled = true,
    this.enabledSnapshot,
  });

  /// Text used by search, completion, and the editable field.
  String get displayText => titleText ?? value.toString();

  String get haystack => ([displayText, ...keywords]).join(' ').toLowerCase();

  SuperAutoSuggestionsItem<T> copyWith({
    T? value,
    String? titleText,
    String? descriptionText,
    Widget? description,
    String? trailingText,
    Widget? trailing,
    IconData? iconData,
    Widget? icon,
    String? group,
    List<String>? keywords,
    bool? enabled,
    Stream<bool>? enabledSnapshot,
  }) {
    return SuperAutoSuggestionsItem<T>(
      value: value ?? this.value,
      titleText: titleText ?? this.titleText,
      descriptionText: descriptionText ?? this.descriptionText,
      description: description ?? this.description,
      trailingText: trailingText ?? this.trailingText,
      trailing: trailing ?? this.trailing,
      iconData: iconData ?? this.iconData,
      icon: icon ?? this.icon,
      group: group ?? this.group,
      keywords: keywords ?? this.keywords,
      enabled: enabled ?? this.enabled,
      enabledSnapshot: enabledSnapshot ?? this.enabledSnapshot,
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
