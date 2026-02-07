class VehicleDetails {
  final String make;
  final String model;
  final String year;
  final String bodyType;
  final String engine;
  final String fuelType;
  final String plantCountry;

  VehicleDetails({
    required this.make,
    required this.model,
    required this.year,
    required this.bodyType,
    required this.engine,
    required this.fuelType,
    required this.plantCountry,
  });

  factory VehicleDetails.fromJson(Map<String, dynamic> json) {
    return VehicleDetails(
      make: json['make'] ?? 'N/A',
      model: json['model'] ?? 'N/A',
      year: json['year']?.toString() ?? 'N/A',
      bodyType: json['body_type'] ?? 'N/A',
      engine: json['engine'] ?? 'N/A',
      fuelType: json['fuel_type'] ?? 'N/A',
      plantCountry: json['plant_country'] ?? 'N/A',
    );
  }
}
