/// Immutable model for a single day in the 5-day daily forecast.
final class DailyForecastModel {
  const DailyForecastModel({
    required this.date,
    required this.weatherCode,
    required this.tempMin,
    required this.tempMax,
  });

  /// The calendar date for this forecast day.
  final DateTime date;

  /// WMO weather interpretation code for the day.
  final int weatherCode;

  /// Minimum temperature for the day in Celsius.
  final double tempMin;

  /// Maximum temperature for the day in Celsius.
  final double tempMax;

  /// Creates a [DailyForecastModel] from parallel daily arrays at index [i].
  ///
  /// The Open-Meteo daily response is structured as parallel arrays:
  /// `{ "time": [...], "weather_code": [...], "temperature_2m_max": [...], ... }`
  factory DailyForecastModel.fromArrays({
    required String dateString,
    required int weatherCode,
    required double tempMin,
    required double tempMax,
  }) {
    return DailyForecastModel(
      date: DateTime.tryParse(dateString) ?? DateTime.now(),
      weatherCode: weatherCode,
      tempMin: tempMin,
      tempMax: tempMax,
    );
  }

  /// Creates a [DailyForecastModel] from a cached JSON map.
  factory DailyForecastModel.fromJson(Map<String, dynamic> json) {
    return DailyForecastModel(
      date: DateTime.tryParse((json['date'] as String?) ?? '') ?? DateTime.now(),
      weatherCode: (json['weatherCode'] as num?)?.toInt() ?? 0,
      tempMin: (json['tempMin'] as num?)?.toDouble() ?? 0.0,
      tempMax: (json['tempMax'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Serialises to a JSON map for caching.
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'weatherCode': weatherCode,
      'tempMin': tempMin,
      'tempMax': tempMax,
    };
  }

  @override
  String toString() =>
      'DailyForecastModel(date: $date, weatherCode: $weatherCode, '
      'tempMin: $tempMin, tempMax: $tempMax)';
}

