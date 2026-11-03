/// Enum representing grouped WMO weather condition types.
///
/// This is used for categorising weather codes into condition groups,
/// primarily for glow/icon logic in the presentation layer.
enum WeatherCondition {
  clearSky,
  mainlyClear,
  partlyCloudy,
  overcast,
  fog,
  rimeFog,
  lightDrizzle,
  moderateDrizzle,
  denseDrizzle,
  slightRain,
  moderateRain,
  heavyRain,
  slightSnow,
  moderateSnow,
  heavySnow,
  slightShowers,
  moderateShowers,
  violentShowers,
  thunderstorm,
  thunderstormSlightHail,
  thunderstormHeavyHail,
  unknown;

  /// Maps a raw WMO weather code to a [WeatherCondition].
  static WeatherCondition fromCode(int code) {
    return switch (code) {
      0 => WeatherCondition.clearSky,
      1 => WeatherCondition.mainlyClear,
      2 => WeatherCondition.partlyCloudy,
      3 => WeatherCondition.overcast,
      45 => WeatherCondition.fog,
      48 => WeatherCondition.rimeFog,
      51 => WeatherCondition.lightDrizzle,
      53 => WeatherCondition.moderateDrizzle,
      55 => WeatherCondition.denseDrizzle,
      61 => WeatherCondition.slightRain,
      63 => WeatherCondition.moderateRain,
      65 => WeatherCondition.heavyRain,
      71 => WeatherCondition.slightSnow,
      73 => WeatherCondition.moderateSnow,
      75 => WeatherCondition.heavySnow,
      80 => WeatherCondition.slightShowers,
      81 => WeatherCondition.moderateShowers,
      82 => WeatherCondition.violentShowers,
      95 => WeatherCondition.thunderstorm,
      96 => WeatherCondition.thunderstormSlightHail,
      99 => WeatherCondition.thunderstormHeavyHail,
      _ => WeatherCondition.unknown,
    };
  }
}

