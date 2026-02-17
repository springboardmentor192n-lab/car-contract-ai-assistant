import 'dart:io';
import 'package:dio/dio.dart';
import '../models/contract_analysis_response.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://127.0.0.1:8000', // Adjust for physical device if needed
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 90),
  ));

  Future<ContractAnalysisResponse> analyzePdf(List<int> bytes, String fileName) async {
    try {
      FormData formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: fileName),
      });

      final response = await _dio.post(
        '/analyze-pdf',
        data: formData,
      );

      if (response.statusCode == 200) {
        return ContractAnalysisResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to analyze PDF: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error analyzing PDF: $e');
    }
  }

  // Placeholder for negotiation chat
  Future<Map<String, dynamic>> negotiate(Map<String, dynamic> clauses, String question) async {
    try {
      final response = await _dio.post(
        '/negotiate',
        data: {
          'clauses': clauses,
          'question': question,
        },
      );
      
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to negotiate: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error negotiating: $e');
    }
  }

  // VIN Lookup
  Future<Map<String, dynamic>> getVehicleDetails(String vin) async {
    try {
      final response = await _dio.get('/vin/$vin');
      
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to fetch VIN details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching VIN details: $e');
    }
  }
}
