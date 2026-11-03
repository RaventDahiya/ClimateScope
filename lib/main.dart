import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure system UI overlay for dark mode (transparent status bar, light icons).
  SystemChrome.setSystemUIOverlayStyle(AppTheme.systemUiOverlayStyle);

  runApp(
    const ProviderScope(
      child: ClimateScopeApp(),
    ),
  );
}
