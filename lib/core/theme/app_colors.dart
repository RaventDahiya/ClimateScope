import 'package:flutter/material.dart';

/// Design system color tokens for ClimateScope (Dark Theme Only).
///
/// NOTE: [colorWeatherYellow] is strictly reserved for sun and lightning
/// weather indicators and must never be used for general UI elements.
abstract final class AppColors {
  /// Root scaffold background, app canvas (#1E1E1E).
  static const Color colorBackground = Color(0xFF1E1E1E);

  /// Metric cards, forecast container, bottom sheet surface (#2A2A2E).
  static const Color colorSurface = Color(0xFF2A2A2E);

  /// Hourly slot default background, search field fill (#333338).
  static const Color colorSurfaceVariant = Color(0xFF333338);

  /// Primary data: temperature, city name, headings (#FFFFFF).
  static const Color colorTextPrimary = Color(0xFFFFFFFF);

  /// Secondary labels, descriptions, units, timestamps (#9E9EA8).
  static const Color colorTextSecondary = Color(0xFF9E9EA8);

  /// Selected hourly slot, water indicators, active UI elements (#3B82F6).
  static const Color colorAccentBlue = Color(0xFF3B82F6);

  /// EXCLUSIVELY for sun and lightning weather icon tints (#FACC15).
  /// Never use for buttons, text, links, or warnings.
  static const Color colorWeatherYellow = Color(0xFFFACC15);

  /// Cloud, fog, and snow icon tints (#E2E2E8).
  static const Color colorWeatherWhite = Color(0xFFE2E2E8);

  /// Rain and drizzle icon tints (#60A5FA).
  static const Color colorWeatherBlue = Color(0xFF60A5FA);

  /// Error state icon tint (#EF4444).
  static const Color colorError = Color(0xFFEF4444);

  /// Offline/staleness banner background (#3B3B40).
  static const Color colorOfflineBanner = Color(0xFF3B3B40);

  /// Subtle dividers between forecast rows (#3B3B40).
  static const Color colorDivider = Color(0xFF3B3B40);
}

