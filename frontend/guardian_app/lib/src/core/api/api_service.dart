
import 'package:dio/dio.dart';

abstract class ApiService {
  final Dio dio;

  ApiService(this.dio);

  // You can define common methods here, for example:
  Future<Response<T>> get<T>(String path,
      {Map<String, dynamic>? queryParameters}) {
    return dio.get(path, queryParameters: queryParameters);
  }

  Future<Response<T>> post<T>(String path, {dynamic data}) {
    return dio.post(path, data: data);
  }
}
