import 'package:flutter/material.dart';
import 'package:frontend/presentations/widgets/primary_button.dart';
import '../bindings/app_routes.dart';

class LandingView extends StatelessWidget {
  const LandingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF020617), Color(0xFF020617), Color(0xFF020617)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 80),

              // HERO TITLE
              const Text(
                "LeaseWise AI",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                "Understand your car lease.\nBefore you sign.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                "AI-powered contract analysis, VIN verification,\n"
                "and smart negotiation assistance — all in one place.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 40),

              // CTA BUTTON
              SizedBox(
                width: 200,
                child: PrimaryButton(
                  title: "Get Started",
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.dashboard);
                  },
                ),
              ),

              const SizedBox(height: 60),

              // FEATURE HIGHLIGHTS ROW
              Wrap(
                spacing: 24,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: const [
                  _HighlightItem(
                    icon: Icons.description,
                    label: "AI Contract Review",
                  ),
                  _HighlightItem(
                    icon: Icons.directions_car,
                    label: "VIN-Based Insights",
                  ),
                  _HighlightItem(
                    icon: Icons.trending_up,
                    label: "Fair Deal Benchmarking",
                  ),
                ],
              ),

              const SizedBox(height: 80),

              // FEATURE CARDS
              _FeatureCard(
                title: "Smart Lease Analysis",
                description:
                    "Automatically extract interest rates, lease terms, mileage limits, penalties, and hidden clauses from car lease agreements.",
                icon: Icons.analytics,
              ),

              const SizedBox(height: 24),

              _FeatureCard(
                title: "VIN & Vehicle Intelligence",
                description:
                    "Decode VINs using official NHTSA data to verify vehicle specifications, manufacturer details, and recall history.",
                icon: Icons.verified,
              ),

              const SizedBox(height: 24),

              _FeatureCard(
                title: "Negotiation Assistant",
                description:
                    "Get AI-generated negotiation points and email suggestions based on your lease terms and real-world market benchmarks.",
                icon: Icons.chat,
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

/* -------------------- SMALL WIDGETS -------------------- */

class _HighlightItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HighlightItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const _FeatureCard({
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF020617),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(color: Colors.white70, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
