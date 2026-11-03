import 'package:flutter/material.dart';
import 'core/strings/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'features/weather/presentation/weather_screen.dart';

/// Root application widget configuring dark theme and home screen.
class ClimateScopeApp extends StatelessWidget {
  const ClimateScopeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const WeatherScreen(),
    );
  }
}

