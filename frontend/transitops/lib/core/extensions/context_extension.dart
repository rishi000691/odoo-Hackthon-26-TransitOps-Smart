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
