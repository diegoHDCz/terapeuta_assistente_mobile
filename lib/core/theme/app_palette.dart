import 'package:flutter/material.dart';

/// Color palette for the app.
///
/// Built around terracotta, pink and "white ice" — chosen for a clinic /
/// health context: terracotta reads as warm and grounding without feeling
/// clinical, soft pink adds a gentle, caring accent, and white ice keeps
/// surfaces calm and airy. Glass tokens support a light glassmorphism
/// treatment (translucent surfaces over soft gradients).
class AppPalette {
  AppPalette._();

  // Brand
  static const Color terracotta = Color(0xFFC97B63);
  static const Color terracottaDark = Color(0xFFA85C46);
  static const Color terracottaLight = Color(0xFFE3A78D);

  static const Color pink = Color(0xFFF0B8C6);
  static const Color pinkLight = Color(0xFFFBE4E9);
  static const Color pinkDark = Color(0xFFD98FA3);

  static const Color whiteIce = Color(0xFFF6FAFA);
  static const Color whiteIceSurface = Color(0xFFEDF3F3);

  // Text
  static const Color textPrimary = Color(0xFF33302E);
  static const Color textSecondary = Color(0xFF6B625D);
  static const Color textOnBrand = Color(0xFFFFFDFB);

  // Semantic
  static const Color success = Color(0xFF7FAF8B);
  static const Color error = Color(0xFFE2685B);
  static const Color warning = Color(0xFFE3B05C);

  // Glassmorphism helpers
  static Color glassSurface = Colors.white.withValues(alpha: 0.18);
  static Color glassBorder = Colors.white.withValues(alpha: 0.35);
  static const List<Color> glassGradient = [pinkLight, whiteIce];

  static const List<BoxShadow> glassShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];
}
