class AnalysisResult {
  final String filename;
  final String contentType;
  final Map<String, dynamic> extractedTerms;
  final Map<String, dynamic> specificClauses; // New field
  final List<dynamic> potentialRisks;
  final String rawText;
  final int riskScore;
  final String riskLevel;
  final List<dynamic> riskExplanation;
  final String? summary; // Added summary field

  AnalysisResult({
    required this.filename,
    required this.contentType,
    required this.extractedTerms,
    required this.specificClauses,
    required this.potentialRisks,
    required this.rawText,
    required this.riskScore,
    required this.riskLevel,
    required this.riskExplanation,
    this.summary, // Added summary to constructor
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      filename: json['filename'] ?? 'N/A',
      contentType: json['content_type'] ?? 'N/A',
      extractedTerms: Map<String, dynamic>.from(json['extracted_terms'] ?? {}),
      specificClauses: Map<String, dynamic>.from(json['specific_clauses'] ?? {}),
      potentialRisks: List<dynamic>.from(json['potential_risks'] ?? []),
      rawText: json['raw_text'] ?? '',
      riskScore: json['risk_score'] ?? 0,
      riskLevel: json['risk_level'] ?? 'N/A',
      riskExplanation: List<dynamic>.from(json['risk_explanation'] ?? []),
      summary: json['summary'] as String?, // Added summary to fromJson
    );
  }
}