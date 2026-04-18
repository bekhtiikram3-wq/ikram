import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// MOON Color Palette — DigitalStore DZ
class AppColors {
  static const Color kLight      = Color(0xFFF5D5E0); // Rose pâle
  static const Color kBlueViolet = Color(0xFF6667AB); // Bleu-violet
  static const Color kPrimary    = Color(0xFF7B337E); // Violet moyen
  static const Color kDark       = Color(0xFF420D4B); // Violet foncé
  static const Color kDeepDark   = Color(0xFF210635); // Violet très foncé

  // Gradients
  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [kDeepDark, kDark],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [kPrimary, kBlueViolet],
  );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [kDeepDark, kDark],
  );

  // Glow shadow
  static List<BoxShadow> glowShadow([double opacity = 0.4]) => [
    BoxShadow(
      color: kPrimary.withOpacity(opacity),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  // TEXT STYLES MODERNES avec Poppins
  static TextStyle headingLarge({Color? color}) => GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: color ?? kLight,
    letterSpacing: -0.5,
  );

  static TextStyle headingMedium({Color? color}) => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: color ?? kLight,
  );

  static TextStyle bodyLarge({Color? color}) => GoogleFonts.poppins(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: color ?? kLight,
  );

  static TextStyle bodyMedium({Color? color}) => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: color ?? kBlueViolet,
  );

  static TextStyle labelSmall({Color? color}) => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: color ?? kBlueViolet,
  );
}