
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/contract_service.dart';
import '../models/models.dart';
import 'contract_details_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Contract> _contracts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContracts();
  }

  Future<void> _loadContracts() async {
    setState(() => _isLoading = true);
    try {
      final service = Provider.of<ContractService>(context, listen: false);
      final contracts = await service.getContracts();
      setState(() {
        _contracts = contracts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading contracts: $e")),
      );
    }
  }

  Future<void> _uploadContract() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png', 'jpeg'],
    );

    if (result != null) {
      setState(() => _isLoading = true);
      try {
        final platformFile = result.files.single;
        final service = Provider.of<ContractService>(context, listen: false);
        
        // Critical Fix: Use bytes on web, path on mobile/desktop
        if (kIsWeb) {
          await service.uploadContract(null, platformFile.name, bytes: platformFile.bytes);
        } else {
          await service.uploadContract(platformFile.path, platformFile.name);
        }
        
        await _loadContracts();
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Upload failed: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.primaryContainer.withOpacity(0.2),
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context),
            SliverToBoxAdapter(child: _buildHeader(context)),
            if (_isLoading)
              const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
            else if (_contracts.isEmpty)
              SliverFillRemaining(child: _buildEmptyState(context))
            else
              _buildContractGrid(context, isMobile),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _uploadContract,
        elevation: 4,
        icon: const Icon(Icons.add),
        label: const Text("New Contract"),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        title: Text(
          "Contract Assistant",
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadContracts,
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Welcome Back",
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Track and analyze your lease agreements effortlessly.",
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          _buildQuickStats(context),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    final theme = Theme.of(context);
    final completed = _contracts.where((c) => c.status == 'completed').length;
    final total = _contracts.length;

    return Row(
      children: [
        _buildStatCard(context, "Analyzed", completed.toString(), Icons.analytics),
        const SizedBox(width: 16),
        _buildStatCard(context, "Stored", total.toString(), Icons.folder_copy),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 24),
            const SizedBox(height: 12),
            Text(value, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(label, style: GoogleFonts.inter(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 24),
          Text(
            "No contracts found",
            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text("Upload your first contract to get started."),
        ],
      ),
    );
  }

  Widget _buildContractGrid(BuildContext context, bool isMobile) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isMobile ? 1 : 3,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: isMobile ? 3.5 : 2.5,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildContractCard(context, _contracts[index]),
          childCount: _contracts.length,
        ),
      ),
    );
  }

  Widget _buildContractCard(BuildContext context, Contract contract) {
    final theme = Theme.of(context);
    final bool isDone = contract.status == 'completed';
    final bool isFailed = contract.status == 'failed';
    final bool isProcessing = contract.status == 'processing' || contract.status == 'queued';

    Color statusColor = theme.colorScheme.primary;
    IconData statusIcon = Icons.hourglass_top;
    String statusText = "Processing...";

    if (isDone) {
      statusColor = Colors.green;
      statusIcon = Icons.verified;
      statusText = "Analysis Complete";
    } else if (isFailed) {
      statusColor = Colors.red;
      statusIcon = Icons.error_outline;
      statusText = "Analysis Failed";
    }

    return InkWell(
      onTap: () {
        if (isDone) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ContractDetailsScreen(contractId: contract.id),
            ),
          );
        } else if (isFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Analysis failed. Please try uploading a clearer image or a PDF."),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Analysis still in progress..."), duration: Duration(seconds: 1)),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: statusColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(statusIcon, color: statusColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    contract.filename,
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statusText,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
