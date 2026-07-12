// premium_card.dart
import 'package:flutter/material.dart';

/// A reusable "premium SaaS dashboard" card — subtle gradient surface,
/// fine-grain 1px border, and a soft low-opacity shadow instead of the
/// harsh default Material elevation. Colors are always pulled from the
/// current Theme, so it adapts automatically between light and dark mode.
class PremiumCard extends StatelessWidget {
  const PremiumCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Two close shades of the surface color for a subtle gradient — in
    // dark mode we lighten slightly toward white; in light mode we shade
    // slightly toward black, so the effect stays subtle either way.
    final Color surfaceStart = isDark
        ? Color.alphaBlend(Colors.white.withValues(alpha: 0.04), colorScheme.surface)
        : Color.alphaBlend(Colors.white.withValues(alpha: 0.6), colorScheme.surface);
    final Color surfaceEnd = isDark
        ? Color.alphaBlend(Colors.black.withValues(alpha: 0.12), colorScheme.surface)
        : Color.alphaBlend(Colors.black.withValues(alpha: 0.02), colorScheme.surface);

    // Fine-grain border: a hair lighter than the background in dark mode,
    // a hair darker in light mode — just enough to separate the card from
    // its background without reading as a hard outline.
    final Color borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : colorScheme.onSurface.withValues(alpha: 0.08);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [surfaceStart, surfaceEnd],
        ),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : colorScheme.shadow)
                .withValues(alpha: isDark ? 0.35 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: child,
    );
  }
}
