import 'package:flutter/material.dart';
import 'package:frontend/presentations/widgets/sidebar_item.dart';
import 'package:frontend/presentations/bindings/app_routes.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.grey[900],
      child: Column(
        children: [
          const SizedBox(height: 20),
          SidebarItem(
            icon: Icons.dashboard,
            label: "Dashboard",
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.dashboard);
            },
          ),
          SidebarItem(
            icon: Icons.upload_file,
            label: "Upload Contract",
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.uploadContract);
            },
          ),
          SidebarItem(
            icon: Icons.analytics,
            label: "Contract Analysis",
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.contractAnalysis);
            },
          ),
          SidebarItem(
            icon: Icons.chat,
            label: "Contract Chat",
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.contractChat);
            },
          ),
          SidebarItem(
            icon: Icons.price_check,
            label: "Price Estimation",
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.priceEstimation);
            },
          ),
          SidebarItem(
            icon: Icons.search,
            label: "VIN Lookup",
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.vinLookup);
            },
          ),
        ],
      ),
    );
  }
}
