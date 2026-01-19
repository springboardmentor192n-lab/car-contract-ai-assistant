class VehicleDetails {
  final String make;
  final String model;
  final String modelYear;
  final String vehicleType;
  final String bodyClass;
  final String engineCylinders;
  final String fuelTypePrimary;
  final String plantCity;
  final String plantCountry;

  VehicleDetails({
    required this.make,
    required this.model,
    required this.modelYear,
    required this.vehicleType,
    required this.bodyClass,
    required this.engineCylinders,
    required this.fuelTypePrimary,
    required this.plantCity,
    required this.plantCountry,
  });

  factory VehicleDetails.fromJson(Map<String, dynamic> json) {
    return VehicleDetails(
      make: json['Make'] ?? 'N/A',
      model: json['Model'] ?? 'N/A',
      modelYear: json['ModelYear'] ?? 'N/A',
      vehicleType: json['VehicleType'] ?? 'N/A',
      bodyClass: json['BodyClass'] ?? 'N/A',
      engineCylinders: json['EngineCylinders'] ?? 'N/A',
      fuelTypePrimary: json['FuelTypePrimary'] ?? 'N/A',
      plantCity: json['PlantCity'] ?? 'N/A',
      plantCountry: json['PlantCountry'] ?? 'N/A',
    );
  }
}