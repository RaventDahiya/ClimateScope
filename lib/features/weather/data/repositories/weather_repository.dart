import 'package:dio/dio.dart';
import '../api/geocoding_api_client.dart';
import '../api/weather_api_client.dart';
import '../../domain/failures/weather_failure.dart';
import '../../domain/models/city_model.dart';
import '../../domain/models/weather_data_model.dart';

/// Single data-access point for all weather and geocoding operations.
///
/// Combines [GeocodingApiClient] and [WeatherApiClient], and is responsible
/// for mapping all [DioException]s to typed [WeatherFailure] sealed classes
/// before they propagate to the application layer.
final class WeatherRepository {
  WeatherRepository({
    required GeocodingApiClient geocodingClient,
    required WeatherApiClient weatherClient,
  })  : _geocodingClient = geocodingClient,
        _weatherClient = weatherClient;

  final GeocodingApiClient _geocodingClient;
  final WeatherApiClient _weatherClient;

  /// Searches for cities matching [query].
  ///
  /// Returns an empty list when no cities match.
  /// Throws a [WeatherFailure] on any network or server error.
  Future<List<CityModel>> searchCities(
    String query, {
    CancelToken? cancelToken,
  }) async {
    try {
      return await _geocodingClient.search(query, cancelToken: cancelToken);
    } on DioException catch (e) {
      // Silently ignore user-initiated request cancellations.
      if (e.type == DioExceptionType.cancel) rethrow;
      throw _mapDioException(e);
    }
  }

  /// Fetches a 5-day weather forecast for [city].
  ///
  /// Throws a [WeatherFailure] on any network or server error.
  Future<WeatherDataModel> fetchWeather(
    CityModel city, {
    CancelToken? cancelToken,
  }) async {
    try {
      return await _weatherClient.fetchForecast(city, cancelToken: cancelToken);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) rethrow;
      throw _mapDioException(e);
    }
  }

  /// Maps a [DioException] to a typed [WeatherFailure].
  ///
  /// Mapping rules per the Architecture doc:
  /// - connectionTimeout / sendTimeout / receiveTimeout → [TimeoutFailure]
  /// - connectionError → [NetworkFailure]
  /// - badResponse 404 → [NotFoundFailure]
  /// - badResponse other → [ServerFailure]
  /// - cancel → should not reach here (callers rethrow cancel)
  /// - Any other → [UnknownFailure]
  WeatherFailure _mapDioException(DioException e) {
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        const TimeoutFailure(),
      DioExceptionType.connectionError => const NetworkFailure(),
      DioExceptionType.badResponse => _mapBadResponse(e),
      _ => const UnknownFailure(),
    };
  }

  WeatherFailure _mapBadResponse(DioException e) {
    final statusCode = e.response?.statusCode;
    if (statusCode == 404) return const NotFoundFailure();
    return const ServerFailure();
  }
}
