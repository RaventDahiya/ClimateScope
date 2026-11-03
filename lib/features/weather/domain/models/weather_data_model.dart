import 'city_model.dart';
import 'current_weather_model.dart';
import 'daily_forecast_model.dart';
import 'hourly_forecast_model.dart';

/// Aggregate immutable model containing all weather data for a selected city.
///
/// This is the single object stored in both the Riverpod notifier state and
/// the local SharedPreferences cache.
final class WeatherDataModel {
  const WeatherDataModel({
    required this.current,
    required this.dailyForecasts,
    required this.hourlyForecasts,
    required this.city,
    required this.timezone,
    required this.lastUpdated,
    this.cacheVersion = 1,
    this.isFromCache = false,
  });

  /// Current weather conditions.
  final CurrentWeatherModel current;

  /// 5-day daily forecast list.
  final List<DailyForecastModel> dailyForecasts;

  /// Full hourly forecast list (~120 entries). Filtered to next ~24h in the UI.
  final List<HourlyForecastModel> hourlyForecasts;

  /// The city this data belongs to.
  final CityModel city;

  /// IANA timezone string from the API (e.g., "Europe/Berlin").
  final String timezone;

  /// Timestamp of the last successful data fetch.
  final DateTime lastUpdated;

  /// Schema version for cache migration. Increment when model fields change.
  final int cacheVersion;

  /// Whether this data was retrieved from local offline cache.
  final bool isFromCache;

  /// Creates a [WeatherDataModel] from a raw Open-Meteo forecast API response.
  ///
  /// [city] must be provided from the geocoding step, as the forecast endpoint
  /// does not return city metadata.
  factory WeatherDataModel.fromJson(
    Map<String, dynamic> json,
    CityModel city,
  ) {
    final currentJson = json['current'] as Map<String, dynamic>? ?? {};
    final dailyJson = json['daily'] as Map<String, dynamic>? ?? {};
    final hourlyJson = json['hourly'] as Map<String, dynamic>? ?? {};

    final currentWeather = CurrentWeatherModel.fromJson(currentJson);

    // Parse daily parallel arrays
    final dailyTimes = (dailyJson['time'] as List<dynamic>?) ?? [];
    final dailyCodes = (dailyJson['weather_code'] as List<dynamic>?) ?? [];
    final dailyMaxTemps =
        (dailyJson['temperature_2m_max'] as List<dynamic>?) ?? [];
    final dailyMinTemps =
        (dailyJson['temperature_2m_min'] as List<dynamic>?) ?? [];

    final dailyForecasts = <DailyForecastModel>[];
    final dailyCount = dailyTimes.length;
    for (var i = 0; i < dailyCount; i++) {
      dailyForecasts.add(
        DailyForecastModel.fromArrays(
          dateString: (dailyTimes[i] as String?) ?? '',
          weatherCode: (dailyCodes[i] as num?)?.toInt() ?? 0,
          tempMin: (dailyMinTemps[i] as num?)?.toDouble() ?? 0.0,
          tempMax: (dailyMaxTemps[i] as num?)?.toDouble() ?? 0.0,
        ),
      );
    }

    // Parse hourly parallel arrays
    final hourlyTimes = (hourlyJson['time'] as List<dynamic>?) ?? [];
    final hourlyTemps =
        (hourlyJson['temperature_2m'] as List<dynamic>?) ?? [];
    final hourlyCodes = (hourlyJson['weather_code'] as List<dynamic>?) ?? [];

    final hourlyForecasts = <HourlyForecastModel>[];
    final hourlyCount = hourlyTimes.length;
    for (var i = 0; i < hourlyCount; i++) {
      hourlyForecasts.add(
        HourlyForecastModel.fromArrays(
          timeString: (hourlyTimes[i] as String?) ?? '',
          temperature: (hourlyTemps[i] as num?)?.toDouble() ?? 0.0,
          weatherCode: (hourlyCodes[i] as num?)?.toInt() ?? 0,
        ),
      );
    }

    return WeatherDataModel(
      current: currentWeather,
      dailyForecasts: dailyForecasts,
      hourlyForecasts: hourlyForecasts,
      city: city,
      timezone: (json['timezone'] as String?) ?? 'UTC',
      lastUpdated: DateTime.now(),
    );
  }

  /// Deserialises a [WeatherDataModel] from a cached JSON map.
  ///
  /// Returns `null` if the JSON is malformed or has an incompatible
  /// [cacheVersion] — callers should treat null as a cache miss.
  static WeatherDataModel? fromCacheJson(Map<String, dynamic> json) {
    const expectedVersion = 1;
    final version = (json['cacheVersion'] as num?)?.toInt() ?? 0;
    if (version != expectedVersion) return null;

    final currentJson = json['current'] as Map<String, dynamic>?;
    final cityJson = json['city'] as Map<String, dynamic>?;
    if (currentJson == null || cityJson == null) return null;

    final dailyList = (json['dailyForecasts'] as List<dynamic>?) ?? [];
    final hourlyList = (json['hourlyForecasts'] as List<dynamic>?) ?? [];

    return WeatherDataModel(
      current: CurrentWeatherModel.fromJson(currentJson),
      dailyForecasts: dailyList
          .whereType<Map<String, dynamic>>()
          .map(DailyForecastModel.fromJson)
          .toList(),
      hourlyForecasts: hourlyList
          .whereType<Map<String, dynamic>>()
          .map(HourlyForecastModel.fromJson)
          .toList(),
      city: CityModel.fromJson(cityJson),
      timezone: (json['timezone'] as String?) ?? 'UTC',
      lastUpdated: DateTime.tryParse(
            (json['lastUpdated'] as String?) ?? '',
          ) ??
          DateTime.now(),
      cacheVersion: version,
      isFromCache: true,
    );
  }

  /// Creates a copy of this [WeatherDataModel] with optional fields replaced.
  WeatherDataModel copyWith({
    CurrentWeatherModel? current,
    List<DailyForecastModel>? dailyForecasts,
    List<HourlyForecastModel>? hourlyForecasts,
    CityModel? city,
    String? timezone,
    DateTime? lastUpdated,
    int? cacheVersion,
    bool? isFromCache,
  }) {
    return WeatherDataModel(
      current: current ?? this.current,
      dailyForecasts: dailyForecasts ?? this.dailyForecasts,
      hourlyForecasts: hourlyForecasts ?? this.hourlyForecasts,
      city: city ?? this.city,
      timezone: timezone ?? this.timezone,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      cacheVersion: cacheVersion ?? this.cacheVersion,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }

  /// Serialises to a JSON map for storage in SharedPreferences.
  Map<String, dynamic> toJson() {
    return {
      'cacheVersion': cacheVersion,
      'current': {
        'temperature_2m': current.temperature,
        'relative_humidity_2m': current.humidity,
        'weather_code': current.weatherCode,
        'wind_speed_10m': current.windSpeed,
      },
      'dailyForecasts':
          dailyForecasts.map((d) => d.toJson()).toList(),
      'hourlyForecasts':
          hourlyForecasts.map((h) => h.toJson()).toList(),
      'city': city.toJson(),
      'timezone': timezone,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  @override
  String toString() =>
      'WeatherDataModel(city: ${city.name}, timezone: $timezone, '
      'lastUpdated: $lastUpdated)';
}

