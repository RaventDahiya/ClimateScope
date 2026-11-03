/// Immutable model representing a geocoded city result.
final class CityModel {
  const CityModel({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.country,
    this.admin1,
  });

  /// City display name (e.g., "London").
  final String name;

  /// Latitude coordinate for the forecast API.
  final double latitude;

  /// Longitude coordinate for the forecast API.
  final double longitude;

  /// Country name (e.g., "United Kingdom").
  final String country;

  /// Region or state name — nullable, not all cities have one.
  final String? admin1;

  /// Creates a [CityModel] from an Open-Meteo geocoding results entry.
  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      name: (json['name'] as String?) ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      country: (json['country'] as String?) ?? '',
      admin1: json['admin1'] as String?,
    );
  }

  /// Serialises this model to a JSON map for caching in SharedPreferences.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'country': country,
      'admin1': admin1,
    };
  }

  @override
  String toString() =>
      'CityModel(name: $name, latitude: $latitude, longitude: $longitude, '
      'country: $country, admin1: $admin1)';
}

