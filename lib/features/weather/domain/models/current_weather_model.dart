/// Immutable model for current weather conditions returned by the forecast API.
final class CurrentWeatherModel {
  const CurrentWeatherModel({
    required this.temperature,
    required this.humidity,
    required this.weatherCode,
    required this.windSpeed,
  });

  /// Current temperature in Celsius (always metric from API).
  final double temperature;

  /// Relative humidity as a percentage (0–100).
  final int humidity;

  /// WMO weather interpretation code.
  final int weatherCode;

  /// Wind speed in km/h (always metric from API).
  final double windSpeed;

  /// Creates a [CurrentWeatherModel] from the `current` object in the forecast response.
  factory CurrentWeatherModel.fromJson(Map<String, dynamic> json) {
    return CurrentWeatherModel(
      temperature: (json['temperature_2m'] as num?)?.toDouble() ?? 0.0,
      humidity: (json['relative_humidity_2m'] as num?)?.toInt() ?? 0,
      weatherCode: (json['weather_code'] as num?)?.toInt() ?? 0,
      windSpeed: (json['wind_speed_10m'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  String toString() =>
      'CurrentWeatherModel(temperature: $temperature, humidity: $humidity, '
      'weatherCode: $weatherCode, windSpeed: $windSpeed)';
}

