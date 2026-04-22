import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ATHENA PREMIUM Color Palette — DigitalStore DZ
class AppColors {
  static const Color kLight      = Color(0xFFFFF9F5); // Crème très clair
  static const Color kPastelPink = Color(0xFFF5E6E0); // Beige rosé clair
  static const Color kPrimary    = Color(0xFFB08968); // Marron rosé
  static const Color kDark       = Color(0xFF8B4C4C); // Bordeaux moyen
  static const Color kDeepDark   = Color(0xFF5C2E2E); // Bordeaux foncé
  static const Color kBlueViolet = Color(0xFFD4A5A5); // Rose poudré
  static const Color kRoseMedium = Color(0xFFC08A8A); // Rose moyen

  // Gradients élégants
  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF5E6E0), Color(0xFFFFFFFF)], // Beige clair → Blanc
  );

  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8B4C4C), Color(0xFFB08968)], // Bordeaux → Marron rosé
  );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5C2E2E), Color(0xFF8B4C4C)], // Bordeaux foncé → Bordeaux moyen
  );

  // Glow shadow bordeaux
  static List<BoxShadow> glowShadow([double opacity = 0.25]) => [
    BoxShadow(
      color: Color(0xFF8B4C4C).withOpacity(opacity),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  // TEXT STYLES avec Poppins — TEXTE NOIR
  static TextStyle headingLarge({Color? color}) => GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: color ?? Color(0xFF000000), // NOIR
    letterSpacing: -0.5,
  );

  static TextStyle headingMedium({Color? color}) => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: color ?? Color(0xFF000000), // NOIR
  );

  static TextStyle bodyLarge({Color? color}) => GoogleFonts.poppins(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: color ?? Color(0xFF1A1A1A), // NOIR
  );

  static TextStyle bodyMedium({Color? color}) => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: color ?? Color(0xFF2C2C2C), // NOIR
  );

  static TextStyle labelSmall({Color? color}) => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: color ?? Color(0xFF424242), // Gris foncé
  );
}