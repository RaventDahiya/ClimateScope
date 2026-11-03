import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:climate_scope/app.dart';
import 'package:climate_scope/core/constants/app_constants.dart';
import 'package:climate_scope/core/strings/app_strings.dart';
import 'package:climate_scope/core/theme/app_colors.dart';
import 'package:climate_scope/core/utils/unit_converter.dart';
import 'package:climate_scope/core/utils/weather_code_mapper.dart';
import 'package:climate_scope/features/weather/application/providers.dart';
import 'package:climate_scope/features/weather/application/weather_notifier.dart';
import 'package:climate_scope/features/weather/data/local/weather_local_storage.dart';
import 'package:climate_scope/features/weather/domain/enums/temperature_unit.dart';
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
import 'package:climate_scope/features/weather/presentation/widgets/daily_forecast_list.dart';
import 'package:climate_scope/features/weather/presentation/widgets/daily_forecast_row.dart';
import 'package:climate_scope/features/weather/presentation/widgets/hourly_slot.dart';
import 'package:climate_scope/features/weather/presentation/widgets/hourly_strip.dart';
import 'package:climate_scope/features/weather/presentation/widgets/metric_card.dart';
import 'package:climate_scope/features/weather/presentation/widgets/metric_cards_row.dart';
import 'package:climate_scope/features/weather/presentation/widgets/weather_header.dart';
import 'package:climate_scope/features/weather/presentation/widgets/weather_hero.dart';
import 'package:climate_scope/features/weather/presentation/widgets/weather_icon_glow.dart';

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

  // ── UnitConverter Tests ────────────────────────────────────────────────────

  group('UnitConverter', () {
    test('celsiusToFahrenheit converts 0°C → 32°F', () {
      expect(UnitConverter.celsiusToFahrenheit(0), 32.0);
    });

    test('celsiusToFahrenheit converts 100°C → 212°F', () {
      expect(UnitConverter.celsiusToFahrenheit(100), 212.0);
    });

    test('celsiusToFahrenheit converts negative (-40°C → -40°F)', () {
      expect(UnitConverter.celsiusToFahrenheit(-40), -40.0);
    });

    test('fahrenheitToCelsius converts 32°F → 0°C', () {
      expect(UnitConverter.fahrenheitToCelsius(32), closeTo(0.0, 0.001));
    });

    test('fahrenheitToCelsius converts 212°F → 100°C', () {
      expect(UnitConverter.fahrenheitToCelsius(212), closeTo(100.0, 0.001));
    });

    test('kmhToMph converts 100 km/h → ~62.1 mph', () {
      expect(UnitConverter.kmhToMph(100), closeTo(62.1371, 0.001));
    });

    test('mphToKmh converts 1 mph → ~1.60934 km/h', () {
      expect(UnitConverter.mphToKmh(1), closeTo(1.60934, 0.001));
    });

    test('formatTemperature returns Celsius string with symbol', () {
      expect(
        UnitConverter.formatTemperature(23.4, TemperatureUnit.celsius),
        '23°C',
      );
    });

    test('formatTemperature converts and returns Fahrenheit string with symbol',
        () {
      // 23.4°C → 74.12°F → round → 74°F
      expect(
        UnitConverter.formatTemperature(23.4, TemperatureUnit.fahrenheit),
        '74°F',
      );
    });

    test('formatWindSpeed returns km/h string for metric unit', () {
      expect(
        UnitConverter.formatWindSpeed(15.0, TemperatureUnit.celsius),
        '15 km/h',
      );
    });

    test('formatWindSpeed returns mph string for imperial unit', () {
      // 15 km/h * 0.621371 = 9.32 → round → 9 mph
      expect(
        UnitConverter.formatWindSpeed(15.0, TemperatureUnit.fahrenheit),
        '9 mph',
      );
    });

    test('temperatureValue returns rounded Celsius int for metric', () {
      expect(UnitConverter.temperatureValue(21.7, TemperatureUnit.celsius), 22);
    });

    test('temperatureValue converts and returns rounded Fahrenheit int', () {
      // 21.7°C → 71.06°F → round → 71
      expect(
        UnitConverter.temperatureValue(21.7, TemperatureUnit.fahrenheit),
        71,
      );
    });
  });

  // ── WeatherCodeMapper Tests ────────────────────────────────────────────────

  group('WeatherCodeMapper', () {
    test('maps code 0 to Clear Sky with yellow tint', () {
      final info = WeatherCodeMapper.map(0);
      expect(info.conditionText, 'Clear Sky');
      expect(info.tintColor, AppColors.colorWeatherYellow);
      expect(info.icon, Icons.wb_sunny_rounded);
    });

    test('maps code 63 to Moderate Rain with blue tint', () {
      final info = WeatherCodeMapper.map(63);
      expect(info.conditionText, 'Moderate Rain');
      expect(info.tintColor, AppColors.colorWeatherBlue);
    });

    test('maps code 95 to Thunderstorm with yellow tint', () {
      final info = WeatherCodeMapper.map(95);
      expect(info.conditionText, 'Thunderstorm');
      expect(info.tintColor, AppColors.colorWeatherYellow);
    });

    test('maps unknown code 999 to Unknown fallback', () {
      final info = WeatherCodeMapper.map(999);
      expect(info.conditionText, 'Unknown');
      expect(info.icon, Icons.help_outline_rounded);
      expect(info.tintColor, AppColors.colorTextSecondary);
    });

    test('maps code 71 to Slight Snow with white tint', () {
      final info = WeatherCodeMapper.map(71);
      expect(info.conditionText, 'Slight Snow');
      expect(info.tintColor, AppColors.colorWeatherWhite);
    });
  });

  // ── Phase 7: Design Polish Tests ──────────────────────────────────────────

  group('Phase 7: WeatherIconGlow', () {
    testWidgets('renders radial glow and icon for clear sky (code 0)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WeatherIconGlow(weatherCode: 0),
          ),
        ),
      );

      final containerFinder = find.byType(Container);
      expect(containerFinder, findsOneWidget);
      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.gradient, isA<RadialGradient>());
      final gradient = decoration.gradient as RadialGradient;
      expect(gradient.colors.first, const Color(0xFFFACC15).withOpacity(0.20));
      expect(gradient.colors.last, Colors.transparent);

      final iconFinder = find.byIcon(Icons.wb_sunny_rounded);
      expect(iconFinder, findsOneWidget);
      final icon = tester.widget<Icon>(iconFinder);
      expect(icon.color, AppColors.colorWeatherYellow);
      expect(icon.semanticLabel, 'Clear Sky');
    });

    testWidgets('renders blue glow and water drop icon for rain (code 63)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WeatherIconGlow(weatherCode: 63),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      final gradient = decoration.gradient as RadialGradient;
      expect(gradient.colors.first, const Color(0xFF3B82F6).withOpacity(0.18));

      final iconFinder = find.byIcon(Icons.water_drop_rounded);
      expect(iconFinder, findsOneWidget);
      final icon = tester.widget<Icon>(iconFinder);
      expect(icon.color, AppColors.colorWeatherBlue);
      expect(icon.semanticLabel, 'Moderate Rain');
    });
  });

  group('Phase 7: WeatherHero', () {
    testWidgets('renders icon glow, temperature with unit, and condition text',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WeatherHero(
              weatherCode: 0,
              temperature: 22.4,
              unit: TemperatureUnit.celsius,
            ),
          ),
        ),
      );

      expect(find.byType(WeatherIconGlow), findsOneWidget);
      expect(find.text('22°C'), findsOneWidget);
      expect(find.text('Clear Sky'), findsOneWidget);
    });

    testWidgets('converts temperature when TemperatureUnit.fahrenheit is passed',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WeatherHero(
              weatherCode: 0,
              temperature: 0.0,
              unit: TemperatureUnit.fahrenheit,
            ),
          ),
        ),
      );

      expect(find.text('32°F'), findsOneWidget);
    });
  });

  group('Phase 7: HourlySlot', () {
    final slotModel = HourlyForecastModel(
      time: DateTime(2026, 11, 3, 15),
      temperature: 18.0,
      weatherCode: 2,
    );

    testWidgets('renders default unselected state with colorSurfaceVariant',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HourlySlot(
              forecast: slotModel,
              isSelected: false,
              onTap: () {},
            ),
          ),
        ),
      );

      final container = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.colorSurfaceVariant);
      expect(find.text('3 PM'), findsOneWidget);
      expect(find.text('18°'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_rounded), findsOneWidget);
    });

    testWidgets('renders selected state with colorAccentBlue and fires onTap',
        (WidgetTester tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HourlySlot(
              forecast: slotModel,
              isSelected: true,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      final container = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.colorAccentBlue);

      await tester.tap(find.byType(HourlySlot));
      expect(tapped, isTrue);
    });
  });

  group('Phase 7: HourlyStrip', () {
    test('filterNext24Hours slices 24 slots starting from current hour', () {
      final reference = DateTime(2026, 11, 3, 10, 15);
      final all = List.generate(
        120,
        (i) => HourlyForecastModel(
          time: DateTime(2026, 11, 3).add(Duration(hours: i)),
          temperature: 20.0 + i,
          weatherCode: 0,
        ),
      );

      final sliced = HourlyStrip.filterNext24Hours(all, reference);
      expect(sliced.length, 24);
      expect(sliced.first.time.hour, 10);
      expect(sliced.last.time.hour, 9); // next day 9 AM (24 hours)
    });

    test('filterNext24Hours safely returns short lists', () {
      final shortList = [
        HourlyForecastModel(
          time: DateTime(2026, 11, 3, 12),
          temperature: 15.0,
          weatherCode: 0,
        ),
      ];

      final result = HourlyStrip.filterNext24Hours(shortList);
      expect(result.length, 1);
    });

    testWidgets('renders horizontal list and updates selection on tap',
        (WidgetTester tester) async {
      final hourlyList = List.generate(
        24,
        (i) => HourlyForecastModel(
          time: DateTime(2026, 11, 3, i),
          temperature: 15.0 + i,
          weatherCode: 0,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HourlyStrip(
              hourlyForecasts: hourlyList,
              referenceTime: DateTime(2026, 11, 3, 0),
            ),
          ),
        ),
      );

      expect(find.text(AppStrings.todaySectionTitle), findsOneWidget);
      expect(find.byType(HourlySlot), findsWidgets);

      // First slot is selected initially
      final firstSlot = tester.widget<HourlySlot>(find.byType(HourlySlot).first);
      expect(firstSlot.isSelected, isTrue);

      // Tap the second slot
      await tester.tap(find.byType(HourlySlot).at(1));
      await tester.pumpAndSettle();

      final updatedFirstSlot = tester.widget<HourlySlot>(find.byType(HourlySlot).first);
      final updatedSecondSlot = tester.widget<HourlySlot>(find.byType(HourlySlot).at(1));
      expect(updatedFirstSlot.isSelected, isFalse);
      expect(updatedSecondSlot.isSelected, isTrue);
    });
  });

  group('Phase 7: MetricCardsRow & MetricCard', () {
    testWidgets('renders Wind and Humidity cards with values and units',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MetricCardsRow(
              windSpeed: 25.0,
              humidity: 80,
              unit: TemperatureUnit.celsius,
            ),
          ),
        ),
      );

      expect(find.text(AppStrings.windLabel), findsOneWidget);
      expect(find.text('25 km/h'), findsOneWidget);
      expect(find.byIcon(Icons.air_rounded), findsOneWidget);

      expect(find.text(AppStrings.humidityLabel), findsOneWidget);
      expect(find.text('80%'), findsOneWidget);
      expect(find.byIcon(Icons.water_drop_rounded), findsOneWidget);
    });

    testWidgets('formats wind in mph when TemperatureUnit.fahrenheit',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MetricCardsRow(
              windSpeed: 100.0,
              humidity: 50,
              unit: TemperatureUnit.fahrenheit,
            ),
          ),
        ),
      );

      expect(find.text('62 mph'), findsOneWidget);
    });
  });

  group('Phase 7: DailyForecastList & DailyForecastRow', () {
    testWidgets('renders 5 daily forecast rows with dividers between them',
        (WidgetTester tester) async {
      final forecasts = List.generate(
        5,
        (i) => DailyForecastModel(
          date: DateTime(2026, 11, 3 + i),
          weatherCode: 0,
          tempMin: 12.0 + i,
          tempMax: 20.0 + i,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DailyForecastList(dailyForecasts: forecasts),
          ),
        ),
      );

      expect(find.text(AppStrings.fiveDaysSectionTitle), findsOneWidget);
      expect(find.byType(DailyForecastRow), findsNWidgets(5));
      expect(find.byType(Divider), findsNWidgets(4));
      expect(find.text(AppStrings.todaySectionTitle), findsOneWidget);
    });
  });

  group('Phase 7: WeatherHeader', () {
    testWidgets('renders city, chevron, and date, fires onTapCity',
        (WidgetTester tester) async {
      var cityTapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeatherHeader(
              cityName: 'Tokyo',
              dateTime: DateTime(2026, 11, 3, 14, 30),
              onTapCity: () => cityTapped = true,
              isLastUpdated: false,
            ),
          ),
        ),
      );

      expect(find.text('Tokyo'), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsOneWidget);
      expect(find.text('Tuesday, Nov 3'), findsOneWidget);

      await tester.tap(find.text('Tokyo'));
      expect(cityTapped, isTrue);
    });

    testWidgets('shows Last updated: format when isLastUpdated is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeatherHeader(
              cityName: 'Paris',
              dateTime: DateTime(2026, 11, 3, 14, 30),
              onTapCity: () {},
              isLastUpdated: true,
            ),
          ),
        ),
      );

      expect(find.text('Paris'), findsOneWidget);
      expect(find.text('Last updated: 2:30 PM'), findsOneWidget);
    });
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
