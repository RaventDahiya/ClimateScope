import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:climate_scope/app.dart';
import 'package:climate_scope/core/strings/app_strings.dart';
import 'package:climate_scope/core/theme/app_colors.dart';
import 'package:climate_scope/features/weather/domain/failures/weather_failure.dart';
import 'package:climate_scope/features/weather/presentation/widgets/empty_state.dart';
import 'package:climate_scope/features/weather/presentation/widgets/error_state.dart';
import 'package:climate_scope/features/weather/presentation/widgets/loading_state.dart';

void main() {
  testWidgets('ClimateScopeApp smoke test verifies launch and empty state',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ClimateScopeApp(),
      ),
    );

    expect(find.text(AppStrings.appName), findsOneWidget);
    expect(find.text(AppStrings.emptySearchPrompt), findsOneWidget);
    expect(find.byIcon(Icons.search_rounded), findsOneWidget);
  });

  testWidgets('LoadingState renders CircularProgressIndicator with accent blue',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LoadingState(),
        ),
      ),
    );

    final indicatorFinder = find.byType(CircularProgressIndicator);
    expect(indicatorFinder, findsOneWidget);

    final indicator = tester.widget<CircularProgressIndicator>(indicatorFinder);
    expect(indicator.color, AppColors.colorAccentBlue);
  });

  testWidgets('EmptyState displays message and calls onTap',
      (WidgetTester tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EmptyState(
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text(AppStrings.emptySearchPrompt), findsOneWidget);
    expect(find.byIcon(Icons.search_rounded), findsOneWidget);

    await tester.tap(find.byType(InkWell));
    expect(tapped, isTrue);
  });

  testWidgets('ErrorState maps NetworkFailure to errorNoInternet and fires onRetry',
      (WidgetTester tester) async {
    var retried = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ErrorState(
            failure: const NetworkFailure(),
            onRetry: () => retried = true,
          ),
        ),
      ),
    );

    expect(find.text(AppStrings.errorNoInternet), findsOneWidget);
    expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    expect(find.text(AppStrings.retry), findsOneWidget);

    await tester.tap(find.text(AppStrings.retry));
    expect(retried, isTrue);
  });

  testWidgets('ErrorState maps TimeoutFailure to errorTimeout',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ErrorState(
            failure: TimeoutFailure(),
          ),
        ),
      ),
    );

    expect(find.text(AppStrings.errorTimeout), findsOneWidget);
    expect(find.byType(OutlinedButton), findsNothing);
  });
}
