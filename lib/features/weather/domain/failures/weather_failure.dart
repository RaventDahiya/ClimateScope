/// Sealed class representing all typed failure cases for weather operations.
///
/// Every [WeatherFailure] carries a human-readable [message] that is safe
/// to display directly in the UI (sourced from [AppStrings]).
sealed class WeatherFailure {
  const WeatherFailure(this.message);

  /// User-facing description of the failure.
  final String message;
}

/// Thrown when the device has no network connectivity.
final class NetworkFailure extends WeatherFailure {
  const NetworkFailure([super.message = 'No internet connection']);
}

/// Thrown when a Dio request exceeds its configured timeout.
final class TimeoutFailure extends WeatherFailure {
  const TimeoutFailure([super.message = 'Request timed out. Please try again.']);
}

/// Thrown when geocoding returns no results (HTTP 404 or missing `results` key).
final class NotFoundFailure extends WeatherFailure {
  const NotFoundFailure([super.message = 'City not found']);
}

/// Thrown on non-404 HTTP error responses (5xx, other 4xx).
final class ServerFailure extends WeatherFailure {
  const ServerFailure([super.message = 'Something went wrong. Please try again.']);
}

/// Thrown when the local cache cannot be read or parsed.
final class CacheFailure extends WeatherFailure {
  const CacheFailure([super.message = 'Unable to read cached data.']);
}

/// Catch-all for any unmapped or unexpected errors.
final class UnknownFailure extends WeatherFailure {
  const UnknownFailure([super.message = 'Something went wrong. Please try again.']);
}

