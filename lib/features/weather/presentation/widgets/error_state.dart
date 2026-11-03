import 'package:flutter/material.dart';
import '../../../../core/strings/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/failures/weather_failure.dart';

/// State widget displayed when an operation fails.
///
/// Features a muted red error icon, user-friendly message mapped from
/// typed [WeatherFailure] sealed members, and an optional retry action button.
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    this.failure,
    this.message,
    this.onRetry,
    this.icon = Icons.error_outline_rounded,
  });

  /// The underlying failure object or exception to map to a user-facing string.
  final Object? failure;

  /// Optional explicit message. When provided, takes precedence over [failure].
  final String? message;

  /// Optional callback invoked when the user taps the retry button.
  final VoidCallback? onRetry;

  /// Error glyph icon. Defaults to [Icons.error_outline_rounded].
  final IconData icon;

  /// Maps any [WeatherFailure] or general error to its designated string in [AppStrings].
  static String mapFailureToMessage(Object? error) {
    return switch (error) {
      NetworkFailure() => AppStrings.errorNoInternet,
      TimeoutFailure() => AppStrings.errorTimeout,
      NotFoundFailure() => AppStrings.errorNotFound,
      ServerFailure() => AppStrings.errorServer,
      CacheFailure() => AppStrings.errorCache,
      UnknownFailure() => AppStrings.errorUnknown,
      WeatherFailure(:final message) => message,
      _ => AppStrings.errorUnknown,
    };
  }

  @override
  Widget build(BuildContext context) {
    final displayMessage = message ?? mapFailureToMessage(failure);

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spaceXl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 64.0,
                color: AppColors.colorError,
              ),
              const SizedBox(height: AppDimensions.spaceLg),
              Text(
                displayMessage,
                style: AppTypography.body.copyWith(
                  color: AppColors.colorTextPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: AppDimensions.spaceLg),
                OutlinedButton(
                  onPressed: onRetry,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.colorAccentBlue,
                    side: const BorderSide(
                      color: AppColors.colorAccentBlue,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMd,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spaceXl,
                      vertical: AppDimensions.spaceMd,
                    ),
                  ),
                  child: const Text(AppStrings.retry),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

