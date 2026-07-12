import 'package:flutter/material.dart';

/// TransitOps brand + semantic color tokens.
/// Source: Relume "Concept 2" style guide (Colors panel).
class AppColors {
  AppColors._();

  // ── Brand ─────────────────────────────────────────────
  /// Nile Blue — primary/main brand color (Relume "Main").
  static const Color primary = Color(0xFF1B3A4B);

  /// Roman — locked accent, used for primary CTAs (Dispatch, Login, etc).
  /// NOTE: same hex as [statusRetiredSuspended] below. If a red CTA button
  /// and a "Suspended" chip land on the same screen, that overlap could
  /// read as ambiguous — raise it with the team before Milestone 4 polish
  /// if it becomes a real issue, rather than silently changing one here.
  static const Color accent = Color(0xFFD94F4F);

  /// Wine Berry — secondary accent. Not tied to any status value in the
  /// spec; reserved for chart series, selected-nav-item indicators, or
  /// other one-off highlights.
  static const Color secondaryAccent = Color(0xFF4A1D43);

  // ── Neutrals (light → dark ramp) ─────────────────────
  // Relume's neutral swatches didn't expose hex values at screenshot
  // resolution — these are a standard clean gray ramp. Click each neutral
  // swatch in Relume individually if you want pixel-exact values instead.
  static const Color neutral50 = Color(0xFFF7F7F7);
  static const Color neutral100 = Color(0xFFE5E5E5);
  static const Color neutral300 = Color(0xFFB0B0B0);
  static const Color neutral500 = Color(0xFF7A7A7A);
  static const Color neutral700 = Color(0xFF4A4A4A);
  static const Color neutral900 = Color(0xFF1A1A1A);

  // ── Semantic status colors ────────────────────────────
  // Maps to Vehicle.status / Driver.status values in the ER diagram
  // (architect.node.md) and the Available/On Trip/In Shop/Retired mapping
  // specified for Task 1.

  /// Available — Jungle (teal-green).
  static const Color statusAvailable = Color(0xFF2A9D8F);

  /// On Trip — derived mid-blue. Relume's concept didn't include a
  /// dedicated blue swatch, so this is a lightened/desaturated tint of
  /// primary Nile Blue, chosen to read as a distinct status color rather
  /// than duplicating the brand primary.
  static const Color statusOnTrip = Color(0xFF3E7CA6);

  /// In Shop — Fire Bush (amber/orange).
  static const Color statusInShop = Color(0xFFE8913A);

  /// Retired / Suspended — Roman (red). Same hex as [accent] — see note
  /// above.
  static const Color statusRetiredSuspended = Color(0xFFD94F4F);
}
