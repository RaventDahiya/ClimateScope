import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../domain/enums/temperature_unit.dart';

/// Notifier managing user-selected temperature unit preference.
///
/// Automatically persists preferences to [SharedPreferences].
class SettingsNotifier extends Notifier<TemperatureUnit> {
  @override
  TemperatureUnit build() {
    _loadPreference();
    return TemperatureUnit.celsius;
  }

  Future<void> _loadPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final unitString = prefs.getString(AppConstants.cacheKeySelectedUnit);
      if (unitString != null) {
        if (unitString == TemperatureUnit.fahrenheit.name) {
          state = TemperatureUnit.fahrenheit;
        } else {
          state = TemperatureUnit.celsius;
        }
      }
    } catch (_) {
      // If SharedPreferences fails, default to celsius without crashing.
    }
  }

  /// Toggles between Celsius and Fahrenheit.
  Future<void> toggle() async {
    state = state == TemperatureUnit.celsius
        ? TemperatureUnit.fahrenheit
        : TemperatureUnit.celsius;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.cacheKeySelectedUnit, state.name);
    } catch (_) {
      // Ignored
    }
  }

  /// Explicitly sets the temperature unit.
  Future<void> setUnit(TemperatureUnit unit) async {
    state = unit;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.cacheKeySelectedUnit, state.name);
    } catch (_) {
      // Ignored
    }
  }
}

