import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// TransitOps type scale, built on Outfit per architect.flutter.md §5.
///
/// NOTE: the Relume style guide (Concept 2) suggested Corben (heading) /
/// Lora (body) — a serif pairing that conflicts with the spec's Outfit
/// requirement. This file keeps Outfit since that's the documented
/// architecture decision. If the team decides to intentionally override
/// the spec, swap GoogleFonts.outfitTextTheme() below for
/// GoogleFonts.corbenTextTheme() (headings) / GoogleFonts.loraTextTheme()
/// (body) — but update architect.flutter.md too so Hari and the rest of
/// the team aren't out of sync on which font is canonical.
class AppTextTheme {
  AppTextTheme._();

  static TextTheme get textTheme => GoogleFonts.outfitTextTheme(
    const TextTheme(
      displayLarge: TextStyle(fontSize: 40, fontWeight: FontWeight.w700),
      displayMedium: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
      headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
    ),
  );
}
