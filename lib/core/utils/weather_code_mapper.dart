import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Immutable data class representing the visual properties of a weather condition.
///
/// Returned by [WeatherCodeMapper.map] for a given WMO weather code.
/// The [conditionText] doubles as the semantic label for screen-reader consumers.
@immutable
class WeatherInfo {
  /// Human-readable condition label (e.g., "Clear Sky", "Moderate Rain").
  /// Also used as the `semanticLabel` for weather icons.
  final String conditionText;

  /// Material icon representing this weather condition.
  final IconData icon;

  /// Tint color for the icon.
  ///
  /// Color rules (strictly enforced per Design.md §6):
  /// - [AppColors.colorWeatherYellow] → **only** sun (codes 0, 1) and
  ///   thunderstorm/hail icons (codes 95, 96, 99).
  /// - [AppColors.colorWeatherBlue]  → drizzle, rain, and shower icons.
  /// - [AppColors.colorWeatherWhite] → cloud, fog, and snow icons.
  /// - [AppColors.colorTextSecondary] → unknown fallback.
  final Color tintColor;

  /// Glow center color used by the radial gradient in [WeatherIconGlow].
  final Color glowColor;

  /// Glow opacity (0.0–1.0) at the radial gradient center.
  final double glowOpacity;

  const WeatherInfo({
    required this.conditionText,
    required this.icon,
    required this.tintColor,
    required this.glowColor,
    required this.glowOpacity,
  });
}

/// Single source of truth for all WMO weather-code → visual-property mappings.
///
/// Usage:
/// ```dart
/// final info = WeatherCodeMapper.map(weatherCode);
/// Icon(info.icon, color: info.tintColor, semanticLabel: info.conditionText);
/// ```
abstract final class WeatherCodeMapper {
  /// Maps a WMO weather code to a [WeatherInfo] instance.
  ///
  /// Returns a grey "Unknown" fallback for any code not in the WMO spec.
  static WeatherInfo map(int code) {
    return switch (code) {
      // ── Clear ──────────────────────────────────────────────────────────
      0 => const WeatherInfo(
          conditionText: 'Clear Sky',
          icon: Icons.wb_sunny_rounded,
          tintColor: AppColors.colorWeatherYellow,
          glowColor: Color(0xFFFACC15), // colorWeatherYellow
          glowOpacity: 0.20,
        ),
      1 => const WeatherInfo(
          conditionText: 'Mainly Clear',
          icon: Icons.wb_sunny_rounded,
          tintColor: AppColors.colorWeatherYellow,
          glowColor: Color(0xFFFACC15),
          glowOpacity: 0.15,
        ),

      // ── Cloudy ─────────────────────────────────────────────────────────
      2 => const WeatherInfo(
          conditionText: 'Partly Cloudy',
          icon: Icons.cloud_rounded,
          tintColor: AppColors.colorWeatherWhite,
          glowColor: Color(0xFF9E9EA8), // colorTextSecondary
          glowOpacity: 0.12,
        ),
      3 => const WeatherInfo(
          conditionText: 'Overcast',
          icon: Icons.cloud_rounded,
          tintColor: AppColors.colorWeatherWhite,
          glowColor: Color(0xFF9E9EA8),
          glowOpacity: 0.12,
        ),

      // ── Fog ────────────────────────────────────────────────────────────
      45 => const WeatherInfo(
          conditionText: 'Fog',
          icon: Icons.cloud_rounded,
          tintColor: AppColors.colorWeatherWhite,
          glowColor: Color(0xFF9E9EA8),
          glowOpacity: 0.15,
        ),
      48 => const WeatherInfo(
          conditionText: 'Rime Fog',
          icon: Icons.cloud_rounded,
          tintColor: AppColors.colorWeatherWhite,
          glowColor: Color(0xFF9E9EA8),
          glowOpacity: 0.15,
        ),

      // ── Drizzle ────────────────────────────────────────────────────────
      51 => const WeatherInfo(
          conditionText: 'Light Drizzle',
          icon: Icons.grain_rounded,
          tintColor: AppColors.colorWeatherBlue,
          glowColor: Color(0xFF60A5FA), // colorWeatherBlue
          glowOpacity: 0.15,
        ),
      53 => const WeatherInfo(
          conditionText: 'Moderate Drizzle',
          icon: Icons.grain_rounded,
          tintColor: AppColors.colorWeatherBlue,
          glowColor: Color(0xFF60A5FA),
          glowOpacity: 0.15,
        ),
      55 => const WeatherInfo(
          conditionText: 'Dense Drizzle',
          icon: Icons.grain_rounded,
          tintColor: AppColors.colorWeatherBlue,
          glowColor: Color(0xFF60A5FA),
          glowOpacity: 0.15,
        ),

      // ── Rain ───────────────────────────────────────────────────────────
      61 => const WeatherInfo(
          conditionText: 'Slight Rain',
          icon: Icons.water_drop_rounded,
          tintColor: AppColors.colorWeatherBlue,
          glowColor: Color(0xFF3B82F6), // colorAccentBlue
          glowOpacity: 0.18,
        ),
      63 => const WeatherInfo(
          conditionText: 'Moderate Rain',
          icon: Icons.water_drop_rounded,
          tintColor: AppColors.colorWeatherBlue,
          glowColor: Color(0xFF3B82F6),
          glowOpacity: 0.18,
        ),
      65 => const WeatherInfo(
          conditionText: 'Heavy Rain',
          icon: Icons.water_drop_rounded,
          tintColor: AppColors.colorWeatherBlue,
          glowColor: Color(0xFF3B82F6),
          glowOpacity: 0.18,
        ),

      // ── Snow ───────────────────────────────────────────────────────────
      71 => const WeatherInfo(
          conditionText: 'Slight Snow',
          icon: Icons.ac_unit_rounded,
          tintColor: AppColors.colorWeatherWhite,
          glowColor: Color(0xFFE2E2E8), // colorWeatherWhite
          glowOpacity: 0.12,
        ),
      73 => const WeatherInfo(
          conditionText: 'Moderate Snow',
          icon: Icons.ac_unit_rounded,
          tintColor: AppColors.colorWeatherWhite,
          glowColor: Color(0xFFE2E2E8),
          glowOpacity: 0.12,
        ),
      75 => const WeatherInfo(
          conditionText: 'Heavy Snow',
          icon: Icons.ac_unit_rounded,
          tintColor: AppColors.colorWeatherWhite,
          glowColor: Color(0xFFE2E2E8),
          glowOpacity: 0.12,
        ),

      // ── Rain Showers ───────────────────────────────────────────────────
      80 => const WeatherInfo(
          conditionText: 'Slight Showers',
          icon: Icons.water_drop_rounded,
          tintColor: AppColors.colorWeatherBlue,
          glowColor: Color(0xFF3B82F6),
          glowOpacity: 0.18,
        ),
      81 => const WeatherInfo(
          conditionText: 'Moderate Showers',
          icon: Icons.water_drop_rounded,
          tintColor: AppColors.colorWeatherBlue,
          glowColor: Color(0xFF3B82F6),
          glowOpacity: 0.18,
        ),
      82 => const WeatherInfo(
          conditionText: 'Violent Showers',
          icon: Icons.water_drop_rounded,
          tintColor: AppColors.colorWeatherBlue,
          glowColor: Color(0xFF3B82F6),
          glowOpacity: 0.18,
        ),

      // ── Thunderstorm ───────────────────────────────────────────────────
      // NOTE: Yellow is the ONLY other colour besides sun allowed here.
      95 => const WeatherInfo(
          conditionText: 'Thunderstorm',
          icon: Icons.thunderstorm_rounded,
          tintColor: AppColors.colorWeatherYellow,
          glowColor: Color(0xFFFACC15),
          glowOpacity: 0.20,
        ),
      96 => const WeatherInfo(
          conditionText: 'Thunderstorm + Slight Hail',
          icon: Icons.thunderstorm_rounded,
          tintColor: AppColors.colorWeatherYellow,
          glowColor: Color(0xFFFACC15),
          glowOpacity: 0.20,
        ),
      99 => const WeatherInfo(
          conditionText: 'Thunderstorm + Heavy Hail',
          icon: Icons.thunderstorm_rounded,
          tintColor: AppColors.colorWeatherYellow,
          glowColor: Color(0xFFFACC15),
          glowOpacity: 0.20,
        ),

      // ── Unknown fallback ───────────────────────────────────────────────
      _ => const WeatherInfo(
          conditionText: 'Unknown',
          icon: Icons.help_outline_rounded,
          tintColor: AppColors.colorTextSecondary,
          glowColor: Color(0xFF9E9EA8),
          glowOpacity: 0.10,
        ),
    };
  }
}
