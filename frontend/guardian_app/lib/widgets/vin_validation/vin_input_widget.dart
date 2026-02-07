// lib/widgets/vin_validation/vin_input_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/vin_validation_provider.dart';

/// A widget for inputting and validating a VIN (Vehicle Identification Number).
class VinInputWidget extends ConsumerStatefulWidget {
  const VinInputWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<VinInputWidget> createState() => _VinInputWidgetState();
}

class _VinInputWidgetState extends ConsumerState<VinInputWidget> {
  final TextEditingController _vinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _vinController.dispose();
    super.dispose();
  }

  void _validateVin() {
    if (_formKey.currentState!.validate()) {
      final vin = _vinController.text.toUpperCase();
      ref.read(vinValidationProvider.notifier).validateVin(vin);
    }
  }

  // Client-side VIN format validation
  String? _vinValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a VIN.';
    }
    if (value.length != 17) {
      return 'VIN must be 17 characters long.';
    }
    // Exclude I, O, Q
    if (RegExp(r'[IOQioq]').hasMatch(value)) {
      return 'VIN cannot contain letters I, O, or Q.';
    }
    // Allow alphanumeric characters (excluding I, O, Q)
    if (!RegExp(r'^[0-9A-HJ-NPR-Z]{17}$').hasMatch(value.toUpperCase())) {
      return 'Invalid VIN format.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final vinValidationState = ref.watch(vinValidationProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'VIN Validation',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _vinController,
                maxLength: 17,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: 'VIN (Vehicle Identification Number)',
                  hintText: 'Enter 17-character VIN',
                  border: const OutlineInputBorder(),
                  counterText: '', // Hide character counter
                  suffixIcon: vinValidationState.isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        )
                      : IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: _validateVin,
                        ),
                ),
                validator: _vinValidator,
                onFieldSubmitted: (value) => _validateVin(),
              ),
            ),
            const SizedBox(height: 16),
            if (vinValidationState.isLoading)
              const Center(child: LinearProgressIndicator())
            else if (vinValidationState.hasError)
              Text(
                'Error: ${vinValidationState.error}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.error),
              )
            else if (vinValidationState.value != null && vinValidationState.value!.isValid)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle_outline, color: Colors.green, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'VIN is Valid!',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manufacturer: ${vinValidationState.value!.manufacturer}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    'Model Year: ${vinValidationState.value!.modelYear}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    'Region: ${vinValidationState.value!.region}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  // Add more decoded info as needed
                ],
              )
            else if (vinValidationState.value != null && !vinValidationState.value!.isValid)
              Row(
                children: [
                  Icon(Icons.cancel_outlined, color: Theme.of(context).colorScheme.error, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'VIN is Invalid or Not Found.',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
