// lib/services/contract_analysis_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/config.dart';
import 'api_service.dart'; // Reusing the existing ApiService

// Conditional import for web download
import 'dart:html' as html;

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
    
    // Helper function for the actual request to support retries
    Future<http.StreamedResponse> sendRequest() async {
      var request = http.MultipartRequest('POST', uri)
        ..files.add(http.MultipartFile.fromBytes(
          'file', // Field name for the file on the backend
          fileBytes,
          filename: fileName,
        ));
      // Increase timeout to 120 seconds for long processing
      return await request.send().timeout(const Duration(seconds: 120));
    }

    int retryCount = 0;
    const int maxRetries = 1;

    while (true) {
      try {
        if (kDebugMode) {
          print('Attempting to upload contract for analysis (Attempt ${retryCount + 1}): $fileName to $uri');
        }
        
        final response = await sendRequest();

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final responseBody = await response.stream.bytesToString();
          if (kDebugMode) {
            print('Contract analysis upload successful. Response body: $responseBody');
          }

          if (responseBody.isNotEmpty) {
            try {
              final jsonResponse = json.decode(responseBody);
              return DocumentContractAnalysisResult.fromJson(jsonResponse);
            } catch (e) {
              if (kDebugMode) {
                print('Failed to parse contract analysis response JSON: $e');
              }
              return DocumentContractAnalysisResult(
                  fileName: fileName,
                  riskLevel: 'Error',
                  summary: 'Failed to parse analysis: $responseBody');
            }
          }
          return DocumentContractAnalysisResult(fileName: fileName, summary: 'No analysis content received.');
        } else {
          final errorBody = await response.stream.bytesToString();
          if (kDebugMode) {
            print('Server returned error: ${response.statusCode} - $errorBody');
          }
          throw ApiException('Failed to analyze contract. Status: ${response.statusCode}', statusCode: response.statusCode);
        }
      } catch (e) {
        if (retryCount < maxRetries && (e is TimeoutException || e is http.ClientException)) {
          retryCount++;
          if (kDebugMode) {
            print('Retrying contract analysis due to error: $e. Attempt $retryCount');
          }
          await Future.delayed(const Duration(seconds: 2));
          continue;
        }
        
        if (kDebugMode) {
          print('Contract Analysis Service Error: $e');
        }
        if (e is TimeoutException) {
          throw ApiException('Analysis request timed out after 120 seconds. Please try again.');
        }
        throw ApiException('An unexpected error occurred during contract analysis: ${e.toString()}');
      }
    }
  }

  /// Downloads the contract analysis as a text file.
  Future<void> downloadAnalysis(DocumentContractAnalysisResult result) async {
    final queryParams = {
      'risk_level': result.riskLevel,
      'summary': result.summary,
    };
    
    // Construct URI with encoded query parameters
    final uri = Uri.parse('${AppConfig.baseUrl}/download-analysis').replace(queryParameters: queryParams);

    if (kIsWeb) {
      try {
        if (kDebugMode) {
          print('Triggering web download for analysis: $uri');
        }
        // Using anchor element for download. 
        // Backend sends Content-Disposition: attachment to force download.
        html.AnchorElement(href: uri.toString())
          ..setAttribute("download", "Contract_Analysis.txt")
          ..click();
      } catch (e) {
        if (kDebugMode) {
          print('Web download failed: $e');
        }
        throw ApiException('Failed to trigger download: $e');
      }
    } else {
      if (kDebugMode) {
        print('Download triggered for non-web (URL only): $uri');
      }
    }
  }
}
