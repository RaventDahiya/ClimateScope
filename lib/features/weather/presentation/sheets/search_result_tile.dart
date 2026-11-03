import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/city_model.dart';

/// Single search result tile displaying city name and admin1/country disambiguation.
class SearchResultTile extends StatelessWidget {
  const SearchResultTile({
    super.key,
    required this.city,
    required this.onTap,
  });

  /// The matched city domain model.
  final CityModel city;

  /// Callback when user selects this city.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final subtitle = city.admin1 != null && city.admin1!.trim().isNotEmpty
        ? '${city.admin1}, ${city.country}'
        : city.country;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: AppDimensions.minTapTargetSize,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceLg,
            vertical: AppDimensions.spaceMd,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                city.name,
                style: AppTypography.body,
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.spaceXs),
                Text(
                  subtitle,
                  style: AppTypography.caption,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

