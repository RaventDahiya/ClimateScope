import 'package:flutter/material.dart';
import '../../../../core/strings/app_strings.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/enums/temperature_unit.dart';
import '../../domain/models/hourly_forecast_model.dart';
import 'hourly_slot.dart';

/// Horizontally scrolling hourly forecast strip displaying the next ~24 hours.
///
/// Features lazy rendering via [ListView.separated], animated selection state,
/// and responsive touch feedback.
class HourlyStrip extends StatefulWidget {
  const HourlyStrip({
    super.key,
    required this.hourlyForecasts,
    this.unit = TemperatureUnit.celsius,
    this.referenceTime,
  });

  /// Full hourly forecast list from the API or cache.
  final List<HourlyForecastModel> hourlyForecasts;

  /// Temperature measurement unit.
  final TemperatureUnit unit;

  /// Optional reference time for testing or timezone synchronization.
  /// Defaults to [DateTime.now()].
  final DateTime? referenceTime;

  /// Slices the hourly forecast to the next ~24 hours starting from [referenceTime].
  static List<HourlyForecastModel> filterNext24Hours(
    List<HourlyForecastModel> all, [
    DateTime? referenceTime,
  ]) {
    if (all.isEmpty) return const [];
    if (all.length <= 24) return all;

    final now = referenceTime ?? DateTime.now();

    var startIndex = 0;
    for (var i = 0; i < all.length; i++) {
      final slotTime = all[i].time;
      if (slotTime.isAfter(now.subtract(const Duration(minutes: 59)))) {
        startIndex = i;
        break;
      }
    }

    if (startIndex + 24 > all.length) {
      startIndex = (all.length - 24).clamp(0, all.length);
    }

    final endIndex = (startIndex + 24).clamp(0, all.length);
    return all.sublist(startIndex, endIndex);
  }

  @override
  State<HourlyStrip> createState() => _HourlyStripState();
}

class _HourlyStripState extends State<HourlyStrip> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final slots = HourlyStrip.filterNext24Hours(
      widget.hourlyForecasts,
      widget.referenceTime,
    );

    if (slots.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.spaceSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Section header ("Today")
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.spaceXl,
            ),
            child: Text(
              AppStrings.todaySectionTitle,
              style: AppTypography.sectionTitle,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceMd),
          // Horizontal scrolling strip (ListView.separated for performance)
          SizedBox(
            height: 104,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spaceXl,
              ),
              itemCount: slots.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(width: AppDimensions.spaceSm),
              itemBuilder: (context, index) {
                return HourlySlot(
                  forecast: slots[index],
                  isSelected: _selectedIndex == index,
                  unit: widget.unit,
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

