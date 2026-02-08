import 'package:flutter/material.dart';
import 'package:frontend/presentations/widgets/car_news.dart';
import 'package:frontend/presentations/widgets/sidebar.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("LeaseWise AI")),
      body: Row(
        children: [
          Sidebar(),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER
                    const Text(
                      "Welcome 👋",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Stay informed about cars while you analyze smarter.",
                      style: TextStyle(color: Colors.white70),
                    ),

                    const SizedBox(height: 32),

                    // FEATURED NEWS
                    CarNewsCard(
                      title: "Top 10 Cars to Consider in 2026 Before Leasing",
                      subtitle:
                          "Industry experts highlight fuel efficiency, resale value, and reliability as key factors this year.",
                      date: "Updated today",
                    ),

                    const SizedBox(height: 32),

                    // QUICK ACTIONS
                    const Text(
                      "Quick Actions",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),

                    const SizedBox(height: 36),

                    // LATEST NEWS LIST
                    const Text(
                      "Latest Car News",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),

                    CarNewsListItem(
                      title:
                          "Electric vehicle lease prices drop across major brands",
                      source: "AutoNews",
                    ),
                    CarNewsListItem(
                      title:
                          "Why residual value matters more than interest rate",
                      source: "CarExpert",
                    ),
                    CarNewsListItem(
                      title: "New safety recalls issued for 2024–2025 models",
                      source: "NHTSA",
                    ),

                    const SizedBox(height: 32),

                    // AI TIP
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Icon(Icons.auto_awesome, color: Colors.white),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Tip: Compare lease terms with current market trends "
                              "before negotiating — small changes can save thousands.",
                              style: TextStyle(
                                color: Colors.white70,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
