import 'package:flutter/material.dart';
import '../../../../core/strings/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';

/// State widget displayed when no data is available or before a user has initiated a search.
///
/// Features a centered icon, informative message, and an optional [onTap] handler
/// that wraps the content in an accessible [InkWell] for interactive prompts.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    this.icon = Icons.search_rounded,
    this.message = AppStrings.emptySearchPrompt,
    this.onTap,
  });

  /// Icon indicating the empty condition. Defaults to [Icons.search_rounded].
  final IconData icon;

  /// User-facing descriptive message. Defaults to [AppStrings.emptySearchPrompt].
  final String message;

  /// Optional tap handler (e.g. to open search modal).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.all(AppDimensions.spaceXl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64.0,
            color: AppColors.colorTextSecondary,
          ),
          const SizedBox(height: AppDimensions.spaceLg),
          Text(
            message,
            style: AppTypography.body.copyWith(
              color: AppColors.colorTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

    if (onTap != null) {
      return Center(
        child: SingleChildScrollView(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            child: content,
          ),
        ),
      );
    }

    return Center(
      child: SingleChildScrollView(
        child: content,
      ),
    );
  }
}
