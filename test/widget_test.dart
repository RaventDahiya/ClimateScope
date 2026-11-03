import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:climate_scope/app.dart';
import 'package:climate_scope/core/strings/app_strings.dart';

void main() {
  testWidgets('ClimateScopeApp smoke test verifies launch',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ClimateScopeApp(),
      ),
    );

    expect(find.text(AppStrings.appName), findsOneWidget);
  });
}
