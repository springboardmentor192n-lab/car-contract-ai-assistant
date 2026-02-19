
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/models.dart';
import '../services/contract_service.dart';
import 'negotiation_chat_screen.dart';

class ContractDetailsScreen extends StatefulWidget {
  final int contractId;
  const ContractDetailsScreen({super.key, required this.contractId});

  @override
  State<ContractDetailsScreen> createState() => _ContractDetailsScreenState();
}

class _ContractDetailsScreenState extends State<ContractDetailsScreen> with SingleTickerProviderStateMixin {
  Contract? _contract;
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    setState(() => _isLoading = true);
    try {
      final service = Provider.of<ContractService>(context, listen: false);
      final contract = await service.getContractDetails(widget.contractId);
      setState(() {
        _contract = contract;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading details: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_contract == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text("Contract not found.")),
      );
    }

    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          _contract!.filename,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: isMobile,
          indicatorColor: theme.colorScheme.primary,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: "Overview"),
            Tab(text: "Detailed Metrics"),
            Tab(text: "Negotiation Bot"),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: "Download Report",
            onPressed: () => _downloadReport(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(isMobile),
          _buildMetricsTab(isMobile),
          NegotiationChatScreen(contractId: widget.contractId),
        ],
      ),
    );
  }

  Future<void> _downloadReport() async {
    final service = Provider.of<ContractService>(context, listen: false);
    final url = service.getDownloadUrl(widget.contractId);
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not initiate download.")),
        );
      }
    }
  }

  Widget _buildOverviewTab(bool isMobile) {
    final sla = _contract!.sla!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Plain English Summary"),
          const SizedBox(height: 12),
          _buildSummaryCard(sla.simpleLanguageSummary ?? "Summary unavailable."),
          const SizedBox(height: 32),
          _buildSectionTitle("High Risk Areas"),
          const SizedBox(height: 12),
          _buildRiskList(sla.redFlags ?? [], isMobile),
          const SizedBox(height: 32),
          _buildSectionTitle("Final Advice"),
          const SizedBox(height: 12),
          _buildAdviceCard(sla.finalAdvice ?? "No specific advice generated."),
          const SizedBox(height: 32),
          _buildSectionTitle("Negotiation Strategy"),
          const SizedBox(height: 12),
          _buildSuggestionList(sla.negotiationPoints ?? []),
        ],
      ),
    );
  }

  Widget _buildMetricsTab(bool isMobile) {
    final sla = _contract!.sla!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Important Terms"),
          const SizedBox(height: 12),
          _buildBulletList(sla.importantTerms ?? []),
          const SizedBox(height: 32),
          _buildSectionTitle("Hidden Charges"),
          const SizedBox(height: 12),
          _buildHiddenCharges(sla.hiddenCharges ?? []),
          const SizedBox(height: 32),
          _buildSectionTitle("Penalties & Fees"),
          const SizedBox(height: 12),
          _buildBulletList(sla.penalties ?? [], color: Colors.orange[800]),
        ],
      ),
    );
  }

  Widget _buildAdviceCard(String content) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.indigo[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.indigo.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, color: Colors.indigo),
          const SizedBox(width: 16),
          Expanded(
            child: Text(content, style: GoogleFonts.inter(fontSize: 15, height: 1.5, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionList(List<String> points) {
    return Column(
      children: points.map((p) => ListTile(
        leading: const Icon(Icons.chat_bubble_outline, color: Colors.teal),
        title: Text(p, style: GoogleFonts.inter(fontSize: 14)),
        contentPadding: EdgeInsets.zero,
      )).toList(),
    );
  }

  Widget _buildBulletList(List<String> items, {Color? color}) {
    return Column(
      children: items.map((item) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.check_circle_outline, size: 18, color: color ?? Colors.indigo),
            const SizedBox(width: 12),
            Expanded(child: Text(item, style: GoogleFonts.inter())),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildHiddenCharges(List<dynamic> charges) {
    if (charges.isEmpty) return const Text("No hidden charges detected.");
    return Column(
      children: charges.map((c) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.amber[50], borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.amber),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "${c['name']}: ${c['description']}",
                style: GoogleFonts.inter(color: Colors.amber[900], fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
    );
  }

  Widget _buildSummaryCard(String content) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Text(content, style: GoogleFonts.inter(fontSize: 15, height: 1.6, color: Colors.blueGrey[800])),
    );
  }

  Widget _buildRiskList(List<String> redFlags, bool isMobile) {
    if (redFlags.isEmpty) return const Text("No immediate risks found.");
    return Column(
      children: redFlags.map((flag) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(12)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(flag, style: GoogleFonts.inter(color: Colors.red[900], fontWeight: FontWeight.w500))),
          ],
        ),
      )).toList(),
    );
  }
}
