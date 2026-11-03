import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';

/// Centered loading state view displaying a brand-tinted progress indicator.
///
/// Used across full-screen views (e.g. `WeatherScreen`) and modal sheets
/// (e.g. `SearchBottomSheet`) during asynchronous operations.
class LoadingState extends StatelessWidget {
  const LoadingState({
    super.key,
    this.padding = const EdgeInsets.all(AppDimensions.spaceXl),
  });

  /// Optional padding around the progress indicator. Defaults to [AppDimensions.spaceXl].
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding,
        child: const CircularProgressIndicator(
          color: AppColors.colorAccentBlue,
        ),
      ),
    );
  }
}

