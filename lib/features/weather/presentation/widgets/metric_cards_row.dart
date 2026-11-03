import 'package:flutter/material.dart';
import '../../../../core/strings/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/enums/temperature_unit.dart';
import 'metric_card.dart';

/// Row containing Wind and Humidity [MetricCard] widgets side-by-side.
class MetricCardsRow extends StatelessWidget {
  const MetricCardsRow({
    super.key,
    required this.windSpeed,
    required this.humidity,
    this.unit = TemperatureUnit.celsius,
  });

  /// Wind speed in km/h (API base unit).
  final double windSpeed;

  /// Relative humidity percentage (0–100).
  final int humidity;

  /// Temperature/measurement unit.
  final TemperatureUnit unit;

  @override
  Widget build(BuildContext context) {
    final isImperial = unit == TemperatureUnit.fahrenheit;
    final displayWind = isImperial
        ? '${(windSpeed * 0.621371).round()} ${AppStrings.unitMph}'
        : '${windSpeed.round()} ${AppStrings.unitKmh}';

    final displayHumidity = '$humidity${AppStrings.unitPercent}';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceXl,
        vertical: AppDimensions.spaceSm,
      ),
      child: Row(
        children: [
          Expanded(
            child: MetricCard(
              icon: Icons.air_rounded,
              iconColor: AppColors.colorTextSecondary,
              label: AppStrings.windLabel,
              value: displayWind,
            ),
          ),
          const SizedBox(width: AppDimensions.spaceMd),
          Expanded(
            child: MetricCard(
              icon: Icons.water_drop_rounded,
              iconColor: AppColors.colorAccentBlue,
              label: AppStrings.humidityLabel,
              value: displayHumidity,
            ),
          ),
        ],
      ),
    );
  }
}

