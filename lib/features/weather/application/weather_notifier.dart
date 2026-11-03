import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/city_model.dart';
import '../domain/models/weather_data_model.dart';
import 'providers.dart';

/// Notifier managing current weather data state.
///
/// Handles local cache loading, request cancellation, and network fetch updates.
class WeatherNotifier extends AsyncNotifier<WeatherDataModel?> {
  CancelToken? _cancelToken;
  CityModel? _selectedCity;

  /// Currently selected city (or null if no city has been selected yet).
  CityModel? get selectedCity => _selectedCity ?? state.valueOrNull?.city;

  @override
  FutureOr<WeatherDataModel?> build() async {
    ref.onDispose(() {
      _cancelToken?.cancel('WeatherNotifier disposed');
    });

    final localStorage = ref.read(weatherLocalStorageProvider);
    final cached = await localStorage.getCachedWeatherData();
    if (cached != null) {
      _selectedCity = cached.city;
      unawaited(_refreshSilently(cached.city));
      return cached;
    }

    return null;
  }

  /// Fetches weather forecast data for [city].
  ///
  /// Cancels any previous in-flight request before starting a new one.
  /// If offline or network fails and cached data exists for [city],
  /// retains the cached data with the staleness indicator rather than
  /// transitioning to an error screen.
  Future<void> fetchWeather(CityModel city) async {
    _selectedCity = city;
    _cancelToken?.cancel('New weather request initiated');
    final cancelToken = _cancelToken = CancelToken();

    final previousData = state.valueOrNull;
    state = const AsyncLoading();

    final repository = ref.read(weatherRepositoryProvider);
    final localStorage = ref.read(weatherLocalStorageProvider);

    try {
      final freshData = await repository.fetchWeather(
        city,
        cancelToken: cancelToken,
      );

      if (cancelToken.isCancelled) return;

      // Save to cache on successful fetch
      await localStorage.saveWeatherData(freshData);

      state = AsyncData(freshData);
    } catch (error, stackTrace) {
      if (cancelToken.isCancelled) return;

      // Distinguish offline + cache from offline + no cache
      if (previousData != null &&
          previousData.city.name.toLowerCase() == city.name.toLowerCase()) {
        state = AsyncData(previousData.copyWith(isFromCache: true));
      } else {
        final cached = await localStorage.getCachedWeatherData();
        if (cached != null &&
            cached.city.name.toLowerCase() == city.name.toLowerCase()) {
          state = AsyncData(cached);
        } else {
          state = AsyncError(error, stackTrace);
        }
      }
    }
  }

  /// Silently attempts to refresh cached weather data in the background.
  Future<void> _refreshSilently(CityModel city) async {
    _cancelToken?.cancel('Silent refresh initiated');
    final cancelToken = _cancelToken = CancelToken();

    try {
      final repository = ref.read(weatherRepositoryProvider);
      final freshData = await repository.fetchWeather(
        city,
        cancelToken: cancelToken,
      );

      if (cancelToken.isCancelled) return;

      final localStorage = ref.read(weatherLocalStorageProvider);
      await localStorage.saveWeatherData(freshData);

      state = AsyncData(freshData);
    } catch (_) {
      // Offline or network error during silent background refresh:
      // Keep displaying the cached data with the offline banner.
    }
  }

  /// Refreshes weather data for the currently selected city.
  Future<void> refresh() async {
    final targetCity = selectedCity;
    if (targetCity != null) {
      await fetchWeather(targetCity);
    }
  }
}

