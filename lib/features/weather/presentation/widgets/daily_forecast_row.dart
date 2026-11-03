import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/strings/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/weather_code_mapper.dart';
import '../../domain/enums/temperature_unit.dart';
import '../../domain/models/daily_forecast_model.dart';

/// Single day forecast row displaying weekday, weather icon, and min/max temperatures.
class DailyForecastRow extends StatelessWidget {
  const DailyForecastRow({
    super.key,
    required this.forecast,
    this.isToday = false,
    this.unit = TemperatureUnit.celsius,
  });

  /// Single day forecast data.
  final DailyForecastModel forecast;

  /// Whether this forecast row represents today.
  final bool isToday;

  /// Temperature measurement unit.
  final TemperatureUnit unit;

  @override
  Widget build(BuildContext context) {
    final info = WeatherCodeMapper.map(forecast.weatherCode);

    final dayLabel = isToday
        ? AppStrings.todaySectionTitle
        : DateFormat('EEE').format(forecast.date);

    final minTemp = unit == TemperatureUnit.fahrenheit
        ? (forecast.tempMin * 9 / 5 + 32).round()
        : forecast.tempMin.round();

    final maxTemp = unit == TemperatureUnit.fahrenheit
        ? (forecast.tempMax * 9 / 5 + 32).round()
        : forecast.tempMax.round();

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.spaceMd,
      ),
      child: Row(
        children: [
          // Weekday label
          SizedBox(
            width: 72,
            child: Text(
              dayLabel,
              style: AppTypography.forecastDay,
            ),
          ),
          // Condition icon with semantic label
          Icon(
            info.icon,
            size: AppDimensions.weatherIconSmall,
            color: info.tintColor,
            semanticLabel: info.conditionText,
          ),
          const Spacer(),
          // Min temperature (secondary color)
          Text(
            '$minTemp°',
            style: AppTypography.forecastTemp.copyWith(
              color: AppColors.colorTextSecondary,
            ),
          ),
          const SizedBox(width: AppDimensions.spaceLg),
          // Max temperature (primary color)
          SizedBox(
            width: 36,
            child: Text(
              '$maxTemp°',
              style: AppTypography.forecastTemp,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

