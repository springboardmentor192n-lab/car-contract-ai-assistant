// lib/screens/vin_lookup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/vin_validation_provider.dart';
import '../widgets/vin_validation/vin_input_field.dart';
import '../widgets/vin_validation/vehicle_details_panel.dart';

/// A dedicated screen for VIN lookup and displaying detailed vehicle information.
class VinLookupScreen extends ConsumerStatefulWidget {
  const VinLookupScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<VinLookupScreen> createState() => _VinLookupScreenState();
}

class _VinLookupScreenState extends ConsumerState<VinLookupScreen> {
  final TextEditingController _vinController = TextEditingController();
  String? _errorText;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _vinController.addListener(_onVinChanged);
  }

  @override
  void dispose() {
    _vinController.removeListener(_onVinChanged);
    _vinController.dispose();
    super.dispose();
  }

  void _onVinChanged() {
    final vin = _vinController.text.toUpperCase();
    if (vin.length == 17 && !RegExp(r'[IOQioq]').hasMatch(vin)) {
      setState(() {
        _isValid = true;
        _errorText = null;
      });
    } else {
      setState(() {
        _isValid = false;
        _errorText = vin.length < 17 ? 'VIN must be 17 characters.' : null;
      });
    }
  }

  void _lookupVin() {
    if (_isValid) {
      ref.read(vinValidationProvider.notifier).validateVin(_vinController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vinValidationState = ref.watch(vinValidationProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'VIN Lookup & Vehicle Validation',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Enter a 17-character Vehicle Identification Number (VIN) to get started.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              VinInputField(
                controller: _vinController,
                isValid: _isValid,
                isLoading: vinValidationState.isLoading,
                onSearch: _lookupVin,
                errorText: _errorText,
              ),
              const SizedBox(height: 32),
              VehicleDetailsPanel(
                validationState: vinValidationState,
              ),
            ],
          ),
        ),
      ),
    );
  }
}