// ============================================================
// features/auto_suggestion_box/presentation/widgets/auto_suggestions_box_theme.dart
// ------------------------------------------------------------
// The box's own ThemeExtension, aligned with the core SuperTokensData / SuperTheme
// surfaces so the box drops into the same console as the table and tree.
// Instance fields swap dark <-> light (lerped); static consts re-expose the
// shared brand constants for terse local use.
//
//   ThemeData(extensions: [AutoSuggestionsBoxThemeData.light]);   // or .dark
//   final t = AutoSuggestionsBoxThemeData.of(context);            // -> .dark fallback
// ============================================================

import 'package:flutter/material.dart';

import 'package:super_core/super_core.dart';

/// Focused-state overrides for an [AutoSuggestionsBoxThemeData].
///
/// Every field is optional: a null field falls back to the theme's resting
/// token (so you can override just the fill, or just the border, and leave the
/// rest alone). Applied only while the field has focus.
///
/// ```dart
/// AutoSuggestionsBoxThemeData.dark.copyWith(
///   focusedStyle: const AutoSuggestionsBoxFocusedStyle(
///     fillColor: Color(0xFF23262C),
///     border: BorderSide(color: Color(0xFF4A7CFF), width: 1.6),
///     fontStyle: TextStyle(fontWeight: FontWeight.w600),
///   ),
/// );
/// ```
@immutable
class AutoSuggestionsBoxFocusedStyle {
  const AutoSuggestionsBoxFocusedStyle({
    this.fillColor,
    this.border,
    this.fontStyle,
    this.cursorColor,
    this.shadow,
  });

  /// Input fill painted while focused. Falls back to [AutoSuggestionsBoxThemeData.fieldBgFocus].
  final Color? fillColor;

  /// Field border (color + width) while focused. Falls back to a 1.4px
  /// [AutoSuggestionsBoxThemeData.borderFocus] side.
  final BorderSide? border;

  /// Merged onto the typed-value text style while focused (weight / color /
  /// letter-spacing…). Null leaves the resting text style untouched.
  final TextStyle? fontStyle;

  /// Caret color while focused. Falls back to the brand accent.
  final Color? cursorColor;

  /// Elevation halo painted behind the field while focused (e.g. a focus ring).
  final List<BoxShadow>? shadow;

  AutoSuggestionsBoxFocusedStyle copyWith({
    Color? fillColor,
    BorderSide? border,
    TextStyle? fontStyle,
    Color? cursorColor,
    List<BoxShadow>? shadow,
  }) =>
      AutoSuggestionsBoxFocusedStyle(
        fillColor: fillColor ?? this.fillColor,
        border: border ?? this.border,
        fontStyle: fontStyle ?? this.fontStyle,
        cursorColor: cursorColor ?? this.cursorColor,
        shadow: shadow ?? this.shadow,
      );

  static AutoSuggestionsBoxFocusedStyle? lerp(
      AutoSuggestionsBoxFocusedStyle? a, AutoSuggestionsBoxFocusedStyle? b, double t) {
    if (a == null && b == null) return null;
    return AutoSuggestionsBoxFocusedStyle(
      fillColor: Color.lerp(a?.fillColor, b?.fillColor, t),
      border: BorderSide.lerp(
        a?.border ?? BorderSide.none,
        b?.border ?? BorderSide.none,
        t,
      ),
      fontStyle: TextStyle.lerp(a?.fontStyle, b?.fontStyle, t),
      cursorColor: Color.lerp(a?.cursorColor, b?.cursorColor, t),
      shadow: BoxShadow.lerpList(a?.shadow, b?.shadow, t),
    );
  }
}

@immutable
class AutoSuggestionsBoxThemeData extends ThemeExtension<AutoSuggestionsBoxThemeData> {
  // ── swappable surfaces (dark <-> light) ──
  final Color fieldBg; //      input fill (resting)
  final Color fieldBgFocus; // input fill (focused)
  final Color overlayBg; //    dropdown panel fill
  final Color hover; //        hovered / highlighted row tint
  final Color border; //       resting field + panel border
  final Color borderFocus; //  focused field border
  final Color fg1; //          primary text (label, typed value)
  final Color fg2; //          secondary (description)
  final Color fg3; //          hint / leading icon
  final Color groupFg; //      group header text

  /// Focused-state visual overrides (fill / border / font / cursor / halo).
  final AutoSuggestionsBoxFocusedStyle focusedStyle;

  const AutoSuggestionsBoxThemeData({
    required this.fieldBg,
    required this.fieldBgFocus,
    required this.overlayBg,
    required this.hover,
    required this.border,
    required this.borderFocus,
    required this.fg1,
    required this.fg2,
    required this.fg3,
    required this.groupFg,
    this.focusedStyle = const AutoSuggestionsBoxFocusedStyle(),
  });

  // ── brand + semantic palette (const, re-exported from SuperTokensData) ──
  static const Color accent = SuperTokensData.defaultAccent;
  static const Color danger = SuperTokensData.defaultDanger;

  // ── typography ──
  static const String displayFont = SuperTokensData.defaultDisplayFont;
  static const String bodyFont = SuperTokensData.defaultBodyFont;

  // ── radii ──
  static const double radiusSm = 4;
  static const double radiusMd = 6;
  static const double radiusLg = 8;

  // ── metrics (aligned with super_form_field's field foundation) ──
  /// Comfortable field height (default density).
  static const double fieldHeight = 42;

  /// Compact field height (dense density).
  static const double fieldCompact = 36;

  /// Resting field border width (matches super_form_field's FieldBox).
  static const double fieldBorderWidth = 1.4;
  static const double rowHeight = 38;
  static const double overlayGap = 4; //   space between field and panel
  static const double overlayMaxWidth = 560;

  // ── motion ──
  static const Duration durFast = Duration(milliseconds: 110);
  static const Duration durBase = Duration(milliseconds: 160);
  static const Curve curveStandard = Cubic(0.4, 0, 0.2, 1);

  // ── elevation ──
  static const List<BoxShadow> overlayShadow = [
    BoxShadow(color: Color(0x2E0B1220), blurRadius: 24, spreadRadius: -4, offset: Offset(0, 12)),
    BoxShadow(color: Color(0x140B1220), blurRadius: 6, spreadRadius: -2, offset: Offset(0, 2)),
  ];

  // ── presets ──
  static const AutoSuggestionsBoxThemeData dark = AutoSuggestionsBoxThemeData(
    fieldBg: Color(0xFF1E2025),
    fieldBgFocus: Color(0xFF23262C),
    overlayBg: Color(0xFF202329),
    hover: Color(0xFF2C313B),
    border: Color(0xFF3A3D47),
    borderFocus: accent,
    fg1: Color(0xFFE6E7EE),
    fg2: Color(0xFF9DA1B0),
    fg3: Color(0xFF6E7280),
    groupFg: Color(0xFF7E8290),
    focusedStyle: AutoSuggestionsBoxFocusedStyle(
      fillColor: Color(0xFF23262C),
      border: BorderSide(color: accent, width: fieldBorderWidth),
    ),
  );

  static const AutoSuggestionsBoxThemeData light = AutoSuggestionsBoxThemeData(
    fieldBg: Color(0xFFFFFFFF),
    fieldBgFocus: Color(0xFFFFFFFF),
    overlayBg: Color(0xFFFFFFFF),
    hover: Color(0xFFEFF3FF),
    border: Color(0xFFC2C6D6),
    borderFocus: accent,
    fg1: Color(0xFF0F172A),
    fg2: Color(0xFF64748B),
    fg3: Color(0xFF94A0B4),
    groupFg: Color(0xFF8A92A4),
    focusedStyle: AutoSuggestionsBoxFocusedStyle(
      fillColor: Color(0xFFFFFFFF),
      border: BorderSide(color: accent, width: fieldBorderWidth),
    ),
  );

  /// Derives an [AutoSuggestionsBoxThemeData] from a Material [ColorScheme].
  ///
  /// Called automatically by [of] when no explicit extension is registered,
  /// enabling seamless use with [SuperMaterialThemeData]:
  ///
  /// ```dart
  /// MaterialApp(
  ///   theme:     SuperMaterialThemeData.light(palette: SuperPalette.bluePalette),
  ///   darkTheme: SuperMaterialThemeData.dark(palette: SuperPalette.bluePalette),
  ///   // AutoSuggestionsBox adapts automatically — no extra registration needed.
  /// );
  /// ```
  factory AutoSuggestionsBoxThemeData.fromColorScheme(ColorScheme cs) {
    final isDark = cs.brightness == Brightness.dark;
    final primary = cs.primary;
    final focBorder = BorderSide(color: primary, width: fieldBorderWidth);
    return AutoSuggestionsBoxThemeData(
      fieldBg:       isDark ? const Color(0xFF1E2025) : cs.surface,
      fieldBgFocus:  isDark ? const Color(0xFF23262C) : cs.surface,
      overlayBg:     isDark ? const Color(0xFF202329) : cs.surface,
      hover:         isDark ? const Color(0xFF2C313B) : cs.surfaceContainerHighest,
      border:        isDark ? const Color(0xFF3A3D47) : cs.outline,
      borderFocus:   primary,
      fg1:           cs.onSurface,
      fg2:           cs.onSurfaceVariant,
      fg3:           isDark ? const Color(0xFF6E7280) : cs.onSurfaceVariant,
      groupFg:       isDark ? const Color(0xFF7E8290) : cs.onSurfaceVariant,
      focusedStyle:  AutoSuggestionsBoxFocusedStyle(
        fillColor: isDark ? const Color(0xFF23262C) : cs.surface,
        border: focBorder,
        cursorColor: primary,
      ),
    );
  }

  /// Derives an [AutoSuggestionsBoxThemeData] from a [SuperMaterialThemeData].
  ///
  /// Preferred bridge (v0.8.0): reads palette-, brightness- and device-mode-
  /// aware tokens from `theme.superTheme` so the box stays in lock-step with the
  /// rest of the toolkit instead of duplicating hard-coded hex. Explicit
  /// extensions still win in [of].
  factory AutoSuggestionsBoxThemeData.fromMaterialTheme(
      SuperMaterialThemeData theme) {
    final s = theme.superTheme;
    final primary = theme.colorScheme.primary;
    final focBorder = BorderSide(color: primary, width: fieldBorderWidth);
    return AutoSuggestionsBoxThemeData(
      fieldBg: s.inputBg,
      fieldBgFocus: s.surface,
      overlayBg: s.surface,
      hover: s.hover,
      border: s.border,
      borderFocus: primary,
      fg1: s.fg1,
      fg2: s.fg2,
      fg3: s.fg3,
      groupFg: s.fg3,
      focusedStyle: AutoSuggestionsBoxFocusedStyle(
        fillColor: s.surface,
        border: focBorder,
        cursorColor: primary,
      ),
    );
  }

  /// Reads the registered [ThemeExtension], or bridges from the current
  /// Material [ColorScheme] (enables [SuperMaterialThemeData] compatibility),
  /// or falls back to [dark] when no Material theme is available.
  static AutoSuggestionsBoxThemeData of(BuildContext context) {
    final ext = Theme.of(context).extension<AutoSuggestionsBoxThemeData>();
    if (ext != null) return ext;
    final superTheme = SuperMaterialThemeData.maybeOf(context);
    if (superTheme != null) {
      return AutoSuggestionsBoxThemeData.fromMaterialTheme(superTheme);
    }
    return AutoSuggestionsBoxThemeData.fromColorScheme(
        Theme.of(context).colorScheme);
  }

  /// A tint of the accent over the overlay surface (selected-row fill).
  Color accentWash([double pct = 0.12]) => Color.alphaBlend(accent.withOpacity(pct), overlayBg);

  @override
  AutoSuggestionsBoxThemeData copyWith({
    Color? fieldBg,
    Color? fieldBgFocus,
    Color? overlayBg,
    Color? hover,
    Color? border,
    Color? borderFocus,
    Color? fg1,
    Color? fg2,
    Color? fg3,
    Color? groupFg,
    AutoSuggestionsBoxFocusedStyle? focusedStyle,
  }) =>
      AutoSuggestionsBoxThemeData(
        fieldBg: fieldBg ?? this.fieldBg,
        fieldBgFocus: fieldBgFocus ?? this.fieldBgFocus,
        overlayBg: overlayBg ?? this.overlayBg,
        hover: hover ?? this.hover,
        border: border ?? this.border,
        borderFocus: borderFocus ?? this.borderFocus,
        fg1: fg1 ?? this.fg1,
        fg2: fg2 ?? this.fg2,
        fg3: fg3 ?? this.fg3,
        groupFg: groupFg ?? this.groupFg,
        focusedStyle: focusedStyle ?? this.focusedStyle,
      );

  @override
  AutoSuggestionsBoxThemeData lerp(ThemeExtension<AutoSuggestionsBoxThemeData>? other, double t) {
    if (other is! AutoSuggestionsBoxThemeData) return this;
    return AutoSuggestionsBoxThemeData(
      fieldBg: Color.lerp(fieldBg, other.fieldBg, t)!,
      fieldBgFocus: Color.lerp(fieldBgFocus, other.fieldBgFocus, t)!,
      overlayBg: Color.lerp(overlayBg, other.overlayBg, t)!,
      hover: Color.lerp(hover, other.hover, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderFocus: Color.lerp(borderFocus, other.borderFocus, t)!,
      fg1: Color.lerp(fg1, other.fg1, t)!,
      fg2: Color.lerp(fg2, other.fg2, t)!,
      fg3: Color.lerp(fg3, other.fg3, t)!,
      groupFg: Color.lerp(groupFg, other.groupFg, t)!,
      focusedStyle: AutoSuggestionsBoxFocusedStyle.lerp(focusedStyle, other.focusedStyle, t) ??
          focusedStyle,
    );
  }
}
