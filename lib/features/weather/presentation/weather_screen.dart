import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/strings/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../application/providers.dart';
import 'sheets/search_bottom_sheet.dart';
import 'widgets/daily_forecast_list.dart';
import 'widgets/metric_cards_row.dart';
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
                cityName: weatherAsync.valueOrNull?.city.name ?? AppStrings.appName,
                dateTime: weatherAsync.valueOrNull?.lastUpdated ?? DateTime.now(),
                onTapCity: () => SearchBottomSheet.show(context),
              ),
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.colorAccentBlue,
                  ),
                ),
              ),
            ],
          ),
          error: (error, _) => Column(
            children: [
              WeatherHeader(
                cityName: weatherAsync.valueOrNull?.city.name ?? AppStrings.appName,
                dateTime: weatherAsync.valueOrNull?.lastUpdated ?? DateTime.now(),
                onTapCity: () => SearchBottomSheet.show(context),
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.spaceXl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          size: 64,
                          color: AppColors.colorError,
                        ),
                        const SizedBox(height: AppDimensions.spaceLg),
                        Text(
                          error.toString().replaceFirst('Exception: ', ''),
                          style: AppTypography.body,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppDimensions.spaceLg),
                        OutlinedButton(
                          onPressed: () {
                            final currentCity = weatherAsync.valueOrNull?.city;
                            if (currentCity != null) {
                              ref
                                  .read(weatherNotifierProvider.notifier)
                                  .fetchWeather(currentCity);
                            } else {
                              SearchBottomSheet.show(context);
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.colorAccentBlue,
                            side: const BorderSide(
                              color: AppColors.colorAccentBlue,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusMd,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.spaceXl,
                              vertical: AppDimensions.spaceMd,
                            ),
                          ),
                          child: const Text(AppStrings.retry),
                        ),
                      ],
                    ),
                  ),
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
                    child: Center(
                      child: InkWell(
                        onTap: () => SearchBottomSheet.show(context),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusLg,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(
                            AppDimensions.spaceXl,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.search_rounded,
                                size: 64,
                                color: AppColors.colorTextSecondary,
                              ),
                              const SizedBox(height: AppDimensions.spaceLg),
                              Text(
                                AppStrings.emptySearchPrompt,
                                style: AppTypography.body.copyWith(
                                  color: AppColors.colorTextSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
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
