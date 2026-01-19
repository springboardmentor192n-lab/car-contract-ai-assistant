import 'package:flutter/material.dart';
import 'package:guardian_app/services/api_service.dart';
import 'package:guardian_app/models/vehicle_details.dart';

class VinLookupScreen extends StatefulWidget {
  const VinLookupScreen({super.key});

  @override
  State<VinLookupScreen> createState() => _VinLookupScreenState();
}

class _VinLookupScreenState extends State<VinLookupScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _vinController = TextEditingController();

  VehicleDetails? _vehicleDetails;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _lookupVin() async {
    final vin = _vinController.text.trim().toUpperCase();
    if (vin.isEmpty) {
      setState(() {
        _errorMessage = "Please enter a VIN.";
      });
      return;
    }
    if (vin.length != 17) {
      setState(() {
        _errorMessage = "VIN must be 17 characters long.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _vehicleDetails = null;
    });

    try {
      final result = await _apiService.getVehicleDetails(vin);
      setState(() {
        _vehicleDetails = result;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  void dispose() {
    _vinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VIN Lookup'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInputSection(),
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_errorMessage != null)
              _buildErrorWidget()
            else if (_vehicleDetails != null)
              _buildResultsWidget()
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Column(
      children: [
        TextField(
          controller: _vinController,
          decoration: const InputDecoration(
            labelText: 'Enter 17-Digit VIN',
            border: OutlineInputBorder(),
            hintText: '1GKS19EKXFZ123456',
          ),
          maxLength: 17,
          textCapitalization: TextCapitalization.characters,
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          icon: const Icon(Icons.search),
          label: const Text('Look Up VIN'),
          onPressed: _isLoading ? null : _lookupVin,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
          ),
        ),
      ],
    );
  }

   Widget _buildErrorWidget() {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(Icons.error, color: Theme.of(context).colorScheme.onErrorContainer, size: 32),
            const SizedBox(height: 10),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsWidget() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vehicle Details', style: Theme.of(context).textTheme.titleLarge),
            const Divider(height: 20),
            _buildDetailRow('Make', _vehicleDetails!.make),
            _buildDetailRow('Model', _vehicleDetails!.model),
            _buildDetailRow('Year', _vehicleDetails!.modelYear),
            _buildDetailRow('Type', _vehicleDetails!.vehicleType),
            _buildDetailRow('Body Class', _vehicleDetails!.bodyClass),
            _buildDetailRow('Engine Cylinders', _vehicleDetails!.engineCylinders),
            _buildDetailRow('Fuel Type', _vehicleDetails!.fuelTypePrimary),
            _buildDetailRow('Plant City', _vehicleDetails!.plantCity),
            _buildDetailRow('Plant Country', _vehicleDetails!.plantCountry),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}