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

    try {
      result = await ApiService.getPriceEstimate(vin: vinController.text.trim());
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Vehicle Information Lookup")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: vinController,
              decoration: const InputDecoration(
                labelText: "Enter VIN",
                hintText: "e.g., 4T1B11HK5KU212345",
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: loading ? null : estimate,
              child: loading
                  ? const Text("Loading...")
                  : const Text("Get Vehicle Info"),
            ),
            const SizedBox(height: 24),
            if (result != null) ...[
              const Text(
                "Vehicle Information (NHTSA Data):",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (result!['vehicle_info'] != null) ...[
                _buildInfoRow("Make", result!['vehicle_info']['make']),
                _buildInfoRow("Model", result!['vehicle_info']['model']),
                _buildInfoRow("Year", result!['vehicle_info']['year']),
                _buildInfoRow("Type", result!['vehicle_info']['type']),
              ],
              const SizedBox(height: 16),
              if (result!['note'] != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Text(
                    result!['note'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? "N/A",
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
