import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:guardian_app/models/analysis_result.dart';
import 'package:guardian_app/models/vehicle_details.dart';
import 'dart:io';


class ApiService {
  // Use kIsWeb to determine the platform and set the base URL accordingly.
  static const String _baseUrl = kIsWeb ? "http://localhost:8000" : "http://10.0.2.2:8000";

  Future<AnalysisResult> analyzeContract(XFile imageFile) async {
    final uri = Uri.parse("$_baseUrl/analyze_contract");
    var request = http.MultipartRequest('POST', uri);

    // For web, we send bytes. For mobile, we send the path.
    if (kIsWeb) {
      final bytes = await imageFile.readAsBytes();
      final file = http.MultipartFile.fromBytes('file', bytes, filename: imageFile.name);
      request.files.add(file);
    } else {
      final file = await http.MultipartFile.fromPath('file', imageFile.path);
      request.files.add(file);
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return AnalysisResult.fromJson(json.decode(response.body));
      } else {
        String errorMessage = "Failed to analyze contract.";
        try {
          final errorBody = json.decode(response.body);
          errorMessage = errorBody['detail'] ?? errorMessage;
        } catch (e) {}
        throw Exception(errorMessage);
      }
    } on SocketException {
       throw Exception('Could not connect to the server. Make sure the backend is running.');
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<VehicleDetails> getVehicleDetails(String vin) async {
    final uri = Uri.parse("$_baseUrl/vin_lookup/$vin");
    
    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return VehicleDetails.fromJson(data['vehicle_details']);
      } else {
        String errorMessage = "Failed to look up VIN.";
        try {
          final errorBody = json.decode(response.body);
          errorMessage = errorBody['detail'] ?? errorMessage;
        } catch (e) {}
        throw Exception(errorMessage);
      }
    } on SocketException {
       throw Exception('Could not connect to the server. Make sure the backend is running.');
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }
}