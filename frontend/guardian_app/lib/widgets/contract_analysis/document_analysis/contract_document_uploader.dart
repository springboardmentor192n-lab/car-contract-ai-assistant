// lib/widgets/contract_analysis/document_analysis/contract_document_uploader.dart
// import 'package:dotted_border/dotted_border.dart'; // Removed DottedBorder import
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/contract_analysis_document_provider.dart';

/// A widget for uploading contract documents for AI analysis.
/// Features a dropzone, file picker fallback, and displays upload progress.
class ContractDocumentUploader extends ConsumerWidget {
  const ContractDocumentUploader({Key? key}) : super(key: key);

  static const List<String> _supportedExtensions = [
    'jpg', 'jpeg', 'png', 'gif', 'bmp', 'tiff', 'pdf', 'doc', 'docx', 'txt', 'odt', 'rtf'
  ];

  Future<void> _pickAndAnalyzeFile(BuildContext context, WidgetRef ref) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _supportedExtensions,
      withData: true, // Crucial for web to get file bytes
    );

    if (result != null && result.files.single.bytes != null) {
      final platformFile = result.files.single;
      if (platformFile.size > 10 * 1024 * 1024) { // 10MB limit
        _showErrorSnackBar(context, 'File size exceeds 10 MB limit.');
        return;
      }

      await ref.read(contractAnalysisDocumentProvider.notifier).analyzeDocument(
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
    final analysisState = ref.watch(contractAnalysisDocumentProvider);

    return InkWell( // Replaced DottedBorder with InkWell wrapping a Container
      onTap: analysisState.isLoading ? null : () => _pickAndAnalyzeFile(context, ref),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 200,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          // Simulating a dashed border with a solid border for now
          border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.6), width: 2),
        ),
        child: analysisState.isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text('Uploading & Analyzing...', style: Theme.of(context).textTheme.titleMedium),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 60,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Drag & Drop or Click to Upload Contract',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    'Supported: JPG, PNG, PDF, DOCX, etc. (Max 10MB)',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
      ),
    );
  }
}
