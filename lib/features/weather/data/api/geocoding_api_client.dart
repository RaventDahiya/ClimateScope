import 'package:dio/dio.dart';
import '../../domain/models/city_model.dart';
import '../../../../core/constants/api_constants.dart';

/// Data-layer client for the Open-Meteo Geocoding API.
///
/// Responsible for a single operation: searching for cities by name and
/// returning a list of [CityModel] results.
final class GeocodingApiClient {
  GeocodingApiClient() : _dio = _buildDio();

  final Dio _dio;

  static Dio _buildDio() {
    return Dio(
      BaseOptions(
        baseUrl: ApiConstants.geocodingBaseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
      ),
    );
  }

  /// Searches for cities matching [query] and returns up to 5 results.
  ///
  /// When the Open-Meteo API finds no cities, the `results` key is **omitted**
  /// entirely from the response (not an empty array). This method handles that
  /// case gracefully by returning an empty list.
  ///
  /// Throws a [DioException] on network / server errors.
  /// Callers (the repository) are responsible for mapping to [WeatherFailure].
  Future<List<CityModel>> search(
    String query, {
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.geocodingSearchPath,
      queryParameters: {
        'name': query,
        'count': ApiConstants.defaultGeocodingCount,
      },
      cancelToken: cancelToken,
    );

    final data = response.data;
    if (data == null) return [];

    // Critical: `results` key is absent (not null, not empty) when no cities match.
    final results = data['results'];
    if (results == null || results is! List) return [];

    return results
        .whereType<Map<String, dynamic>>()
        .map(CityModel.fromJson)
        .toList();
  }
}
