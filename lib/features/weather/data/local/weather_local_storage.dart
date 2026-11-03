import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/models/weather_data_model.dart';

/// Local persistent storage layer for weather data and app preferences.
///
/// Encapsulates all [SharedPreferences] reads and writes with schema version
/// validation and corrupted payload protection.
class WeatherLocalStorage {
  WeatherLocalStorage({SharedPreferences? sharedPreferences})
      : _sharedPreferences = sharedPreferences;

  SharedPreferences? _sharedPreferences;

  Future<SharedPreferences> _getPrefs() async {
    return _sharedPreferences ??= await SharedPreferences.getInstance();
  }

  /// Persists [data] as a JSON string under [AppConstants.cacheKeyWeatherData].
  Future<bool> saveWeatherData(WeatherDataModel data) async {
    try {
      final prefs = await _getPrefs();
      final jsonString = jsonEncode(data.toJson());
      return await prefs.setString(
        AppConstants.cacheKeyWeatherData,
        jsonString,
      );
    } catch (_) {
      return false;
    }
  }

  /// Retrieves cached [WeatherDataModel] from [SharedPreferences].
  ///
  /// Returns `null` if no cache exists, the schema version mismatches,
  /// or the JSON payload is malformed. If corrupted or outdated,
  /// the stale cache key is automatically purged.
  Future<WeatherDataModel?> getCachedWeatherData() async {
    try {
      final prefs = await _getPrefs();
      final jsonString = prefs.getString(AppConstants.cacheKeyWeatherData);
      if (jsonString == null || jsonString.isEmpty) {
        return null;
      }

      final dynamic decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic>) {
        await clearWeatherData();
        return null;
      }

      final weatherData = WeatherDataModel.fromCacheJson(decoded);
      if (weatherData == null) {
        // Schema mismatch or invalid data -> clear stale cache
        await clearWeatherData();
        return null;
      }

      return weatherData;
    } catch (_) {
      // Catch FormatException, TypeError, etc. -> purge corrupt data
      await clearWeatherData();
      return null;
    }
  }

  /// Clears the cached weather data from [SharedPreferences].
  Future<bool> clearWeatherData() async {
    try {
      final prefs = await _getPrefs();
      return await prefs.remove(AppConstants.cacheKeyWeatherData);
    } catch (_) {
      return false;
    }
  }
}
