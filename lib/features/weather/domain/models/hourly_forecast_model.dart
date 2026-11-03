/// Immutable model for a single hour in the hourly forecast strip.
final class HourlyForecastModel {
  const HourlyForecastModel({
    required this.time,
    required this.temperature,
    required this.weatherCode,
  });

  /// The datetime for this hourly slot (in city-local time, parsed as UTC-naive).
  final DateTime time;

  /// Temperature in Celsius for this hour.
  final double temperature;

  /// WMO weather interpretation code for this hour.
  final int weatherCode;

  /// Creates an [HourlyForecastModel] from parallel hourly arrays at index [i].
  factory HourlyForecastModel.fromArrays({
    required String timeString,
    required double temperature,
    required int weatherCode,
  }) {
    return HourlyForecastModel(
      time: DateTime.tryParse(timeString) ?? DateTime.now(),
      temperature: temperature,
      weatherCode: weatherCode,
    );
  }

  /// Creates an [HourlyForecastModel] from a cached JSON map.
  factory HourlyForecastModel.fromJson(Map<String, dynamic> json) {
    return HourlyForecastModel(
      time: DateTime.tryParse((json['time'] as String?) ?? '') ?? DateTime.now(),
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
      weatherCode: (json['weatherCode'] as num?)?.toInt() ?? 0,
    );
  }

  /// Serialises to a JSON map for caching.
  Map<String, dynamic> toJson() {
    return {
      'time': time.toIso8601String(),
      'temperature': temperature,
      'weatherCode': weatherCode,
    };
  }

  @override
  String toString() =>
      'HourlyForecastModel(time: $time, temperature: $temperature, '
      'weatherCode: $weatherCode)';
}
