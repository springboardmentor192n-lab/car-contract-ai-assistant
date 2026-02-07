// lib/services/contract_analysis_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/config.dart';
import 'api_service.dart'; // Reusing the existing ApiService

/// Represents the structured result of a contract document analysis.
class DocumentContractAnalysisResult {
  final String fileName;
  final String riskLevel;
  final List<String> hiddenFees;
  final List<String> penalties;
  final List<String> unfairClauses;
  final String summary;

  DocumentContractAnalysisResult({
    required this.fileName,
    this.riskLevel = 'N/A',
    this.hiddenFees = const [],
    this.penalties = const [],
    this.unfairClauses = const [],
    this.summary = 'No analysis available.',
  });

  factory DocumentContractAnalysisResult.fromJson(Map<String, dynamic> json) {
    return DocumentContractAnalysisResult(
      fileName: json['file_name'] as String? ?? 'Unknown File',
      riskLevel: json['risk_level'] as String? ?? 'N/A',
      hiddenFees: List<String>.from(json['hidden_fees'] as List? ?? []),
      penalties: List<String>.from(json['penalties'] as List? ?? []),
      unfairClauses: List<String>.from(json['unfair_clauses'] as List? ?? []),
      summary: json['summary'] as String? ?? 'No summary provided.',
    );
  }
}

/// Service for handling contract document uploads and their AI analysis.
class ContractAnalysisService {
  final ApiService _apiService; // Can be used for other API calls if needed

  ContractAnalysisService(this._apiService);

  /// Uploads a contract document for AI analysis and returns the structured result.
  Future<DocumentContractAnalysisResult> analyzeContract({
    required String fileName,
    required Uint8List fileBytes,
  }) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/analyze_contract'); // Backend endpoint
    var request = http.MultipartRequest('POST', uri)
      ..files.add(http.MultipartFile.fromBytes(
        'file', // Field name for the file on the backend
        fileBytes,
        filename: fileName,
      ));

    try {
      if (kDebugMode) {
        print('Attempting to upload contract for analysis: $fileName to $uri');
      }
      final response = await request.send();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseBody = await response.stream.bytesToString();
        if (kDebugMode) {
          print('Contract analysis upload successful. Response body: $responseBody');
        }

        if (responseBody.isNotEmpty) {
          try {
            final jsonResponse = json.decode(responseBody);
            // Assuming backend returns a JSON with the structured analysis result
            return DocumentContractAnalysisResult.fromJson(jsonResponse);
          } catch (e) {
            if (kDebugMode) {
              print('Failed to parse contract analysis response JSON: $e');
            }
            // If response is not JSON, treat body as a generic error or summary
            return DocumentContractAnalysisResult(
                fileName: fileName,
                riskLevel: 'Error',
                summary: 'Failed to parse analysis: $responseBody');
          }
        }
        return DocumentContractAnalysisResult(fileName: fileName, summary: 'No analysis content received.');
      } else {
        final errorBody = await response.stream.bytesToString();
        String errorMessage = 'Failed to analyze contract. Status: ${response.statusCode}';
        if (errorBody.isNotEmpty) {
          errorMessage += ' Body: $errorBody';
        }
        throw ApiException(errorMessage, statusCode: response.statusCode);
      }
    } on http.ClientException catch (e) {
      if (kDebugMode) {
        print('HTTP Client Error during contract analysis upload: $e');
      }
      throw ApiException('Network error or connection failed during upload: ${e.message}');
    } on ApiException {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('Contract Analysis Service Error: $e');
      }
      throw ApiException('An unexpected error occurred during contract analysis: ${e.toString()}');
    }
  }
}
