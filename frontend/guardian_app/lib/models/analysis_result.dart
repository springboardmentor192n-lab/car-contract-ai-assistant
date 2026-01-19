class AnalysisResult {
  final String filename;
  final String contentType;
  final Map<String, dynamic> extractedTerms;
  final List<dynamic> potentialRisks;
  final String rawText;

  AnalysisResult({
    required this.filename,
    required this.contentType,
    required this.extractedTerms,
    required this.potentialRisks,
    required this.rawText,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      filename: json['filename'] ?? 'N/A',
      contentType: json['content_type'] ?? 'N/A',
      extractedTerms: Map<String, dynamic>.from(json['extracted_terms'] ?? {}),
      potentialRisks: List<dynamic>.from(json['potential_risks'] ?? []),
      rawText: json['raw_text'] ?? '',
    );
  }
}