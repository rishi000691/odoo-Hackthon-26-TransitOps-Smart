import 'package:flutter/material.dart';

extension ContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;

  double get width => MediaQuery.of(this).size.width;
  double get height => MediaQuery.of(this).size.height;

  // ─── Breakpoints ───────────────────────────────────────────────────────────
  /// < 640 px  – phone portrait / compact
  bool get isMobile => width < 640;

  /// 640 – 1023 px – tablet / large phone landscape
  bool get isTablet => width >= 640 && width < 1024;

  /// ≥ 1024 px – desktop / web
  bool get isDesktop => width >= 1024;

  /// True when there is enough horizontal space to show a side panel
  bool get showSidePanel => isDesktop;

  // ─── Responsive helpers ────────────────────────────────────────────────────
  /// Horizontal page padding: 16 mobile → 32 tablet → 48 desktop
  double get pagePaddingH {
    if (isDesktop) return 48;
    if (isTablet) return 32;
    return 16;
  }

  /// Number of stat-grid columns: 2 mobile → 2 tablet → 4 desktop
  int get statGridColumns {
    if (isDesktop) return 4;
    return 2;
  }

  /// Max form card width for auth screens
  double get authCardWidth {
    if (isDesktop) return 460;
    if (isTablet) return 520;
    return double.infinity;
  }

  /// Returns T based on breakpoint
  T responsive<T>({required T mobile, T? tablet, required T desktop}) {
    if (isDesktop) return desktop;
    if (isTablet) return tablet ?? mobile;
    return mobile;
  }
}

// ─── Theme-aware design tokens ────────────────────────────────────────────────
/// Provides the same six surface/text tokens used by every screen in the app,
/// but resolved from the active [ThemeData] brightness so the dark/light
/// toggle works app-wide.
///
/// Dark values intentionally match the hardcoded constants that already exist
/// in each screen file (0xFF090D16, etc.) so dark mode is pixel-identical.
/// Light values use the app's neutral palette for a clean, readable light UI.
extension AppThemeTokens on BuildContext {
  bool get _isDark => Theme.of(this).brightness == Brightness.dark;

  /// Page / scaffold background.
  Color get kBg =>
      _isDark ? const Color(0xFF090D16) : const Color(0xFFF7F7F7);

  /// Card / panel surface (one layer above bg).
  Color get kSurface =>
      _isDark ? const Color(0xFF111827) : const Color(0xFFFFFFFF);

  /// Raised surface (hover states, nested cards).
  Color get kSurfaceRaised =>
      _isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E5E5);

  /// Primary text — high contrast.
  Color get kTextPrimary =>
      _isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1A1A1A);

  /// Secondary / muted text.
  Color get kTextSecondary =>
      _isDark ? const Color(0xFF94A3B8) : const Color(0xFF7A7A7A);

  /// Divider / border lines.
  Color get kBorder =>
      _isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E5E5);
}
