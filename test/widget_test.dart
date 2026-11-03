import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:climate_scope/app.dart';
import 'package:climate_scope/core/constants/app_constants.dart';
import 'package:climate_scope/core/strings/app_strings.dart';
import 'package:climate_scope/core/theme/app_colors.dart';
import 'package:climate_scope/features/weather/application/providers.dart';
import 'package:climate_scope/features/weather/application/weather_notifier.dart';
import 'package:climate_scope/features/weather/data/local/weather_local_storage.dart';
import 'package:climate_scope/features/weather/domain/failures/weather_failure.dart';
import 'package:climate_scope/features/weather/domain/models/city_model.dart';
import 'package:climate_scope/features/weather/domain/models/current_weather_model.dart';
import 'package:climate_scope/features/weather/domain/models/daily_forecast_model.dart';
import 'package:climate_scope/features/weather/domain/models/hourly_forecast_model.dart';
import 'package:climate_scope/features/weather/domain/models/weather_data_model.dart';
import 'package:climate_scope/features/weather/presentation/weather_screen.dart';
import 'package:climate_scope/features/weather/presentation/widgets/empty_state.dart';
import 'package:climate_scope/features/weather/presentation/widgets/error_state.dart';
import 'package:climate_scope/features/weather/presentation/widgets/loading_state.dart';
import 'package:climate_scope/features/weather/presentation/widgets/offline_banner.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final dummyCity = const CityModel(
    name: 'Berlin',
    latitude: 52.52,
    longitude: 13.41,
    country: 'Germany',
    admin1: 'Berlin',
  );

  final dummyWeather = WeatherDataModel(
    current: const CurrentWeatherModel(
      temperature: 21.5,
      humidity: 65,
      weatherCode: 0,
      windSpeed: 12.0,
    ),
    dailyForecasts: [
      DailyForecastModel(
        date: DateTime(2026, 11, 3),
        weatherCode: 0,
        tempMin: 10.0,
        tempMax: 22.0,
      ),
    ],
    hourlyForecasts: [
      HourlyForecastModel(
        time: DateTime(2026, 11, 3, 14),
        temperature: 21.0,
        weatherCode: 0,
      ),
    ],
    city: dummyCity,
    timezone: 'Europe/Berlin',
    lastUpdated: DateTime(2026, 11, 3, 14, 30),
    isFromCache: true,
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('ClimateScopeApp smoke test verifies launch and empty state',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ClimateScopeApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.appName), findsOneWidget);
    expect(find.text(AppStrings.emptySearchPrompt), findsOneWidget);
    expect(find.byIcon(Icons.search_rounded), findsOneWidget);
  });

  testWidgets('LoadingState renders CircularProgressIndicator with accent blue',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LoadingState(),
        ),
      ),
    );

    final indicatorFinder = find.byType(CircularProgressIndicator);
    expect(indicatorFinder, findsOneWidget);

    final indicator = tester.widget<CircularProgressIndicator>(indicatorFinder);
    expect(indicator.color, AppColors.colorAccentBlue);
  });

  testWidgets('EmptyState displays message and calls onTap',
      (WidgetTester tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EmptyState(
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text(AppStrings.emptySearchPrompt), findsOneWidget);
    expect(find.byIcon(Icons.search_rounded), findsOneWidget);

    await tester.tap(find.byType(InkWell));
    expect(tapped, isTrue);
  });

  testWidgets(
      'ErrorState maps NetworkFailure to errorNoInternet and fires onRetry',
      (WidgetTester tester) async {
    var retried = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ErrorState(
            failure: const NetworkFailure(),
            onRetry: () => retried = true,
          ),
        ),
      ),
    );

    expect(find.text(AppStrings.errorNoInternet), findsOneWidget);
    expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    expect(find.text(AppStrings.retry), findsOneWidget);

    await tester.tap(find.text(AppStrings.retry));
    expect(retried, isTrue);
  });

  testWidgets('ErrorState maps TimeoutFailure to errorTimeout',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ErrorState(
            failure: TimeoutFailure(),
          ),
        ),
      ),
    );

    expect(find.text(AppStrings.errorTimeout), findsOneWidget);
    expect(find.byType(OutlinedButton), findsNothing);
  });

  testWidgets('OfflineBanner displays icon and staleness timestamp',
      (WidgetTester tester) async {
    final timestamp = DateTime(2026, 11, 3, 14, 30);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OfflineBanner(lastUpdated: timestamp),
        ),
      ),
    );

    expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);
    expect(
      find.text(
        '${AppStrings.dataMayBeOutdated}${AppStrings.bannerSeparator}${AppStrings.lastUpdatedPrefix}2:30 PM',
      ),
      findsOneWidget,
    );
  });

  test('WeatherLocalStorage successfully saves and retrieves cached weather',
      () async {
    final storage = WeatherLocalStorage();
    final saved = await storage.saveWeatherData(dummyWeather);
    expect(saved, isTrue);

    final loaded = await storage.getCachedWeatherData();
    expect(loaded, isNotNull);
    expect(loaded!.city.name, 'Berlin');
    expect(loaded.isFromCache, isTrue);
    expect(loaded.current.temperature, 21.5);
  });

  test('WeatherLocalStorage gracefully purges corrupted JSON and returns null',
      () async {
    SharedPreferences.setMockInitialValues({
      AppConstants.cacheKeyWeatherData: '{invalid_json',
    });

    final storage = WeatherLocalStorage();
    final loaded = await storage.getCachedWeatherData();
    expect(loaded, isNull);

    // Verify key was purged
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey(AppConstants.cacheKeyWeatherData), isFalse);
  });

  test(
      'WeatherLocalStorage gracefully purges schema version mismatch and returns null',
      () async {
    final mismatchedJson = jsonEncode({
      'cacheVersion': 99,
      'city': dummyCity.toJson(),
    });

    SharedPreferences.setMockInitialValues({
      AppConstants.cacheKeyWeatherData: mismatchedJson,
    });

    final storage = WeatherLocalStorage();
    final loaded = await storage.getCachedWeatherData();
    expect(loaded, isNull);

    // Verify key was purged
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey(AppConstants.cacheKeyWeatherData), isFalse);
  });

  testWidgets(
      'WeatherScreen renders OfflineBanner and last updated header when isFromCache is true',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          weatherNotifierProvider.overrideWith(
            () => _FakeWeatherNotifier(dummyWeather),
          ),
        ],
        child: const MaterialApp(
          home: WeatherScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Berlin'), findsOneWidget);
    expect(find.byType(OfflineBanner), findsOneWidget);
    expect(
      find.text('${AppStrings.lastUpdatedPrefix}2:30 PM'),
      findsOneWidget,
    );
  });
}

class _FakeWeatherNotifier extends WeatherNotifier {
  _FakeWeatherNotifier(this._initialData);
  final WeatherDataModel? _initialData;

  @override
  Future<WeatherDataModel?> build() async {
    return _initialData;
  }
}
