
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardian_app/src/features/vehicle/application/vin_lookup_service.dart';
import 'package:guardian_app/src/shared/widgets/primary_button.dart';

class VinLookupScreen extends ConsumerWidget {
  const VinLookupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vinController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final vinLookupState = ref.watch(vinLookupProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('VIN Lookup'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(vinLookupProvider.notifier).reset(),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: vinController,
                decoration: const InputDecoration(
                  labelText: 'Enter Vehicle Identification Number (VIN)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a VIN' : null,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'Lookup VIN',
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    ref
                        .read(vinLookupProvider.notifier)
                        .lookupVIN(vinController.text);
                  }
                },
              ),
              const SizedBox(height: 24),
              Expanded(
                child: vinLookupState.when(
                  data: (vehicle) {
                    if (vehicle == null) {
                      return const Center(
                          child: Text('Vehicle details will be shown here.'));
                    }
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Make: ${vehicle.make}'),
                            Text('Model: ${vehicle.model}'),
                            Text('Year: ${vehicle.year}'),
                            Text('Body Type: ${vehicle.bodyType}'),
                            Text('Fuel Type: ${vehicle.fuelType}'),
                            Text('Engine: ${vehicle.engine}'),
                          ],
                        ),
                      ),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Error: $error')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
