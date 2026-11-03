/// API constants for Open-Meteo Geocoding and Forecast endpoints.
abstract final class ApiConstants {
  /// Geocoding API base URL.
  static const String geocodingBaseUrl =
      'https://geocoding-api.open-meteo.com';

  /// Geocoding search endpoint path.
  static const String geocodingSearchPath = '/v1/search';

  /// Weather forecast API base URL.
  static const String forecastBaseUrl = 'https://api.open-meteo.com';

  /// Weather forecast endpoint path.
  static const String forecastPath = '/v1/forecast';

  /// Default number of geocoding results to request.
  static const int defaultGeocodingCount = 5;

  /// Default number of forecast days to request.
  static const int defaultForecastDays = 5;

  /// Forecast query parameter: current weather variables.
  static const String currentVariables =
      'temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m';

  /// Forecast query parameter: daily weather variables.
  static const String dailyVariables =
      'weather_code,temperature_2m_max,temperature_2m_min';

  /// Forecast query parameter: hourly weather variables.
  static const String hourlyVariables = 'temperature_2m,weather_code';

  /// Forecast query parameter: timezone auto-detection.
  static const String timezoneAuto = 'auto';

  /// HTTP connect timeout duration.
  static const Duration connectTimeout = Duration(seconds: 10);

  /// HTTP receive timeout duration.
  static const Duration receiveTimeout = Duration(seconds: 15);

  /// HTTP send timeout duration.
  static const Duration sendTimeout = Duration(seconds: 10);
}

