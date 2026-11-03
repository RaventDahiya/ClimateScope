import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/strings/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Main weather screen for ClimateScope.
class WeatherScreen extends ConsumerWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      backgroundColor: AppColors.colorBackground,
      body: SafeArea(
        child: Center(
          child: Text(
            AppStrings.appName,
            style: AppTypography.headerCity,
          ),
        ),
      ),
    );
  }
}

