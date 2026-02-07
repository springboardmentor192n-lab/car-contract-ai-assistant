// lib/services/document_upload_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/config.dart';
import 'api_service.dart';

/// Represents the structured result of a document analysis.
class DocumentAnalysisResult {
  final String fileName;
  final String riskLevel;
  final List<String> hiddenFees;
  final List<String> unfairClauses;
  final List<String> penalties;
  final String summary;

  DocumentAnalysisResult({
    required this.fileName,
    this.riskLevel = 'N/A',
    this.hiddenFees = const [],
    this.unfairClauses = const [],
    this.penalties = const [],
    this.summary = 'No analysis available.',
  });

  factory DocumentAnalysisResult.fromJson(Map<String, dynamic> json) {
    return DocumentAnalysisResult(
      fileName: json['file_name'] as String? ?? 'Unknown File',
      riskLevel: json['risk_level'] as String? ?? 'N/A',
      hiddenFees: List<String>.from(json['hidden_fees'] as List? ?? []),
      unfairClauses: List<String>.from(json['unfair_clauses'] as List? ?? []),
      penalties: List<String>.from(json['penalties'] as List? ?? []),
      summary: json['summary'] as String? ?? 'No summary provided.',
    );
  }
}

/// Service for handling document uploads and parsing the analysis result.
class DocumentUploadService {
  final ApiService _apiService;

  DocumentUploadService(this._apiService);

  /// Uploads a document and returns a structured analysis result.
  Future<DocumentAnalysisResult> uploadDocument({
    required String fileName,
    required Uint8List fileBytes,
  }) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/upload/document');
    var request = http.MultipartRequest('POST', uri)
      ..files.add(http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: fileName,
      ));

    try {
      // MOCK IMPLEMENTATION: Simulate API call and return a mock structured response.
      // In a real scenario, the backend would perform AI analysis and return this structure.
      await Future.delayed(const Duration(seconds: 2)); // Simulate upload & processing time

      // Mock response based on file name or content
      if (fileName.toLowerCase().contains('bad')) {
        return DocumentAnalysisResult.fromJson({
          'file_name': fileName,
          'risk_level': 'High',
          'hidden_fees': ['\$250 administrative fee', '\$50 statement fee'],
          'unfair_clauses': ['Lender can change interest rate unilaterally.'],
          'penalties': ['4% prepayment penalty for first 2 years.'],
          'summary': 'This contract contains several high-risk clauses, including unilateral rate changes and high hidden fees. Proceed with extreme caution and seek legal advice.'
        });
      } else {
        return DocumentAnalysisResult.fromJson({
          'file_name': fileName,
          'risk_level': 'Low',
          'hidden_fees': [],
          'unfair_clauses': [],
          'penalties': ['Standard late payment fee of \$35.'],
          'summary': 'The contract appears to have fair and standard terms. The only penalty noted is for late payments, which is common.'
        });
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('Document Upload/Analysis Error: $e');
      }
      throw ApiException('Failed to analyze document: ${e.toString()}');
    }
  }
}
