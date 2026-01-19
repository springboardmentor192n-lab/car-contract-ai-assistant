import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:guardian_app/services/api_service.dart';
import 'package:guardian_app/models/analysis_result.dart';
import 'dart:typed_data';
import 'dart:io';

class ContractAnalysisScreen extends StatefulWidget {
  const ContractAnalysisScreen({super.key});

  @override
  State<ContractAnalysisScreen> createState() => _ContractAnalysisScreenState();
}

class _ContractAnalysisScreenState extends State<ContractAnalysisScreen> {
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();

  XFile? _selectedImageFile;
  Uint8List? _selectedImageBytes;
  AnalysisResult? _analysisResult;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // Read bytes for web display, and keep the file for mobile display and API submission
      final bytes = await image.readAsBytes();
      setState(() {
        _selectedImageFile = image;
        _selectedImageBytes = bytes;
        _analysisResult = null;
        _errorMessage = null;
      });
    }
  }

  Future<void> _analyzeContract() async {
    if (_selectedImageFile == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _apiService.analyzeContract(_selectedImageFile!);
      setState(() {
        _analysisResult = result;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analyze Contract'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildImagePicker(),
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_errorMessage != null)
              _buildErrorWidget()
            else if (_analysisResult != null)
              _buildResultsWidget()
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      children: [
        if (_selectedImageFile == null)
          OutlinedButton.icon(
            icon: const Icon(Icons.image),
            label: const Text('Select Contract Image'),
            onPressed: _pickImage,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 20),
            ),
          )
        else
          Column(
            children: [
              // Conditional image display
              kIsWeb
                  ? Image.memory(_selectedImageBytes!, height: 200)
                  : Image.file(File(_selectedImageFile!.path), height: 200),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Re-select'),
                    onPressed: _pickImage,
                  ),
                  FilledButton.icon(
                    icon: const Icon(Icons.analytics),
                    label: const Text('Analyze Now'),
                    onPressed: _analyzeContract,
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(Icons.error, color: Theme.of(context).colorScheme.onErrorContainer, size: 32),
            const SizedBox(height: 10),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionCard(
          title: 'Extracted Terms',
          child: _analysisResult!.extractedTerms.isEmpty
              ? const Text('No financial terms were automatically found.')
              : Column(
                  children: _analysisResult!.extractedTerms.entries.map((entry) {
                    return ListTile(
                      title: Text(_formatTitle(entry.key)),
                      trailing: Text(entry.value.toString(), style: Theme.of(context).textTheme.bodyLarge),
                    );
                  }).toList(),
                ),
        ),
        const SizedBox(height: 16),
        _buildSectionCard(
          title: 'Potential Risks',
          color: Colors.orange.shade100,
          child: _analysisResult!.potentialRisks.isEmpty
              ? const Text('No potential risks were automatically flagged.')
              : Column(
                  children: _analysisResult!.potentialRisks.map((risk) {
                    return ListTile(
                      leading: const Icon(Icons.warning_amber, color: Colors.orange),
                      title: Text(risk.toString()),
                    );
                  }).toList(),
                ),
        ),
         const SizedBox(height: 16),
        _buildSectionCard(
          title: 'Raw Text (for verification)',
          child: Text(
            _analysisResult!.rawText,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({required String title, required Widget child, Color? color}) {
    return Card(
      elevation: 2,
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const Divider(height: 20),
            child,
          ],
        ),
      ),
    );
  }

  String _formatTitle(String text) {
    return text.replaceAll('_', ' ').split(' ').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
  }
}