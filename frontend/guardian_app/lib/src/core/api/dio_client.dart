import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://car-contract-ai-assistant.onrender.com', // Production backend URL
    connectTimeout: const Duration(milliseconds: 5000),
    receiveTimeout: const Duration(milliseconds: 3000),
  ));

  dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  
  // You can add interceptors for handling auth tokens here
  // dio.interceptors.add(InterceptorsWrapper(
  //   onRequest:(options, handler) async {
  //     // Get token from storage
  //     // final token = await ref.read(secureStorageProvider).read(key: 'auth_token');
  //     // if (token != null) {
  //     //   options.headers['Authorization'] = 'Bearer $token';
  //     // }
  //     return handler.next(options);
  //   },
  // ));

  return dio;
});