import 'package:flutter/material.dart';
import 'package:frontend/presentations/views/landing_view.dart';
import '../views/dashboard_view.dart';
import '../views/upload_contract_view.dart';
import '../views/contract_analysis_view.dart';
import '../views/contract_chat_view.dart';
import '../views/price_estimation_view.dart';
import '../views/vin_lookup_view.dart';

class AppRoutes {
  static const String landing = '/landing';
  static const String dashboard = '/dashboard';
  static const String uploadContract = '/upload-contract';
  static const String contractAnalysis = '/contract-analysis';
  static const String contractChat = '/contract-chat';
  static const String priceEstimation = '/price-estimation';
  static const String vinLookup = '/vin-lookup';

  static Map<String, WidgetBuilder> routes = {
    landing: (context) => const LandingView(),
    dashboard: (context) => const DashboardView(),
    uploadContract: (context) => const UploadContractView(),
    contractAnalysis: (context) => const ContractAnalysisView(slaData: null),
    contractChat: (context) => const ContractChatView(contractData: {}),
    priceEstimation: (context) => const PriceEstimationView(),
    vinLookup: (context) => const VinLookupView(),
  };
}
