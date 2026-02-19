
import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/models.dart';

class ContractService {
  final ApiService _apiService = ApiService();

  Future<Contract?> uploadContract(String? filePath, String filename, {List<int>? bytes}) async {
    try {
      MultipartFile file;
      if (bytes != null) {
        file = MultipartFile.fromBytes(bytes, filename: filename);
      } else if (filePath != null) {
        file = await MultipartFile.fromFile(filePath, filename: filename);
      } else {
        return null;
      }

      FormData formData = FormData.fromMap({
        "file": file,
      });

      final response = await _apiService.dio.post('/contracts/upload', data: formData);
      if (response.statusCode == 200) {
        return Contract.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print("Upload Error: $e");
      return null;
    }
  }

  Future<List<Contract>> getContracts() async {
    try {
      final response = await _apiService.dio.get('/contracts');
      if (response.statusCode == 200) {
        List<dynamic> list = response.data;
        return list.map((e) => Contract.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print("Get Contracts Error: $e");
      return [];
    }
  }

  Future<Contract?> getContractDetails(int id) async {
    try {
      final response = await _apiService.dio.get('/contracts/$id');
      if (response.statusCode == 200) {
        return Contract.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print("Get Detail Error: $e");
      return null;
    }
  }

  Future<NegotiationChatResponse?> chatWithAI(int contractId, String message) async {
    try {
      final response = await _apiService.dio.post(
        '/contracts/$contractId/chat',
        data: {"contract_id": contractId, "user_message": message},
      );
      if (response.statusCode == 200) {
        return NegotiationChatResponse.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print("Chat Error: $e");
      return null;
    }
  }

  // Helper for download URL
  String getDownloadUrl(int id) {
    return "${_apiService.baseUrl}/contracts/$id/download";
  }
}
