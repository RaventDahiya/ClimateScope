import 'package:flutter/material.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/unit_converter.dart';
import '../../../../core/utils/weather_code_mapper.dart';
import '../../domain/enums/temperature_unit.dart';

/// Focal hero section displaying the weather icon, temperature, and condition.
class WeatherHero extends StatelessWidget {
  const WeatherHero({
    super.key,
    required this.weatherCode,
    required this.temperature,
    this.unit = TemperatureUnit.celsius,
  });

  /// WMO weather interpretation code.
  final int weatherCode;

  /// Current temperature value (in Celsius).
  final double temperature;

  /// Display temperature unit.
  final TemperatureUnit unit;

  @override
  Widget build(BuildContext context) {
    final info = WeatherCodeMapper.map(weatherCode);

    final displayTemp = UnitConverter.temperatureValue(temperature, unit);

    return Padding(
      padding: const EdgeInsets.only(
        top: AppDimensions.spaceXl,
        bottom: AppDimensions.spaceXl,
        left: AppDimensions.spaceXl,
        right: AppDimensions.spaceXl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Centered hero weather icon container (160x160)
          SizedBox(
            width: AppDimensions.heroIconContainerSize,
            height: AppDimensions.heroIconContainerSize,
            child: Center(
              child: Icon(
                info.icon,
                size: AppDimensions.heroIconSize,
                color: info.tintColor,
                semanticLabel: info.conditionText,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spaceSm),
          // Focal temperature wrapped in FittedBox to prevent overflow at 2x text scale
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '$displayTemp${unit.symbol}',
              style: AppTypography.heroTemperature,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceXs),
          // Weather condition label
          Text(
            info.conditionText,
            style: AppTypography.heroCondition,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

