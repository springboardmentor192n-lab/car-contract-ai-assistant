import 'package:flutter/material.dart';
import 'package:guardian_app/screens/contract_analysis_screen.dart';
import 'package:guardian_app/screens/vin_lookup_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AutoFinance Guardian'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildMenuCard(
              context,
              icon: Icons.document_scanner,
              title: 'Analyze Contract',
              subtitle: 'Upload a contract to check for risks',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ContractAnalysisScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildMenuCard(
              context,
              icon: Icons.car_crash,
              title: 'Check Vehicle (VIN)',
              subtitle: 'Look up vehicle history and details',
              onTap: () {
                 Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const VinLookupScreen()),
                );
              },
            ),
             const SizedBox(height: 16),
            _buildMenuCard(
              context,
              icon: Icons.show_chart,
              title: 'Market Rates',
              subtitle: 'Check average auto loan rates',
              onTap: () {
                // TODO: Navigate to MarketRatesScreen
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }
}
