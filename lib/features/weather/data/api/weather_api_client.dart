import 'package:dio/dio.dart';
import '../../domain/models/city_model.dart';
import '../../domain/models/weather_data_model.dart';
import '../../../../core/constants/api_constants.dart';

/// Data-layer client for the Open-Meteo Forecast API.
///
/// Responsible for fetching current, daily, and hourly weather data for a
/// given latitude/longitude pair.
final class WeatherApiClient {
  WeatherApiClient() : _dio = _buildDio();

  final Dio _dio;

  static Dio _buildDio() {
    return Dio(
      BaseOptions(
        baseUrl: ApiConstants.forecastBaseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
      ),
    );
  }

  /// Fetches a 5-day forecast (current + daily + hourly) for the given [city].
  ///
  /// Throws a [DioException] on network / server errors.
  /// Callers (the repository) are responsible for mapping to [WeatherFailure].
  Future<WeatherDataModel> fetchForecast(
    CityModel city, {
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.forecastPath,
      queryParameters: {
        'latitude': city.latitude,
        'longitude': city.longitude,
        'current': ApiConstants.currentVariables,
        'daily': ApiConstants.dailyVariables,
        'hourly': ApiConstants.hourlyVariables,
        'forecast_days': ApiConstants.defaultForecastDays,
        'timezone': ApiConstants.timezoneAuto,
      },
      cancelToken: cancelToken,
    );

    final data = response.data;
    if (data == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Empty response body from forecast API',
        type: DioExceptionType.badResponse,
      );
    }

    return WeatherDataModel.fromJson(data, city);
  }
}
