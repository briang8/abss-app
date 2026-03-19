// lib/theme/app_theme.dart
//
// ══════════════════════════════════════════════════════════════════════════════
// ABSS DESIGN SYSTEM
// App: Alerts by Stay Safe
// ══════════════════════════════════════════════════════════════════════════════
//
// COLOUR USAGE RULES
// ──────────────────
// • Always use the context-aware getters (AppColors.background(ctx)) in widgets.
//   They return the correct light or dark value automatically.
// • Use the named palette constants (AppColors.primary, AppColors.critical, etc.)
//   for brand / severity colours — these are the same in both themes.
// • Use AppColors.lightXxx / AppColors.darkXxx only when you are explicitly
//   building a ThemeData (in AppTheme.light / AppTheme.dark).
//
// TEXT STYLE USAGE RULES
// ──────────────────────
// • All AppText methods take a BuildContext so they can resolve the correct
//   text colour for the active theme.
// • Pass null only in places where you have no context (e.g. ThemeData styles).
// • AppText.button is context-free because buttons always render white text.
//
// ══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppColors
// ─────────────────────────────────────────────────────────────────────────────
class AppColors {
  AppColors._();

  // ── Brand / severity — identical in both themes ───────────────────────────
  static const primary      = Color(0xFF16A34A);
  static const primaryDim   = Color(0xFF14532D);
  static const primaryGlow  = Color(0x3316A34A);

  static const info         = Color(0xFF0284C7);
  static const infoDim      = Color(0xFF075985);
  static const infoGlow     = Color(0x330284C7);

  static const critical     = Color(0xFFDC2626);
  static const criticalDim  = Color(0xFF7F1D1D);
  static const criticalGlow = Color(0x33DC2626);

  static const high         = Color(0xFFEA580C);
  static const highDim      = Color(0xFF7C2D12);
  static const highGlow     = Color(0x33EA580C);

  static const moderate     = Color(0xFFCA8A04);
  static const moderateDim  = Color(0xFF78350F);
  static const moderateGlow = Color(0x33CA8A04);

  static const low          = Color(0xFF16A34A);

  static const voice        = Color(0xFF7C3AED);
  static const voiceGlow    = Color(0x337C3AED);

  // ── Light palette ─────────────────────────────────────────────────────────
  static const lightBg            = Color(0xFFF8FAFC);
  static const lightSurface       = Color(0xFFFFFFFF);
  static const lightCard          = Color(0xFFFFFFFF);
  static const lightCardAlt       = Color(0xFFF1F5F9);
  static const lightBorder        = Color(0xFFE2E8F0);
  static const lightBorderLight   = Color(0xFFCBD5E1);
  static const lightTextPrimary   = Color(0xFF0F172A);
  static const lightTextSecondary = Color(0xFF475569);
  static const lightTextMuted     = Color(0xFF94A3B8);
  static const lightTextDisabled  = Color(0xFFCBD5E1);

  // ── Dark palette ──────────────────────────────────────────────────────────
  static const darkBg             = Color(0xFF080C18);
  static const darkSurface        = Color(0xFF0F1628);
  static const darkCard           = Color(0xFF151D35);
  static const darkCardAlt        = Color(0xFF1A2340);
  static const darkBorder         = Color(0xFF1E2A45);
  static const darkBorderLight    = Color(0xFF243050);
  static const darkTextPrimary    = Color(0xFFEEF2FF);
  static const darkTextSecondary  = Color(0xFF94A3B8);
  static const darkTextMuted      = Color(0xFF475569);
  static const darkTextDisabled   = Color(0xFF334155);

  // ── Context-aware getters — USE THESE IN ALL WIDGET CODE ─────────────────
  static Color background   (BuildContext ctx) => _isDark(ctx) ? darkBg             : lightBg;
  static Color surface      (BuildContext ctx) => _isDark(ctx) ? darkSurface        : lightSurface;
  static Color card         (BuildContext ctx) => _isDark(ctx) ? darkCard           : lightCard;
  static Color cardAlt      (BuildContext ctx) => _isDark(ctx) ? darkCardAlt        : lightCardAlt;
  static Color border       (BuildContext ctx) => _isDark(ctx) ? darkBorder         : lightBorder;
  static Color borderLight  (BuildContext ctx) => _isDark(ctx) ? darkBorderLight    : lightBorderLight;
  static Color textPrimary  (BuildContext ctx) => _isDark(ctx) ? darkTextPrimary    : lightTextPrimary;
  static Color textSecondary(BuildContext ctx) => _isDark(ctx) ? darkTextSecondary  : lightTextSecondary;
  static Color textMuted    (BuildContext ctx) => _isDark(ctx) ? darkTextMuted      : lightTextMuted;
  static Color textDisabled (BuildContext ctx) => _isDark(ctx) ? darkTextDisabled   : lightTextDisabled;

  static bool _isDark(BuildContext ctx) => Theme.of(ctx).brightness == Brightness.dark;
}

// ─────────────────────────────────────────────────────────────────────────────
// SeverityStyle & AppSeverity
// ─────────────────────────────────────────────────────────────────────────────
class SeverityStyle {
  final Color color;
  final Color dimColor;
  final Color glowColor;
  final String label;

  const SeverityStyle({
    required this.color,
    required this.dimColor,
    required this.glowColor,
    required this.label,
  });
}

class AppSeverity {
  AppSeverity._();

  static const critical = SeverityStyle(
    color: AppColors.critical, dimColor: AppColors.criticalDim,
    glowColor: AppColors.criticalGlow, label: 'CRITICAL',
  );
  static const high = SeverityStyle(
    color: AppColors.high, dimColor: AppColors.highDim,
    glowColor: AppColors.highGlow, label: 'HIGH',
  );
  static const moderate = SeverityStyle(
    color: AppColors.moderate, dimColor: AppColors.moderateDim,
    glowColor: AppColors.moderateGlow, label: 'MODERATE',
  );
  static const low = SeverityStyle(
    color: AppColors.low, dimColor: AppColors.primaryDim,
    glowColor: AppColors.primaryGlow, label: 'LOW',
  );

  static SeverityStyle fromString(String s) => switch (s) {
    'critical' => critical,
    'high'     => high,
    'moderate' => moderate,
    _          => low,
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// AppText
//
// All methods accept BuildContext? (nullable).
// Pass a real context in widget code so colours resolve to the active theme.
// Pass null only in ThemeData definitions where no context is available.
// ─────────────────────────────────────────────────────────────────────────────
class AppText {
  AppText._();

  static Color _primary  (BuildContext? ctx) => ctx != null ? AppColors.textPrimary(ctx)   : AppColors.darkTextPrimary;
  static Color _secondary(BuildContext? ctx) => ctx != null ? AppColors.textSecondary(ctx) : AppColors.darkTextSecondary;
  static Color _muted    (BuildContext? ctx) => ctx != null ? AppColors.textMuted(ctx)      : AppColors.darkTextMuted;

  static TextStyle display(BuildContext? ctx) => GoogleFonts.dmSans(
    fontSize: 62, fontWeight: FontWeight.w800,
    letterSpacing: -2, height: 1,
    color: _primary(ctx),
  );

  static TextStyle h1(BuildContext? ctx) => GoogleFonts.dmSans(
    fontSize: 30, fontWeight: FontWeight.w800,
    letterSpacing: -0.8,
    color: _primary(ctx),
  );

  static TextStyle h2(BuildContext? ctx) => GoogleFonts.dmSans(
    fontSize: 22, fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
    color: _primary(ctx),
  );

  static TextStyle h3(BuildContext? ctx) => GoogleFonts.dmSans(
    fontSize: 17, fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    color: _primary(ctx),
  );

  static TextStyle h4(BuildContext? ctx) => GoogleFonts.dmSans(
    fontSize: 15, fontWeight: FontWeight.w600,
    color: _primary(ctx),
  );

  static TextStyle body(BuildContext? ctx) => GoogleFonts.dmSans(
    fontSize: 14, fontWeight: FontWeight.w400,
    height: 1.6,
    color: _secondary(ctx),
  );

  static TextStyle bodyMedium(BuildContext? ctx) => GoogleFonts.dmSans(
    fontSize: 14, fontWeight: FontWeight.w500,
    color: _primary(ctx),
  );

  static TextStyle caption(BuildContext? ctx) => GoogleFonts.dmSans(
    fontSize: 12, fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    color: _muted(ctx),
  );

  static TextStyle label(BuildContext? ctx) => GoogleFonts.dmSans(
    fontSize: 11, fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
    color: _muted(ctx),
  );

  // Context-free — buttons always display white text regardless of theme.
  static TextStyle get button => GoogleFonts.dmSans(
    fontSize: 15, fontWeight: FontWeight.w600,
    letterSpacing: 0.2, color: Colors.white,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// AppTheme  —  light (default) and dark ThemeData
// ─────────────────────────────────────────────────────────────────────────────
class AppTheme {
  AppTheme._();

  // Light — the default. Optimised for outdoor use in bright sunlight.
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBg,
    colorScheme: const ColorScheme.light(
      surface:   AppColors.lightSurface,
      primary:   AppColors.primary,
      secondary: AppColors.info,
      error:     AppColors.critical,
      onSurface: AppColors.lightTextPrimary,
      onPrimary: Colors.white,
    ),
    textTheme: GoogleFonts.dmSansTextTheme(ThemeData.light().textTheme).apply(
      bodyColor:    AppColors.lightTextPrimary,
      displayColor: AppColors.lightTextPrimary,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor:     AppColors.lightBg,
      elevation:           0,
      scrolledUnderElevation: 0,
      systemOverlayStyle:  SystemUiOverlayStyle.dark,
      titleTextStyle:      AppText.h3(null).copyWith(color: AppColors.lightTextPrimary),
      iconTheme:           const IconThemeData(color: AppColors.lightTextPrimary),
    ),
    cardTheme: CardThemeData(
      color:     AppColors.lightCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.lightBorder),
      ),
      margin: EdgeInsets.zero,
    ),
    dividerColor: AppColors.lightBorder,
    inputDecorationTheme: const InputDecorationTheme(
      hintStyle: TextStyle(color: AppColors.lightTextMuted),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? AppColors.primary : AppColors.lightTextMuted,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? AppColors.primary.withValues(alpha: 0.3)
            : AppColors.lightBorder,
      ),
    ),
  );

  // Dark
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBg,
    colorScheme: const ColorScheme.dark(
      surface:   AppColors.darkSurface,
      primary:   AppColors.primary,
      secondary: AppColors.info,
      error:     AppColors.critical,
      onSurface: AppColors.darkTextPrimary,
      onPrimary: Colors.white,
    ),
    textTheme: GoogleFonts.dmSansTextTheme(ThemeData.dark().textTheme).apply(
      bodyColor:    AppColors.darkTextPrimary,
      displayColor: AppColors.darkTextPrimary,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor:     AppColors.darkBg,
      elevation:           0,
      scrolledUnderElevation: 0,
      systemOverlayStyle:  SystemUiOverlayStyle.light,
      titleTextStyle:      AppText.h3(null).copyWith(color: AppColors.darkTextPrimary),
      iconTheme:           const IconThemeData(color: AppColors.darkTextPrimary),
    ),
    cardTheme: CardThemeData(
      color:     AppColors.darkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.darkBorder),
      ),
      margin: EdgeInsets.zero,
    ),
    dividerColor: AppColors.darkBorder,
    inputDecorationTheme: const InputDecorationTheme(
      hintStyle: TextStyle(color: AppColors.darkTextMuted),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? AppColors.primary : AppColors.darkTextMuted,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? AppColors.primary.withValues(alpha: 0.3)
            : AppColors.darkBorder,
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// AppDecorations — context-aware BoxDecoration helpers
// ─────────────────────────────────────────────────────────────────────────────
class AppDecorations {
  AppDecorations._();

  static BoxDecoration card(
    BuildContext ctx, {
    Color? borderColor,
    BorderRadius? radius,
  }) => BoxDecoration(
    color:        AppColors.card(ctx),
    borderRadius: radius ?? BorderRadius.circular(16),
    border:       Border.all(color: borderColor ?? AppColors.border(ctx)),
  );

  static BoxDecoration glowCard(Color glowColor) => BoxDecoration(
    color:        glowColor.withValues(alpha: 0.08),
    borderRadius: BorderRadius.circular(16),
    border:       Border.all(color: glowColor.withValues(alpha: 0.25)),
  );

  static BoxDecoration heroWeather(BuildContext ctx) {
    final isDark = Theme.of(ctx).brightness == Brightness.dark;
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end:   Alignment.bottomRight,
        colors: isDark
            ? const [Color(0x330284C7), Color(0x1A16A34A)]
            : const [Color(0xFFE0F2FE), Color(0xFFDCFCE7)],
      ),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: isDark ? const Color(0x330284C7) : const Color(0xFFBAE6FD),
      ),
    );
  }
}
