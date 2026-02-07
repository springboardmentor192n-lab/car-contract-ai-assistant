
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AutoFinance Guardian'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // TODO: Navigate to profile/settings
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildFeatureCard(
            context,
            title: 'Analyze a Contract',
            subtitle: 'Upload a PDF or image of your lease/loan agreement.',
            icon: Icons.document_scanner,
            onTap: () => context.go('/contract-analysis'),
          ),
          _buildFeatureCard(
            context,
            title: 'Check Vehicle Value',
            subtitle: 'Lookup a VIN to get market data and recall info.',
            icon: Icons.directions_car,
            onTap: () => context.go('/vin-lookup'),
          ),
          _buildFeatureCard(
            context,
            title: 'Negotiation Helper',
            subtitle: 'Get AI-powered suggestions for your negotiation.',
            icon: Icons.chat,
            onTap: () => context.go('/chat'),
          ),
          _buildFeatureCard(
            context,
            title: 'Market Rates',
            subtitle: 'Compare interest rates and terms.',
            icon: Icons.show_chart,
            onTap: () => context.go('/market-rates'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icon, size: 40, color: theme.colorScheme.primary),
        title: Text(title, style: theme.textTheme.titleLarge),
        subtitle: Text(subtitle),
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16.0),
      ),
    );
  }
}
