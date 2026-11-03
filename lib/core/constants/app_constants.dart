/// Application-wide constants including cache keys and debounce limits.
abstract final class AppConstants {
  /// SharedPreferences key for cached weather data JSON.
  static const String cacheKeyWeatherData = 'cached_weather_data';

  /// SharedPreferences key for persisted unit preference.
  static const String cacheKeySelectedUnit = 'selected_unit';

  /// SharedPreferences key for recent searches JSON array.
  static const String cacheKeyRecentSearches = 'recent_searches';

  /// Schema version for cached weather data.
  static const int cacheVersion = 1;

  /// Debounce duration for city search input field.
  static const Duration searchDebounceDuration = Duration(milliseconds: 500);

  /// Maximum number of recent city searches to persist.
  static const int maxRecentSearches = 10;
}

