class ContractAnalysisResponse {
  final String filename;
  final int totalSentences;
  final Map<String, dynamic> clauses;
  final double fairness;
  final String? fairnessRating;
  final List<String>? fairnessReasons;
  final Map<String, dynamic>? vehicleInfo;
  final Map<String, dynamic>? priceEstimation;
  final Map<String, dynamic>? contractDetails;
  final String aiSummary;

  ContractAnalysisResponse({
    required this.filename,
    required this.totalSentences,
    required this.clauses,
    required this.fairness,
    this.fairnessRating,
    this.fairnessReasons,
    this.vehicleInfo,
    this.priceEstimation,
    this.contractDetails,
    required this.aiSummary,
  });

  factory ContractAnalysisResponse.fromJson(Map<String, dynamic> json) {
    // Handle fairness which can be a number (old) or a Map (new)
    dynamic fairnessData = json['fairness'];
    double fairnessScore = 0.0;
    String? rating;
    List<String>? reasons;

    if (fairnessData is Map) {
      fairnessScore = (fairnessData['score'] ?? 0).toDouble();
      rating = fairnessData['rating'];
      if (fairnessData['reasons'] != null) {
        reasons = List<String>.from(fairnessData['reasons']);
      }
    } else if (fairnessData is num) {
      fairnessScore = fairnessData.toDouble();
    }

    return ContractAnalysisResponse(
      filename: json['filename'] ?? '',
      totalSentences: json['total_sentences'] ?? 0,
      clauses: json['clauses'] ?? {},
      fairness: fairnessScore,
      fairnessRating: rating,
      fairnessReasons: reasons,

      vehicleInfo: json['vehicle_info'],
      priceEstimation: json['price_estimation'],
      contractDetails: json['contract_details'],
      aiSummary: json['ai_summary'] ?? '',
    );
  }
}
