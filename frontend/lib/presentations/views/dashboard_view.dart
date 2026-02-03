import 'package:flutter/material.dart';
import 'package:frontend/presentations/widgets/feature_card.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("LeaseWise AI"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Dashboard",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Access your AI-powered tools",
              style: TextStyle(color: Colors.white70),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.95,
                children: [
                  FeatureCard(
                    title: "Upload Contract",
                    subtitle: "Analyze car lease agreements using AI",
                    icon: Icons.upload_file,
                    onTap: () {},
                  ),
                  FeatureCard(
                    title: "SLA Analysis",
                    subtitle: "View extracted clauses and penalties",
                    icon: Icons.description,
                    onTap: () {},
                  ),
                  FeatureCard(
                    title: "VIN Lookup",
                    subtitle: "Decode VIN & verify vehicle details",
                    icon: Icons.directions_car,
                    onTap: () {},
                  ),
                  FeatureCard(
                    title: "Price Estimation",
                    subtitle: "Check fair lease & purchase pricing",
                    icon: Icons.attach_money,
                    onTap: () {},
                  ),
                  FeatureCard(
                    title: "Negotiation Assistant",
                    subtitle: "Get AI-powered negotiation tips",
                    icon: Icons.chat,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
