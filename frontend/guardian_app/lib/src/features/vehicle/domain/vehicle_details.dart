import 'package:flutter/material.dart';

@immutable
class VehicleDetails {
  final String vin;
  final String make;
  final String model;
  final int year;
  final List<String> recalls;

  const VehicleDetails({
    required this.vin,
    required this.make,
    required this.model,
    required this.year,
    required this.recalls,
  });

  factory VehicleDetails.fromJson(Map<String, dynamic> json) {
    return VehicleDetails(
      vin: json['vin'] as String,
      make: json['make'] as String,
      model: json['model'] as String,
      year: json['year'] as int,
      recalls: List<String>.from(json['recalls'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vin': vin,
      'make': make,
      'model': model,
      'year': year,
      'recalls': recalls,
    };
  }
}