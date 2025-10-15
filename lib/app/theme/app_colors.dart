import 'package:flutter/material.dart';

/// Colores de la aplicación Tribbe
class AppColors {
  AppColors._();

  // Primary - Azul característico de Tribbe
  static const Color kPrimaryColor = Color(0xFF0047FF);
  static const Color kPrimaryLight = Color(0xFF4D7CFF);
  static const Color kPrimaryDark = Color(0xFF0033B8);

  // Secondary
  static const Color kSecondaryColor = Color(0xFF00D9FF);
  static const Color kSecondaryLight = Color(0xFF66E5FF);
  static const Color kSecondaryDark = Color(0xFF00A8CC);

  // Neutral
  static const Color kBackgroundLight = Color(0xFFFAFAFA);
  static const Color kBackgroundDark = Color(0xFF121212);
  static const Color kSurfaceLight = Color(0xFFFFFFFF);
  static const Color kSurfaceDark = Color(0xFF1E1E1E);
  static const Color kTextPrimary = Color(0xFF1A1A1A);
  static const Color kTextSecondary = Color(0xFF666666);
  static const Color kTextLight = Color(0xFFFFFFFF);
  static const Color kDivider = Color(0xFFE0E0E0);

  // Status
  static const Color kSuccess = Color(0xFF4CAF50);
  static const Color kError = Color(0xFFF44336);
  static const Color kWarning = Color(0xFFFFC107);
  static const Color kInfo = Color(0xFF2196F3);

  // Social OAuth
  static const Color kFacebookBlue = Color(0xFF1877F2);
  static const Color kGoogleRed = Color(0xFFDB4437);
  static const Color kAppleBlack = Color(0xFF000000);
  static const Color kAppleWhite = Color(0xFFFFFFFF);

  // Gradients
  static const LinearGradient kPrimaryGradient = LinearGradient(
    colors: [kPrimaryColor, kSecondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient kDarkGradient = LinearGradient(
    colors: [Color(0xFF1A1A1A), Color(0xFF2D2D2D)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
