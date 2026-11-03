import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/unit_converter.dart';
import '../../../../core/utils/weather_code_mapper.dart';
import '../../domain/enums/temperature_unit.dart';
import '../../domain/models/hourly_forecast_model.dart';

/// Single interactive hourly forecast slot within the horizontal [HourlyStrip].
///
/// Features smooth animated selection highlighting, WMO-tinted condition icons,
/// and accessible screen reader semantics.
class HourlySlot extends StatelessWidget {
  const HourlySlot({
    super.key,
    required this.forecast,
    required this.isSelected,
    required this.onTap,
    this.unit = TemperatureUnit.celsius,
  });

  /// The hourly forecast domain model.
  final HourlyForecastModel forecast;

  /// Whether this slot is currently highlighted/selected.
  final bool isSelected;

  /// Callback when user taps this slot.
  final VoidCallback onTap;

  /// Temperature display unit.
  final TemperatureUnit unit;

  @override
  Widget build(BuildContext context) {
    final info = WeatherCodeMapper.map(forecast.weatherCode);
    final timeLabel = DateFormat('h a').format(forecast.time);
    final tempValue = UnitConverter.temperatureValue(forecast.temperature, unit);

    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final animationDuration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 200);

    return Semantics(
      button: true,
      selected: isSelected,
      label: '$timeLabel, ${info.conditionText}, $tempValue degrees',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          child: AnimatedContainer(
            duration: animationDuration,
            curve: Curves.easeOut,
            width: AppDimensions.hourlySlotWidth,
            padding: const EdgeInsets.symmetric(
              vertical: AppDimensions.spaceSm,
              horizontal: AppDimensions.spaceXs,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.colorAccentBlue
                  : AppColors.colorSurfaceVariant,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Hour label (e.g. "2 PM")
                Text(
                  timeLabel,
                  style: isSelected
                      ? AppTypography.hourlyTime.copyWith(
                          color: AppColors.colorTextPrimary,
                        )
                      : AppTypography.hourlyTime,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDimensions.spaceSm),
                // Condition icon with semantic label
                Icon(
                  info.icon,
                  size: AppDimensions.weatherIconSmall,
                  color: isSelected
                      ? AppColors.colorTextPrimary
                      : info.tintColor,
                  semanticLabel: info.conditionText,
                ),
                const SizedBox(height: AppDimensions.spaceSm),
                // Hourly temperature
                Text(
                  '$tempValue°',
                  style: AppTypography.hourlyTemp,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
