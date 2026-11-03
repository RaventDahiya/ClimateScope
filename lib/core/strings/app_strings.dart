/// Centralized repository of all user-facing strings for ClimateScope.
///
/// Per project rules, strings must never be hard-coded in presentation widgets.
abstract final class AppStrings {
  /// Application display title.
  static const String appName = 'ClimateScope';

  // Empty State
  /// Prompt shown on first launch when no city has been searched yet.
  static const String emptySearchPrompt =
      'Search for a city to see its weather';

  // Search Sheet
  /// Placeholder text in search input field.
  static const String searchHint = 'Search for a city…';

  /// Inline validation message for empty, whitespace, or special character queries.
  static const String searchValidationInvalid =
      'Please enter a valid city name';

  /// Message when geocoding returns no matches.
  static const String noCitiesFound = 'No cities found';

  /// Formatted message for empty results with specific query.
  static String noResultsFoundFor(String query) =>
      "No results found for '$query'";

  /// Section title for recent searches.
  static const String recentSearchesTitle = 'Recent';

  /// Button label to clear recent searches.
  static const String clearAll = 'Clear all';

  // Error Messages
  /// Network connectivity error.
  static const String errorNoInternet = 'No internet connection';

  /// Request timeout error.
  static const String errorTimeout = 'Request timed out. Please try again.';

  /// 404 / city not found error.
  static const String errorNotFound = 'City not found';

  /// Generic server error.
  static const String errorServer =
      'Something went wrong. Please try again.';

  /// Local cache read/parse error.
  static const String errorCache = 'Unable to read cached data.';

  /// Catch-all unknown failure error.
  static const String errorUnknown =
      'Something went wrong. Please try again.';

  /// Action label on error retry button.
  static const String retry = 'Retry';

  // Offline Banner
  /// Staleness indicator banner prefix.
  static const String dataMayBeOutdated = 'Data may be outdated';

  /// Last updated timestamp prefix.
  static const String lastUpdatedPrefix = 'Last updated: ';

  /// Separator dot for banner items.
  static const String bannerSeparator = ' • ';

  // Sections & Metrics
  /// Title for the 5-day daily forecast section.
  static const String fiveDaysSectionTitle = '5 days';

  /// Title for the 24-hour hourly forecast section.
  static const String todaySectionTitle = 'Today';

  /// Wind metric card label.
  static const String windLabel = 'Wind';

  /// Humidity metric card label.
  static const String humidityLabel = 'Humidity';

  /// Fallback condition text for unknown WMO codes.
  static const String conditionUnknown = 'Unknown';

  // Units
  /// Celsius symbol.
  static const String unitCelsius = '°C';

  /// Fahrenheit symbol.
  static const String unitFahrenheit = '°F';

  /// Kilometers per hour symbol.
  static const String unitKmh = 'km/h';

  /// Miles per hour symbol.
  static const String unitMph = 'mph';

  /// Percentage symbol.
  static const String unitPercent = '%';
}

