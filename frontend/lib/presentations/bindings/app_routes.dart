import 'package:flutter/material.dart';
import 'package:frontend/presentations/views/landing_view.dart';
import '../views/dashboard_view.dart';
import '../views/upload_contract_view.dart';

class AppRoutes {
  static const String landing = '/landing';
  static const String dashboard = '/dashboard';
  static const String uploadContract = '/upload-contract';

  static Map<String, WidgetBuilder> routes = {
    landing: (context) => const LandingView(),
    dashboard: (context) => const DashboardView(),
    uploadContract: (context) => const UploadContractView(),
  };
}
