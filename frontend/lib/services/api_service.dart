import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8000";

  static Future<Map<String, dynamic>> uploadContract(PlatformFile file) async {
    print(
      "Starting upload for file: ${file.name}, path: ${file.path}, bytes: ${file.bytes?.length}",
    );
    final request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/api/upload-contract"),
    );

    if (file.bytes != null) {
      // Web or when bytes are available (prefer bytes for web)
      request.files.add(
        http.MultipartFile.fromBytes("file", file.bytes!, filename: file.name),
      );
    } else if (file.path != null) {
      // Mobile/desktop fallback
      request.files.add(await http.MultipartFile.fromPath("file", file.path!));
    } else {
      throw Exception("File has no path or bytes");
    }
    print("Multipart request prepared");

    final response = await request.send();
    print("Response status: ${response.statusCode}");
    final body = await response.stream.bytesToString();
    print("Response body: $body");

    if (response.statusCode != 200) {
      throw Exception(
        "Contract upload failed with status ${response.statusCode}: $body",
      );
    }

    return json.decode(body);
  }

  // (Later) Chat endpoint will be added here
}
