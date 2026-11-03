import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/strings/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';

/// Top header widget displaying the city name selector and current date/time.
///
/// Tapping the city name triggers [onTapCity], opening the search sheet.
class WeatherHeader extends StatelessWidget {
  const WeatherHeader({
    super.key,
    required this.cityName,
    required this.dateTime,
    required this.onTapCity,
    this.isLastUpdated = false,
  });

  /// Selected city name.
  final String cityName;

  /// Reference date/time (city-local time or last-updated timestamp).
  final DateTime dateTime;

  /// Callback when user taps the city name selector.
  final VoidCallback onTapCity;

  /// Whether [dateTime] represents a cached last-updated timestamp.
  final bool isLastUpdated;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, MMM d');
    final timeFormat = DateFormat('h:mm a');
    final subtitleText = isLastUpdated
        ? '${AppStrings.lastUpdatedPrefix}${timeFormat.format(dateTime)}'
        : dateFormat.format(dateTime);

    return Padding(
      padding: const EdgeInsets.only(
        left: AppDimensions.spaceXl,
        right: AppDimensions.spaceXl,
        top: AppDimensions.spaceLg,
        bottom: AppDimensions.spaceSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tappable city selector with accessible minimum tap target
          ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppDimensions.minTapTargetSize,
            ),
            child: InkWell(
              onTap: onTapCity,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.spaceXs,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        cityName,
                        style: AppTypography.headerCity,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spaceXs),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.colorTextSecondary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spaceXs),
          Text(
            subtitleText,
            style: AppTypography.headerTime,
          ),
        ],
      ),
    );
  }
}

