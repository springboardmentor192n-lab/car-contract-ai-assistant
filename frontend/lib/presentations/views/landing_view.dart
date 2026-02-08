import 'package:flutter/material.dart';
import 'package:frontend/presentations/widgets/feature_card.dart';
import 'package:frontend/presentations/widgets/primary_button.dart';
import 'package:lottie/lottie.dart';
import '../bindings/app_routes.dart';

class LandingView extends StatefulWidget {
  const LandingView({super.key});

  @override
  State<LandingView> createState() => _LandingViewState();
}

class _LandingViewState extends State<LandingView> {
  bool animate = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() => animate = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF020617), Color(0xFF020617)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 60),

              /// 🔹 ANIMATED HERO TEXT
              AnimatedSlide(
                offset: animate ? Offset.zero : const Offset(0, 0.2),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOut,
                child: AnimatedOpacity(
                  opacity: animate ? 1 : 0,
                  duration: const Duration(milliseconds: 700),
                  child: Column(
                    children: const [
                      Text(
                        "LeaseWise AI",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Understand your car lease.\nBefore you sign.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// 🔹 SUBTITLE
              AnimatedOpacity(
                opacity: animate ? 1 : 0,
                duration: const Duration(milliseconds: 900),
                child: const Text(
                  "AI-powered contract analysis, VIN verification,\n"
                  "and smart negotiation assistance.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              /// 🔹 LOTTIE ANIMATION
              SizedBox(
                height: 220,
                child: Lottie.asset(
                  "assets/animations/Robot Futuristic Ai animated.json",
                  repeat: true,
                ),
              ),

              const SizedBox(height: 32),

              /// 🔹 CTA BUTTON
              AnimatedScale(
                scale: animate ? 1 : 0.9,
                duration: const Duration(milliseconds: 500),
                child: SizedBox(
                  width: 220,
                  child: PrimaryButton(
                    title: "Get Started",
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.dashboard);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 60),

              /// 🔹 FEATURE HIGHLIGHTS
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
                    label: "VIN Intelligence",
                  ),
                  _HighlightItem(
                    icon: Icons.trending_up,
                    label: "Price Benchmarking",
                  ),
                ],
              ),

              const SizedBox(height: 80),

              /// 🔹 FEATURE CARDS (STAGGERED FEEL)
              const FeatureCard(
                title: "Smart Lease Analysis",
                description:
                    "Extract interest rates, lease terms, mileage limits, penalties, and hidden clauses automatically.",
                icon: Icons.analytics,
              ),
              const SizedBox(height: 24),
              const FeatureCard(
                title: "VIN & Vehicle Intelligence",
                description:
                    "Verify vehicle specifications, manufacturer details, and recall history using official data.",
                icon: Icons.verified,
              ),
              const SizedBox(height: 24),
              const FeatureCard(
                title: "Negotiation Assistant",
                description:
                    "Get AI-powered negotiation strategies based on market benchmarks and contract terms.",
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
