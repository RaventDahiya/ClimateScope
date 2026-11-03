import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/strings/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../application/providers.dart';
import 'sheets/search_bottom_sheet.dart';
import 'widgets/daily_forecast_list.dart';
import 'widgets/empty_state.dart';
import 'widgets/error_state.dart';
import 'widgets/loading_state.dart';
import 'widgets/metric_cards_row.dart';
import 'widgets/offline_banner.dart';
import 'widgets/weather_header.dart';
import 'widgets/weather_hero.dart';

/// Primary weather screen of ClimateScope.
///
/// Observes [weatherNotifierProvider] and [settingsNotifierProvider] to render
/// header, current weather hero, metrics, and 5-day daily forecast.
class WeatherScreen extends ConsumerWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherNotifierProvider);
    final unit = ref.watch(settingsNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.colorBackground,
      body: SafeArea(
        child: weatherAsync.when(
          loading: () => Column(
            children: [
              WeatherHeader(
                cityName: weatherAsync.valueOrNull?.city.name ??
                    ref.read(weatherNotifierProvider.notifier).selectedCity?.name ??
                    AppStrings.appName,
                dateTime: weatherAsync.valueOrNull?.lastUpdated ?? DateTime.now(),
                onTapCity: () => SearchBottomSheet.show(context),
                isLastUpdated: weatherAsync.valueOrNull?.isFromCache ?? false,
              ),
              const Expanded(
                child: LoadingState(),
              ),
            ],
          ),
          error: (error, _) => Column(
            children: [
              WeatherHeader(
                cityName: weatherAsync.valueOrNull?.city.name ??
                    ref.read(weatherNotifierProvider.notifier).selectedCity?.name ??
                    AppStrings.appName,
                dateTime: weatherAsync.valueOrNull?.lastUpdated ?? DateTime.now(),
                onTapCity: () => SearchBottomSheet.show(context),
                isLastUpdated: weatherAsync.valueOrNull?.isFromCache ?? false,
              ),
              Expanded(
                child: ErrorState(
                  failure: error,
                  onRetry: () {
                    final notifier = ref.read(weatherNotifierProvider.notifier);
                    final currentCity = notifier.selectedCity;
                    if (currentCity != null) {
                      notifier.fetchWeather(currentCity);
                    } else {
                      SearchBottomSheet.show(context);
                    }
                  },
                ),
              ),
            ],
          ),
          data: (weather) {
            if (weather == null) {
              // Empty state on first launch before any search
              return Column(
                children: [
                  WeatherHeader(
                    cityName: AppStrings.appName,
                    dateTime: DateTime.now(),
                    onTapCity: () => SearchBottomSheet.show(context),
                  ),
                  Expanded(
                    child: EmptyState(
                      onTap: () => SearchBottomSheet.show(context),
                    ),
                  ),
                ],
              );
            }

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: WeatherHeader(
                    cityName: weather.city.name,
                    dateTime: weather.lastUpdated,
                    onTapCity: () => SearchBottomSheet.show(context),
                    isLastUpdated: weather.isFromCache,
                  ),
                ),
                if (weather.isFromCache)
                  SliverToBoxAdapter(
                    child: OfflineBanner(
                      lastUpdated: weather.lastUpdated,
                    ),
                  ),
                SliverToBoxAdapter(
                  child: WeatherHero(
                    weatherCode: weather.current.weatherCode,
                    temperature: weather.current.temperature,
                    unit: unit,
                  ),
                ),
                SliverToBoxAdapter(
                  child: MetricCardsRow(
                    windSpeed: weather.current.windSpeed,
                    humidity: weather.current.humidity,
                    unit: unit,
                  ),
                ),
                SliverToBoxAdapter(
                  child: DailyForecastList(
                    dailyForecasts: weather.dailyForecasts,
                    unit: unit,
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppDimensions.spaceXxl),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
