import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/vin_validation_provider.dart';
import '../widgets/vin_validation/vin_input_field.dart';
import '../widgets/vin_validation/vehicle_details_panel.dart';
import '../widgets/responsive/responsive_layout.dart';

class VinLookupScreen extends ConsumerWidget {
  const VinLookupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ResponsiveLayout(
      mobile: const _VinLookupContent(padding: 16.0),
      desktop: const _VinLookupContent(padding: 48.0),
    );
  }
}

class _VinLookupContent extends ConsumerStatefulWidget {
  final double padding;

  const _VinLookupContent({Key? key, required this.padding}) : super(key: key);

  @override
  ConsumerState<_VinLookupContent> createState() => _VinLookupContentState();
}

class _VinLookupContentState extends ConsumerState<_VinLookupContent> {
  // Use a local controller to avoid rebuilding the whole widget tree unnecessarily
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
    // Basic VIN validation (17 chars, no I, O, Q)
    // This logic might duplicate what's in the provider/service,
    // but it's good for immediate UI feedback.
    final vin = _vinController.text.toUpperCase();
    if (vin.length == 17) {
       // Ideally use a validator function
       setState(() {
        _isValid = true;
        _errorText = null;
      });
    } else {
      setState(() {
        _isValid = false;
        // _errorText = 'Enter 17 characters'; // Optional: show error as they type?
      });
    }
  }

  void _lookupVin() {
    ref.read(vinValidationProvider.notifier).validateVin(_vinController.text);
  }

  @override
  Widget build(BuildContext context) {
    final vinValidationState = ref.watch(vinValidationProvider);

    return SingleChildScrollView(
      padding: EdgeInsets.all(widget.padding),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'VIN Lookup',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Enter a 17-character VIN to get vehicle details.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              VinInputField(
                controller: _vinController, // Pass the controller
                // We might need to adjust VinInputField if it expects to manage its own state
                // but usually passing a controller is standard.
                // Checking previous implementation... it passed controller.
                // It also passed isValid and onSearch.
                isValid: _isValid,
                isLoading: vinValidationState.isLoading,
                onSearch: _lookupVin,
                errorText: _errorText,
              ),
              const SizedBox(height: 32),
              // We need to make sure VehicleDetailsPanel is responsive too
              // It likely just displays data, so width constraint handles it.
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
