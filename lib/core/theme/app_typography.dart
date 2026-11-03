import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Design system typography styles using the Inter font family.
abstract final class AppTypography {
  static const String fontFamily = 'Inter';

  /// 72sp, Bold (700): Main focal temperature display.
  static const TextStyle heroTemperature = TextStyle(
    fontFamily: fontFamily,
    fontSize: 72,
    fontWeight: FontWeight.w700,
    height: 1.0,
    letterSpacing: -2.0,
    color: AppColors.colorTextPrimary,
  );

  /// 18sp, Regular (400): Condition text below hero temperature.
  static const TextStyle heroCondition = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.0,
    color: AppColors.colorTextSecondary,
  );

  /// 22sp, SemiBold (600): Tappable city name in header.
  static const TextStyle headerCity = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0.0,
    color: AppColors.colorTextPrimary,
  );

  /// 14sp, Regular (400): City-local date and time in header.
  static const TextStyle headerTime = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.2,
    color: AppColors.colorTextSecondary,
  );

  /// 16sp, SemiBold (600): Section headers ("Today", "5 days").
  static const TextStyle sectionTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0.5,
    color: AppColors.colorTextPrimary,
  );

  /// 16sp, Regular (400): General body text, messages.
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.0,
    color: AppColors.colorTextPrimary,
  );

  /// 14sp, Medium (500): Metric card labels ("Wind", "Humidity").
  static const TextStyle label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.2,
    color: AppColors.colorTextSecondary,
  );

  /// 20sp, SemiBold (600): Metric card values.
  static const TextStyle metricValue = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.0,
    color: AppColors.colorTextPrimary,
  );

  /// 12sp, Regular (400): Timestamps, secondary notes, units.
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.3,
    color: AppColors.colorTextSecondary,
  );

  /// 14sp, Medium (500): Temperature label in hourly forecast slot.
  static const TextStyle hourlyTemp = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: 0.0,
    color: AppColors.colorTextPrimary,
  );

  /// 12sp, Regular (400): Hour label in hourly forecast slot.
  static const TextStyle hourlyTime = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.2,
    letterSpacing: 0.2,
    color: AppColors.colorTextSecondary,
  );

  /// 16sp, Medium (500): Weekday name in 5-day forecast list.
  static const TextStyle forecastDay = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.0,
    color: AppColors.colorTextPrimary,
  );

  /// 16sp, Regular (400): Min/max temperatures in 5-day forecast list.
  static const TextStyle forecastTemp = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.0,
    color: AppColors.colorTextPrimary,
  );
}

