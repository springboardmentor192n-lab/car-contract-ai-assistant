// lib/widgets/document_upload/document_upload_widget.dart
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/document_upload_provider.dart';
import '../../services/document_upload_service.dart';

/// A widget for uploading documents for AI analysis.
/// Features a dropzone, progress display, and structured results panel.
class DocumentUploadWidget extends ConsumerWidget {
  const DocumentUploadWidget({Key? key}) : super(key: key);

  static const List<String> _supportedExtensions = [
    'jpg', 'jpeg', 'png', 'gif', 'bmp', 'tiff', 'pdf', 'doc', 'docx', 'txt', 'odt', 'rtf'
  ];

  Future<void> _pickAndUploadFile(BuildContext context, WidgetRef ref) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _supportedExtensions,
    );

    if (result != null && result.files.single.bytes != null) {
      final platformFile = result.files.single;
      if (platformFile.size > 10 * 1024 * 1024) { // 10MB limit
        _showErrorSnackBar(context, 'File size exceeds 10 MB limit.');
        return;
      }

      await ref.read(documentUploadProvider.notifier).uploadDocument(
            fileName: platformFile.name,
            fileBytes: platformFile.bytes!,
          );
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uploadState = ref.watch(documentUploadProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Contract Document Analysis',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            uploadState.when(
              data: (result) {
                if (result == null) {
                  return _buildDropzone(context, ref);
                }
                return _buildResultPanel(context, ref, result);
              },
              loading: () => _buildLoadingIndicator(context),
              error: (err, stack) => _buildErrorState(context, ref, err.toString()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropzone(BuildContext context, WidgetRef ref) {
    return DottedBorder(
      color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
      strokeWidth: 2,
      dashPattern: const [8, 4],
      borderType: BorderType.RRect,
      radius: const Radius.circular(12),
      child: InkWell(
        onTap: () => _pickAndUploadFile(context, ref),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 150,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 50,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Click to upload your contract document',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  'Max file size: 10MB',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Uploading & Analyzing...', style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, String error) {
    return SizedBox(
      height: 150,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 40),
            const SizedBox(height: 16),
            Text('Upload Failed: $error', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(documentUploadProvider.notifier).clearResult(),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultPanel(BuildContext context, WidgetRef ref, DocumentAnalysisResult result) {
    Color riskColor;
    IconData riskIcon;
    switch (result.riskLevel) {
      case 'High':
        riskColor = Colors.redAccent;
        riskIcon = Icons.warning_amber_rounded;
        break;
      case 'Medium':
        riskColor = Colors.orangeAccent;
        riskIcon = Icons.info_outline_rounded;
        break;
      default:
        riskColor = Colors.green;
        riskIcon = Icons.check_circle_outline_rounded;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Analysis for: ${result.fileName}', style: Theme.of(context).textTheme.titleMedium),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => ref.read(documentUploadProvider.notifier).clearResult(),
              tooltip: 'Analyze another document',
            ),
          ],
        ),
        const Divider(height: 24),
        _buildResultCategory(
          context,
          'Risk Level',
          result.riskLevel,
          riskColor,
          riskIcon,
        ),
        _buildResultList(context, 'Hidden Fees Detected', result.hiddenFees, Icons.money_off),
        _buildResultList(context, 'Unfair Clauses Found', result.unfairClauses, Icons.gavel_rounded),
        _buildResultList(context, 'Penalties & Termination Risks', result.penalties, Icons.report_problem_outlined),
        _buildResultSummary(context, 'Overall Summary', result.summary),
      ],
    );
  }

  Widget _buildResultCategory(BuildContext context, String title, String value, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Text('$title: ', style: Theme.of(context).textTheme.titleMedium),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildResultList(BuildContext context, String title, List<String> items, IconData icon) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          ...items.map((item) => ListTile(
                leading: Icon(icon, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                title: Text(item),
                dense: true,
              )),
        ],
      ),
    );
  }

  Widget _buildResultSummary(BuildContext context, String title, String summary) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(summary, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}