import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';

/// Single metric card displaying an icon, label, and formatted value with units.
class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceLg),
      decoration: BoxDecoration(
        color: AppColors.colorSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: AppDimensions.weatherIconSmall,
            color: iconColor,
          ),
          const SizedBox(height: AppDimensions.spaceSm),
          Text(
            label,
            style: AppTypography.label,
          ),
          const SizedBox(height: AppDimensions.spaceXs),
          Text(
            value,
            style: AppTypography.metricValue,
          ),
        ],
      ),
    );
  }
}

