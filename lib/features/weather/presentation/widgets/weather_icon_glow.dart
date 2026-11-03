import 'package:flutter/material.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/weather_code_mapper.dart';

/// Radial gradient glow backlight behind the hero weather icon.
///
/// Provides a soft, condition-appropriate colored glow matching the active WMO code.
class WeatherIconGlow extends StatelessWidget {
  const WeatherIconGlow({
    super.key,
    required this.weatherCode,
    this.size = AppDimensions.heroIconContainerSize,
    this.iconSize = AppDimensions.heroIconSize,
  });

  /// WMO weather interpretation code.
  final int weatherCode;

  /// Outer container dimension (width & height). Defaults to 160dp.
  final double size;

  /// Weather icon glyph size. Defaults to 80dp.
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final info = WeatherCodeMapper.map(weatherCode);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 0.5,
          colors: [
            info.glowColor.withOpacity(info.glowOpacity),
            Colors.transparent,
          ],
          stops: const [0.0, 1.0],
        ),
      ),
      child: Center(
        child: Icon(
          info.icon,
          size: iconSize,
          color: info.tintColor,
          semanticLabel: info.conditionText,
        ),
      ),
    );
  }
}
