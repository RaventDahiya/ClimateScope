import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_typography.dart';

/// ClimateScope Dark Theme definition. Light theme is intentionally unsupported.
abstract final class AppTheme {
  /// System UI overlay style for dark mode (light status & nav bar icons).
  static const SystemUiOverlayStyle systemUiOverlayStyle =
      SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: AppColors.colorBackground,
    systemNavigationBarIconBrightness: Brightness.light,
    systemNavigationBarDividerColor: Colors.transparent,
  );

  /// The singular dark theme configuration for ClimateScope.
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: AppTypography.fontFamily,
      scaffoldBackgroundColor: AppColors.colorBackground,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.colorSurface,
        primary: AppColors.colorAccentBlue,
        error: AppColors.colorError,
        onSurface: AppColors.colorTextPrimary,
        onPrimary: AppColors.colorTextPrimary,
        onError: AppColors.colorTextPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: systemUiOverlayStyle,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.colorBackground,
        modalBackgroundColor: AppColors.colorBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusXl),
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.colorDivider,
        thickness: 0.5,
        space: 1.0,
      ),
    );
  }
}

