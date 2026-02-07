// lib/widgets/vin_validation/vin_input_field.dart
import 'package:flutter/material.dart';

/// A large, styled text input field specifically designed for VIN entry.
/// It provides real-time validation feedback through its decoration.
class VinInputField extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final bool isValid;
  final bool isLoading;
  final VoidCallback onSearch;

  const VinInputField({
    Key? key,
    required this.controller,
    this.errorText,
    this.isValid = false,
    this.isLoading = false,
    required this.onSearch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLength: 17,
      textCapitalization: TextCapitalization.characters,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
      decoration: InputDecoration(
        labelText: 'Enter Vehicle Identification Number (VIN)',
        hintText: '17-CHARACTER VIN',
        errorText: errorText,
        counterText: '', // Hide the default character counter
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(
            width: 2,
            color: isValid
                ? Colors.green
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(
            width: 2,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: isLoading
              ? const CircularProgressIndicator()
              : IconButton(
                  icon: const Icon(Icons.search, size: 30),
                  onPressed: onSearch,
                  tooltip: 'Lookup VIN',
                ),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a VIN.';
        }
        if (value.length != 17) {
          return 'VIN must be 17 characters long.';
        }
        if (RegExp(r'[IOQioq]').hasMatch(value)) {
          return 'VIN cannot contain letters I, O, or Q.';
        }
        return null;
      },
      onFieldSubmitted: (_) => onSearch(),
    );
  }
}
