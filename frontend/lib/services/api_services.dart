import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://10.0.2.2:8000";

  static Future<Map<String, dynamic>> uploadContract(File file) async {
    final request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/api/upload-contract"),
    );

    request.files.add(await http.MultipartFile.fromPath("file", file.path));

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception("Contract upload failed");
    }

    return json.decode(body);
  }

  // (Later) Chat endpoint will be added here
}
