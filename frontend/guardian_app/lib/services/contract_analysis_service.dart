// lib/services/contract_analysis_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../core/config.dart';
import 'api_service.dart';
import 'web_download_helper.dart';

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

class ContractAnalysisService {
  final ApiService _apiService;

  ContractAnalysisService(this._apiService);

  MediaType _getMediaType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf': return MediaType('application', 'pdf');
      case 'doc': return MediaType('application', 'msword');
      case 'docx': return MediaType('application', 'vnd.openxmlformats-officedocument.wordprocessingml.document');
      case 'png': return MediaType('image', 'png');
      case 'jpg':
      case 'jpeg': return MediaType('image', 'jpeg');
      case 'txt': return MediaType('text', 'plain');
      default: return MediaType('application', 'octet-stream');
    }
  }

  Future<DocumentContractAnalysisResult> analyzeContract({
    required String fileName,
    required Uint8List fileBytes,
  }) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/analyze_contract');
    
    int retryCount = 0;
    while (true) {
      try {
        if (kDebugMode) {
          print('Uploading $fileName to $uri (Attempt ${retryCount + 1})');
        }

        final request = http.MultipartRequest('POST', uri);
        
        // Add file with proper MediaType
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: fileName,
          contentType: _getMediaType(fileName),
        ));

        // Add standard headers
        request.headers.addAll({
          'Accept': 'application/json',
        });

        final streamedResponse = await request.send().timeout(AppConfig.timeoutDuration);
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final jsonResponse = json.decode(response.body);
          return DocumentContractAnalysisResult.fromJson(jsonResponse);
        } else {
          throw ApiException(
            'Server error (${response.statusCode}): ${response.body}',
            statusCode: response.statusCode
          );
        }
      } catch (e) {
        if (kDebugMode) {
          print('Upload error: $e');
        }

        bool isNetworkError = e is http.ClientException || e is TimeoutException || e.toString().contains('Failed to fetch');
        
        if (retryCount < AppConfig.retryCount && isNetworkError) {
          retryCount++;
          await Future.delayed(AppConfig.retryDelay);
          continue;
        }
        
        if (e is TimeoutException) {
          throw ApiException('Analysis request timed out. The server might be busy or starting up.');
        }
        if (e.toString().contains('Failed to fetch')) {
          throw ApiException('Connection failed. This might be a CORS issue or the server is down.');
        }
        throw ApiException('Network error: ${e.toString()}');
      }
    }
  }

  Future<void> downloadAnalysis(DocumentContractAnalysisResult result) async {
    // Encode query parameters properly for the GET request
    final queryParams = {
      'risk_level': result.riskLevel,
      'summary': result.summary,
      'penalties': result.penalties.join('\n'),
    };
    
    final uri = Uri.parse('${AppConfig.baseUrl}/download-analysis').replace(queryParameters: queryParams);

    try {
      if (kDebugMode) {
        print('Triggering PDF download: $uri');
      }
      // Use the web-safe conditional download helper
      downloadFile(uri.toString(), 'Contract_Analysis.pdf');
    } catch (e) {
      throw ApiException('Failed to start download: $e');
    }
  }
}
