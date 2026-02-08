import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class PriceEstimationView extends StatefulWidget {
  const PriceEstimationView({super.key});

  @override
  State<PriceEstimationView> createState() => _PriceEstimationViewState();
}

class _PriceEstimationViewState extends State<PriceEstimationView> {
  final vinController = TextEditingController();
  Map<String, dynamic>? result;
  bool loading = false;

  Future<void> estimate() async {
    setState(() => loading = true);

    result = await ApiService.getPriceEstimate(vin: vinController.text.trim());

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Vehicle Price Estimation")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: vinController,
              decoration: const InputDecoration(labelText: "Enter VIN"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: loading ? null : estimate,
              child: const Text("Estimate Price"),
            ),
            const SizedBox(height: 24),
            if (result != null)
              Text(
                "Estimated Price Range:\n"
                "\$${result!['price_estimate']['estimated_price_range']['min']} - "
                "\$${result!['price_estimate']['estimated_price_range']['max']}",
                style: const TextStyle(fontSize: 18),
              ),
          ],
        ),
      ),
    );
  }
}
