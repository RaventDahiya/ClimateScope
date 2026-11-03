import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/city_model.dart';
import '../domain/models/weather_data_model.dart';
import 'providers.dart';

/// Notifier managing current weather data state.
///
/// Handles cancellation of in-flight requests and safe async updates.
class WeatherNotifier extends AsyncNotifier<WeatherDataModel?> {
  CancelToken? _cancelToken;
  CityModel? _selectedCity;

  /// Currently selected city (or null if no city has been selected yet).
  CityModel? get selectedCity => _selectedCity ?? state.valueOrNull?.city;

  @override
  FutureOr<WeatherDataModel?> build() {
    ref.onDispose(() {
      _cancelToken?.cancel('WeatherNotifier disposed');
    });

    // In Phase 3, initial state is null (empty state).
    // In Phase 5, this will load from local cache.
    return null;
  }

  /// Fetches weather forecast data for [city].
  ///
  /// Cancels any previous in-flight request before starting a new one.
  Future<void> fetchWeather(CityModel city) async {
    _selectedCity = city;
    _cancelToken?.cancel('New weather request initiated');
    final cancelToken = _cancelToken = CancelToken();

    state = const AsyncLoading();

    final nextState = await AsyncValue.guard(() async {
      final repository = ref.read(weatherRepositoryProvider);
      return await repository.fetchWeather(city, cancelToken: cancelToken);
    });

    // If request was superseded or cancelled, discard result.
    if (cancelToken.isCancelled) return;

    state = nextState;
  }

  /// Refreshes weather data for the currently selected city.
  Future<void> refresh() async {
    final targetCity = selectedCity;
    if (targetCity != null) {
      await fetchWeather(targetCity);
    }
  }
}

