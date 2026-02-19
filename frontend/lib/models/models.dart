
class User {
  final int id;
  final String email;
  final String? fullName;

  User({required this.id, required this.email, this.fullName});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
    );
  }
}

class ExtractedSLA {
  final int? id;
  final double? apr;
  final int? leaseTermMonths;
  final double? monthlyPayment;
  final double? downPayment;
  final double? residualValue;
  final int? mileageLimitPerYear;
  final double? overageChargePerMile;
  final double? earlyTerminationFee;
  final double? amountDueAtSigning;
  final double? totalLeaseCost;
  final String? lenderName;
  final String? vehicleVin;
  final String? vehicleMake;
  final String? vehicleModel;
  final int? vehicleYear;
  
  final String? simpleLanguageSummary;
  final List<String>? importantTerms;
  final List<String>? redFlags;
  final List<dynamic>? hiddenCharges;
  final List<String>? penalties;
  final List<String>? negotiationPoints;
  final String? finalAdvice;
  final String? riskLevel;

  ExtractedSLA({
    this.id, this.apr, this.leaseTermMonths, this.monthlyPayment, this.downPayment,
    this.residualValue, this.mileageLimitPerYear, this.overageChargePerMile,
    this.earlyTerminationFee, this.amountDueAtSigning, this.totalLeaseCost,
    this.lenderName, this.vehicleVin, this.vehicleMake, this.vehicleModel,
    this.vehicleYear, this.simpleLanguageSummary, this.importantTerms, this.redFlags,
    this.hiddenCharges, this.penalties, this.negotiationPoints, this.finalAdvice, this.riskLevel
  });

  factory ExtractedSLA.fromJson(Map<String, dynamic> json) {
    return ExtractedSLA(
      id: json['id'],
      apr: json['apr']?.toDouble(),
      leaseTermMonths: json['lease_term_months'],
      monthlyPayment: json['monthly_payment']?.toDouble(),
      downPayment: json['down_payment']?.toDouble(),
      residualValue: json['residual_value']?.toDouble(),
      mileageLimitPerYear: json['mileage_limit_per_year'],
      overageChargePerMile: json['overage_charge_per_mile']?.toDouble(),
      earlyTerminationFee: json['early_termination_fee']?.toDouble(),
      amountDueAtSigning: json['amount_due_at_signing']?.toDouble(),
      totalLeaseCost: json['total_lease_cost']?.toDouble(),
      lenderName: json['lender_name'],
      vehicleVin: json['vehicle_vin'],
      vehicleMake: json['vehicle_make'],
      vehicleModel: json['vehicle_model'],
      vehicleYear: json['vehicle_year'],
      simpleLanguageSummary: json['simple_language_summary'],
      importantTerms: json['important_terms'] != null ? List<String>.from(json['important_terms']) : [],
      redFlags: json['red_flags'] != null ? List<String>.from(json['red_flags']) : [],
      hiddenCharges: json['hidden_charges'],
      penalties: json['penalties'] != null ? List<String>.from(json['penalties']) : [],
      negotiationPoints: json['negotiation_points'] != null ? List<String>.from(json['negotiation_points']) : [],
      finalAdvice: json['final_advice'],
      riskLevel: json['risk_level'],
    );
  }
}

class NegotiationChatResponse {
  final String response;
  final List<String> suggestedQuestions;
  final String? dealerEmailDraft;

  NegotiationChatResponse({
    required this.response,
    required this.suggestedQuestions,
    this.dealerEmailDraft,
  });

  factory NegotiationChatResponse.fromJson(Map<String, dynamic> json) {
    return NegotiationChatResponse(
      response: json['response'],
      suggestedQuestions: List<String>.from(json['suggested_questions'] ?? []),
      dealerEmailDraft: json['dealer_email_draft'],
    );
  }
}

class FairnessScore {
  final int score;
  final String rating;
  final Map<String, dynamic>? breakdown;
  final String? explanation;

  FairnessScore({required this.score, required this.rating, this.breakdown, this.explanation});

  factory FairnessScore.fromJson(Map<String, dynamic> json) {
    return FairnessScore(
      score: json['score'],
      rating: json['rating'],
      breakdown: json['breakdown'],
      explanation: json['explanation'],
    );
  }
}

class PriceAnalysis {
  final double? estimatedFairPriceLow;
  final double? estimatedFairPriceHigh;
  final double? marketAveragePrice;
  final double? contractPrice;
  final double? overpricedAmount;
  final String? verdict;
  final String? explanation;

  PriceAnalysis({
    this.estimatedFairPriceLow, this.estimatedFairPriceHigh, this.marketAveragePrice,
    this.contractPrice, this.overpricedAmount, this.verdict, this.explanation
  });

  factory PriceAnalysis.fromJson(Map<String, dynamic> json) {
    return PriceAnalysis(
      estimatedFairPriceLow: json['estimated_fair_price_low']?.toDouble(),
      estimatedFairPriceHigh: json['estimated_fair_price_high']?.toDouble(),
      marketAveragePrice: json['market_average_price']?.toDouble(),
      contractPrice: json['contract_price']?.toDouble(),
      overpricedAmount: json['overpriced_amount']?.toDouble(),
      verdict: json['verdict'],
      explanation: json['explanation'],
    );
  }
}

class VehicleReport {
  final String vin;
  final String? make;
  final String? model;
  final int? year;
  final List<dynamic>? recalls;

  VehicleReport({required this.vin, this.make, this.model, this.year, this.recalls});

  factory VehicleReport.fromJson(Map<String, dynamic> json) {
    return VehicleReport(
      vin: json['vin'],
      make: json['make'],
      model: json['model'],
      year: json['year'],
      recalls: json['recalls'],
    );
  }
}

class Contract {
  final int id;
  final String filename;
  final String status;
  final ExtractedSLA? sla;
  final FairnessScore? fairnessScore;
  final VehicleReport? vehicleReport;
  final PriceAnalysis? priceAnalysis;

  Contract({
    required this.id, required this.filename, required this.status,
    this.sla, this.fairnessScore, this.vehicleReport, this.priceAnalysis
  });

  factory Contract.fromJson(Map<String, dynamic> json) {
    return Contract(
      id: json['id'],
      filename: json['filename'],
      status: json['status'],
      sla: json['sla'] != null ? ExtractedSLA.fromJson(json['sla']) : null,
      fairnessScore: json['fairness_score'] != null ? FairnessScore.fromJson(json['fairness_score']) : null,
      vehicleReport: json['vehicle_report'] != null ? VehicleReport.fromJson(json['vehicle_report']) : null,
      priceAnalysis: json['price_analysis'] != null ? PriceAnalysis.fromJson(json['price_analysis']) : null,
    );
  }
}
