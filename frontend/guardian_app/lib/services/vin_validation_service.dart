// lib/services/vin_validation_service.dart
import 'package:flutter/foundation.dart';
import '../core/config.dart';
import 'api_service.dart';

/// Represents the result of a VIN validation and decoding.
class VinValidationResult {
  final String vin;
  final bool isValid;
  final String manufacturer;
  final String modelYear;
  final String region;
  final String error;

  VinValidationResult({
    required this.vin,
    this.isValid = false,
    this.manufacturer = 'N/A',
    this.modelYear = 'N/A',
    this.region = 'N/A',
    this.error = '',
  });

  factory VinValidationResult.fromJson(Map<String, dynamic> json) {
    return VinValidationResult(
      vin: json['vin'] as String,
      isValid: json['is_valid'] as bool? ?? false,
      manufacturer: json['manufacturer'] as String? ?? 'N/A',
      modelYear: json['model_year'] as String? ?? 'N/A',
      region: json['region'] as String? ?? 'N/A',
      error: json['error'] as String? ?? '',
    );
  }
}

/// Service for handling VIN validation and decoding via API.
class VinValidationService {
  final ApiService _apiService;

  VinValidationService(this._apiService);

  /// Validates a VIN against a (mock) backend endpoint.
  Future<VinValidationResult> validateVin(String vin) async {
    // Client-side format validation (already done in widget, but good to have here too)
    if (vin.length != 17 || RegExp(r'[IOQioq]').hasMatch(vin)) {
      return VinValidationResult(vin: vin, isValid: false, error: 'Invalid VIN format.');
    }

    try {
      // Mock API call for VIN validation
      // In a real scenario, this would call a FastAPI endpoint like /vin/validate
      // For demonstration, we'll simulate a response based on the VIN itself.
      if (kDebugMode) {
        print('Calling mock VIN validation for: $vin');
      }

      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

      if (vin.startsWith('1')) { // Example: VINs starting with '1' are valid US
        return VinValidationResult(
          vin: vin,
          isValid: true,
          manufacturer: 'Ford (Mock)',
          modelYear: '2022',
          region: 'USA',
        );
      } else if (vin.startsWith('J')) { // Example: VINs starting with 'J' are valid Japan
        return VinValidationResult(
          vin: vin,
          isValid: true,
          manufacturer: 'Toyota (Mock)',
          modelYear: '2023',
          region: 'Japan',
        );
      } else if (vin.startsWith('Z')) { // Example: VINs starting with 'Z' are invalid/error
        return VinValidationResult(
          vin: vin,
          isValid: false,
          error: 'VIN format recognized, but no data found (Mock Error)',
        );
      } else {
        return VinValidationResult(vin: vin, isValid: false, error: 'VIN not recognized (Mock)');
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print('VIN API Error: ${e.message}');
      }
      return VinValidationResult(vin: vin, isValid: false, error: 'API Error: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        print('VIN Validation Service Error: $e');
      }
      return VinValidationResult(vin: vin, isValid: false, error: 'An unexpected error occurred.');
    }
  }
}
