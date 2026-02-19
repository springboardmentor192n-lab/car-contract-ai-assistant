
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  late Dio _dio;
  // Use http://10.0.2.2:8000 for Android emulator
  // Use http://127.0.0.1:8000 for iOS simulator or web
  final String baseUrl = "http://127.0.0.1:8001"; 

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));

    _dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
    
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (DioException e, handler) {
        print("API Error: ${e.message}");
        return handler.next(e);
      }
    ));
  }

  Dio get dio => _dio;
}
