import 'package:flutter/material.dart';

class MarketRatesScreen extends StatelessWidget {
  const MarketRatesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Rates'),
      ),
      body: const Center(
        child: Text('Market Rates Screen Content'),
      ),
    );
  }
}
