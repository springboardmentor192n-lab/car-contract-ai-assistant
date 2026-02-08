import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class VinLookupView extends StatefulWidget {
  const VinLookupView({super.key});

  @override
  State<VinLookupView> createState() => _VinLookupViewState();
}

class _VinLookupViewState extends State<VinLookupView> {
  final TextEditingController controller = TextEditingController();
  final List<Map<String, String>> messages = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    // Add initial AI message
    messages.add({
      "role": "ai",
      "text":
          "Hello! I'm your AI vehicle assistant. Please provide the VIN number to get comprehensive vehicle details including manufacturer info, recall history, registration details, and more.",
    });
  }

  Future<void> sendMessage() async {
    final userInput = controller.text.trim();
    if (userInput.isEmpty) return;

    setState(() {
      messages.add({"role": "user", "text": userInput});
      loading = true;
    });

    controller.clear();

    try {
      final result = await ApiService.getPriceChatEstimate(vin: userInput);

      // Format the response
      String responseText = _formatResponse(result);

      setState(() {
        messages.add({"role": "ai", "text": responseText});
      });
    } catch (e) {
      setState(() {
        messages.add({
          "role": "ai",
          "text":
              "Sorry, I couldn't process that VIN. Please check the VIN and try again.",
        });
      });
    }

    setState(() => loading = false);
  }

  String _formatResponse(Map<String, dynamic> result) {
    final vinData = result['vin_data'];

    String response =
        "Here's the comprehensive information for your vehicle:\n\n";

    // Vehicle Info
    final vehicleInfo = vinData['vehicle_info'];
    response += "Vehicle Details:\n";
    response += "Make: ${vehicleInfo['make'] ?? 'N/A'}\n";
    response += "Model: ${vehicleInfo['model'] ?? 'N/A'}\n";
    response += "Year: ${vehicleInfo['year'] ?? 'N/A'}\n";
    response += "Type: ${vehicleInfo['type'] ?? 'N/A'}\n\n";

    // Recalls
    final recalls = vinData['recalls'];
    if (recalls.isNotEmpty) {
      response += "Recall History (${recalls.length}):\n";
      for (var recall in recalls.take(3)) {
        response += "- ${recall['Component']}: ${recall['Summary']}\n";
      }
      if (recalls.length > 3)
        response += "...and ${recalls.length - 3} more\n\n";
    } else {
      response += "No recalls found.\n\n";
    }

    // Accidents (Mock data - explained below)
    final accidents = vinData['accidents'];
    if (accidents.isNotEmpty) {
      response += "Reported Accidents:\n";
      for (var accident in accidents) {
        response +=
            "- ${accident['date']}: ${accident['description']} (${accident['severity']})\n";
      }
      response += "\n";
    } else {
      response += "No reported accidents found.\n\n";
    }

    // Service Reports (Mock data)
    final serviceReports = vinData['service_reports'];
    if (serviceReports.isNotEmpty) {
      response += "Service History:\n";
      for (var service in serviceReports.take(2)) {
        response +=
            "- ${service['date']}: ${service['service']} (${service['mileage']} miles)\n";
      }
      response += "\n";
    } else {
      response += "No service history available.\n\n";
    }

    // Odometer Discrepancies (Mock data)
    final odometerDiscrepancies = vinData['odometer_discrepancies'];
    if (odometerDiscrepancies.isNotEmpty) {
      response += "Odometer Discrepancies:\n";
      for (var discrepancy in odometerDiscrepancies) {
        response +=
            "- Reported: ${discrepancy['reported_mileage']}, Actual: ${discrepancy['actual_mileage']} (Diff: ${discrepancy['discrepancy']})\n";
      }
      response += "\n";
    } else {
      response += "No odometer discrepancies found.\n\n";
    }

    // Registration
    final registration = vinData['registration_details'];
    response += "Registration Details:\n";
    response += "Status: ${registration['status']}\n";
    response += "Expires: ${registration['expiration_date']}\n";
    response += "Owner: ${registration['owner']}\n";

    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI VIN Lookup Assistant")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (_, i) {
                final msg = messages[i];
                final isUser = msg["role"] == "user";

                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.8,
                    ),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFF1E3A8A) : Colors.white12,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      msg["text"]!,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: "Enter VIN number...",
                    ),
                  ),
                ),
                loading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: CircularProgressIndicator(),
                      )
                    : IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: sendMessage,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
