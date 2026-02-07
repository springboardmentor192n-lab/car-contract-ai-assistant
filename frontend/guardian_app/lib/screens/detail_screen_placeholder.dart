// lib/screens/detail_screen_placeholder.dart
import 'package:flutter/material.dart';

/// A placeholder screen for displaying details of an item.
/// It shows the item ID and type passed through navigation.
class DetailScreenPlaceholder extends StatelessWidget {
  final String itemId;
  final String itemType;

  const DetailScreenPlaceholder({
    Key? key,
    required this.itemId,
    required this.itemType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$itemType Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Details for $itemType with ID:', style: Theme.of(context).textTheme.headlineSmall),
            Text(itemId, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const Text('This is a placeholder for future detailed views.'),
          ],
        ),
      ),
    );
  }
}