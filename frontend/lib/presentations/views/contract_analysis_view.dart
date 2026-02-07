import 'package:flutter/material.dart';
import 'contract_chat_view.dart';
import 'package:frontend/presentations/widgets/info_card.dart';

class ContractAnalysisView extends StatelessWidget {
  final Map<String, dynamic> slaData;

  const ContractAnalysisView({super.key, required this.slaData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Contract Summary")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  InfoCard(
                    title: "Interest Rate / APR",
                    value: (slaData["interest_rate_apr"]?["value"] ?? "N/A")
                        .toString(),
                  ),
                  InfoCard(
                    title: "Lease Duration",
                    value: (slaData["lease_term_duration"]?["value"] ?? "N/A")
                        .toString(),
                  ),
                  InfoCard(
                    title: "Monthly Payment",
                    value: (slaData["monthly_payment"]?["value"] ?? "N/A")
                        .toString(),
                  ),
                  InfoCard(
                    title: "Mileage Allowance",
                    value:
                        (slaData["mileage_allowance"]?["allowed_miles_per_year"] ??
                                "N/A")
                            .toString(),
                  ),
                  InfoCard(
                    title: "Early Termination",
                    value:
                        (slaData["early_termination_clause"]?["summary"] ??
                                "N/A")
                            .toString(),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ContractChatView(contractData: slaData),
                  ),
                );
              },
              child: const Text("Ask AI / Improve Deal"),
            ),
          ],
        ),
      ),
    );
  }
}
