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

  //chatbot implementation
  static Future<String> chatWithContract({
    required Map<String, dynamic> slaData,
    required String question,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/chat"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"sla_data": slaData, "question": question}),
    );

    print("Chat response status: ${response.statusCode}");
    print("Chat response body: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Chat request failed");
    }

    final decoded = jsonDecode(response.body);
    return decoded["answer"];
  }

  //price estimator implementation
  static Future<Map<String, dynamic>> getPriceEstimate({
    String? vin,
    String? make,
    String? model,
    int? year,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/price-estimate"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "vin": vin,
        "make": make,
        "model": model,
        "year": year,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Price estimation failed");
    }

    return jsonDecode(response.body);
  }

  //price chat implementation
  static Future<Map<String, dynamic>> getPriceChatEstimate({
    required String vin,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/price-chat"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"vin": vin}),
    );

    if (response.statusCode != 200) {
      throw Exception("Price chat estimation failed");
    }

    return jsonDecode(response.body);
  }
}
