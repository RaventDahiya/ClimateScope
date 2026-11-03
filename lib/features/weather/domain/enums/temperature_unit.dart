/// Measurement units for temperature and wind speed conversions.
enum TemperatureUnit {
  celsius,
  fahrenheit;

  /// Returns the temperature unit symbol.
  String get symbol {
    return switch (this) {
      TemperatureUnit.celsius => '°C',
      TemperatureUnit.fahrenheit => '°F',
    };
  }
}

