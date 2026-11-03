import 'package:flutter/material.dart';
import '../../../../core/strings/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/enums/temperature_unit.dart';
import '../../domain/models/daily_forecast_model.dart';
import 'daily_forecast_row.dart';

/// 5-day daily forecast container widget.
class DailyForecastList extends StatelessWidget {
  const DailyForecastList({
    super.key,
    required this.dailyForecasts,
    this.unit = TemperatureUnit.celsius,
  });

  /// 5-day forecast entries from API.
  final List<DailyForecastModel> dailyForecasts;

  /// Selected temperature unit.
  final TemperatureUnit unit;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceXl,
        vertical: AppDimensions.spaceSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Section header ("5 days")
          const Text(
            AppStrings.fiveDaysSectionTitle,
            style: AppTypography.sectionTitle,
          ),
          const SizedBox(height: AppDimensions.spaceMd),
          // Rounded container enclosing the daily rows
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spaceLg,
              vertical: AppDimensions.spaceSm,
            ),
            decoration: BoxDecoration(
              color: AppColors.colorSurface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < dailyForecasts.length; i++) ...[
                  DailyForecastRow(
                    forecast: dailyForecasts[i],
                    isToday: i == 0 ||
                        (dailyForecasts[i].date.year == now.year &&
                            dailyForecasts[i].date.month == now.month &&
                            dailyForecasts[i].date.day == now.day),
                    unit: unit,
                  ),
                  if (i < dailyForecasts.length - 1)
                    const Divider(
                      color: AppColors.colorDivider,
                      height: 1,
                      thickness: 0.5,
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

