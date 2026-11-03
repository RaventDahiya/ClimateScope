import '../strings/app_strings.dart';
import '../../features/weather/domain/enums/temperature_unit.dart';

/// Pure unit-conversion utilities for ClimateScope.
///
/// **Principle:** Raw metric values (°C, km/h) are stored everywhere — models,
/// cache, and provider state. Conversion to the user's preferred unit happens
/// **only** at display time in the presentation layer, using these functions.
///
/// This means the unit toggle works fully offline: it is local math, not an
/// API call.
abstract final class UnitConverter {
  // ── Temperature ────────────────────────────────────────────────────────────

  /// Converts [celsius] to Fahrenheit.
  ///
  /// Formula: `°F = °C × 9/5 + 32`
  static double celsiusToFahrenheit(double celsius) =>
      celsius * 9 / 5 + 32;

  /// Converts [fahrenheit] to Celsius.
  ///
  /// Formula: `°C = (°F − 32) × 5/9`
  /// Not used for display (API is always metric) but included for completeness.
  static double fahrenheitToCelsius(double fahrenheit) =>
      (fahrenheit - 32) * 5 / 9;

  // ── Wind Speed ─────────────────────────────────────────────────────────────

  /// Converts [kmh] (km/h) to mph.
  ///
  /// Formula: `mph = km/h × 0.621371`
  static double kmhToMph(double kmh) => kmh * 0.621371;

  /// Converts [mph] to km/h.
  ///
  /// Not used for display (API is always metric) but included for completeness.
  static double mphToKmh(double mph) => mph * 1.60934;

  // ── Formatted Display Strings ──────────────────────────────────────────────

  /// Converts [celsius] to the [unit] system and returns a formatted string.
  ///
  /// Examples:
  /// - `formatTemperature(23.4, celsius)` → `"23°C"`
  /// - `formatTemperature(23.4, fahrenheit)` → `"74°F"`
  ///
  /// Value is **rounded** to the nearest integer for display.
  static String formatTemperature(double celsius, TemperatureUnit unit) {
    final value = unit == TemperatureUnit.fahrenheit
        ? celsiusToFahrenheit(celsius).round()
        : celsius.round();
    return '$value${unit.symbol}';
  }

  /// Converts [kmh] wind speed to the [unit] system and returns a formatted
  /// string with the appropriate unit label.
  ///
  /// Examples:
  /// - `formatWindSpeed(15.0, celsius)` → `"15 km/h"`
  /// - `formatWindSpeed(15.0, fahrenheit)` → `"9 mph"`
  ///
  /// Value is **rounded** to the nearest integer for display.
  static String formatWindSpeed(double kmh, TemperatureUnit unit) {
    if (unit == TemperatureUnit.fahrenheit) {
      return '${kmhToMph(kmh).round()} ${AppStrings.unitMph}';
    }
    return '${kmh.round()} ${AppStrings.unitKmh}';
  }

  /// Returns the temperature integer for display (no symbol) in [unit].
  ///
  /// Useful when the symbol is rendered separately (e.g. in the hero widget).
  static int temperatureValue(double celsius, TemperatureUnit unit) {
    return unit == TemperatureUnit.fahrenheit
        ? celsiusToFahrenheit(celsius).round()
        : celsius.round();
  }
}
