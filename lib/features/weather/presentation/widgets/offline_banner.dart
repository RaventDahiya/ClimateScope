import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/strings/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';

/// Full-bleed banner indicating that displayed weather data is loaded from cache.
///
/// Displayed at the top of scrollable content when offline or showing cached data.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({
    super.key,
    required this.lastUpdated,
  });

  /// The timestamp of the last successful data fetch.
  final DateTime lastUpdated;

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('h:mm a');
    final formattedTime = timeFormat.format(lastUpdated);
    final bannerText =
        '${AppStrings.dataMayBeOutdated}${AppStrings.bannerSeparator}${AppStrings.lastUpdatedPrefix}$formattedTime';

    return Container(
      width: double.infinity,
      color: AppColors.colorOfflineBanner,
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.spaceSm,
        horizontal: AppDimensions.spaceLg,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 16,
            color: AppColors.colorTextSecondary,
          ),
          const SizedBox(width: AppDimensions.spaceSm),
          Flexible(
            child: Text(
              bannerText,
              style: AppTypography.caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
