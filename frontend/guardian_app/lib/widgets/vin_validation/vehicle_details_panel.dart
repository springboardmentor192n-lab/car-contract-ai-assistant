// lib/widgets/vin_validation/vehicle_details_panel.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Add this import
import '../../services/vin_validation_service.dart'; // For VinValidationResult
import '../common/skeleton_loader.dart';

/// A panel to display structured vehicle details from a VIN lookup.
/// Includes loading skeletons and an empty/error state.
class VehicleDetailsPanel extends StatelessWidget {
  final AsyncValue<VinValidationResult?> validationState;

  const VehicleDetailsPanel({
    Key? key,
    required this.validationState,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return validationState.when(
      data: (result) {
        if (result == null) {
          return _buildEmptyState(context, 'Enter a VIN to see vehicle details.');
        }
        if (!result.isValid) {
          return _buildEmptyState(context, result.error.isNotEmpty ? result.error : 'Invalid VIN or vehicle not found.');
        }
        return _buildDetailsCard(context, result);
      },
      loading: () => _buildLoadingState(context),
      error: (err, stack) => _buildEmptyState(context, 'Error: ${err.toString()}'),
    );
  }

  Widget _buildDetailsCard(BuildContext context, VinValidationResult result) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vehicle Details',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            _buildDetailRow(context, 'Make', result.manufacturer),
            _buildDetailRow(context, 'Model', 'F-150 (Mock)'), // Add mock data for new fields
            _buildDetailRow(context, 'Year', result.modelYear),
            _buildDetailRow(context, 'Vehicle Type', 'TRUCK (Mock)'),
            _buildDetailRow(context, 'Body Class', 'Pickup (Mock)'),
            _buildDetailRow(context, 'Engine Cylinders', '6 (Mock)'),
            _buildDetailRow(context, 'Fuel Type', 'Gasoline (Mock)'),
            _buildDetailRow(context, 'Plant City', 'Dearborn (Mock)'),
            _buildDetailRow(context, 'Plant Country', result.region),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vehicle Details',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            for (int i = 0; i < 9; i++) // 9 skeleton rows
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonLoader(width: 100, height: 20),
                    SkeletonLoader(width: 150, height: 20),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 40, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
