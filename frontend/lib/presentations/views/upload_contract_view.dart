import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/presentations/widgets/primary_button.dart';
import 'contract_analysis_view.dart';

class UploadContractView extends StatefulWidget {
  const UploadContractView({super.key});

  @override
  State<UploadContractView> createState() => _UploadContractViewState();
}

class _UploadContractViewState extends State<UploadContractView> {
  PlatformFile? file;
  bool loading = false;

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowedExtensions: ['pdf', 'jpg', 'png'],
      type: FileType.custom,
    );

    if (result != null) {
      setState(() {
        file = result.files.single;
      });
    }
  }

  Future<void> upload() async {
    if (file == null) return;

    setState(() => loading = true);

    try {
      final response = await ApiService.uploadContract(file!);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ContractAnalysisView(slaData: response['sla_extracted']),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Upload failed: $e")));
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Contract")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PrimaryButton(
              title: "Select Contract File",
              icon: Icons.upload_file,
              onPressed: pickFile,
            ),

            if (file != null) ...[
              const SizedBox(height: 12),
              Text(file!.name, style: const TextStyle(color: Colors.white70)),
            ],

            const Spacer(),

            PrimaryButton(
              title: "Analyze Contract",
              icon: Icons.analytics,
              loading: loading,
              onPressed: upload,
            ),
          ],
        ),
      ),
    );
  }
}
