import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/api/geocoding_api_client.dart';
import '../data/api/weather_api_client.dart';
import '../data/repositories/weather_repository.dart';
import '../domain/enums/temperature_unit.dart';
import '../domain/models/city_model.dart';
import '../domain/models/weather_data_model.dart';
import 'search_notifier.dart';
import 'settings_notifier.dart';
import 'weather_notifier.dart';

/// Provider for the [GeocodingApiClient] singleton.
final geocodingApiClientProvider = Provider<GeocodingApiClient>((ref) {
  return GeocodingApiClient();
});

/// Provider for the [WeatherApiClient] singleton.
final weatherApiClientProvider = Provider<WeatherApiClient>((ref) {
  return WeatherApiClient();
});

/// Provider for the [WeatherRepository] data-access layer.
final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  final geocodingClient = ref.watch(geocodingApiClientProvider);
  final weatherClient = ref.watch(weatherApiClientProvider);
  return WeatherRepository(
    geocodingClient: geocodingClient,
    weatherClient: weatherClient,
  );
});

/// Async notifier provider managing current weather data state.
final weatherNotifierProvider =
    AsyncNotifierProvider<WeatherNotifier, WeatherDataModel?>(
  WeatherNotifier.new,
);

/// Async notifier provider managing city search query and results.
final searchNotifierProvider =
    AsyncNotifierProvider<SearchNotifier, List<CityModel>>(
  SearchNotifier.new,
);

/// Notifier provider managing temperature unit preferences (°C vs °F).
final settingsNotifierProvider =
    NotifierProvider<SettingsNotifier, TemperatureUnit>(
  SettingsNotifier.new,
);

