import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../storage/app_prefs.dart';
import '../storage/token_storage.dart';
import 'api_endpoints.dart';

class ApiClient {
  final Dio dio;
  final TokenStorage _storage;
  final AppPrefs _appPrefs;

  ApiClient(this._storage, this._appPrefs)
      : dio = Dio(
          BaseOptions(
            baseUrl: ApiEndpoints.baseUrl,
            connectTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 20),
            headers: {'Content-Type': 'application/json'},
          ),
        ) {
    // Auth interceptor
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = _storage.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          // Token expired — clear and let the router redirect to login
          _storage.clear();
          _appPrefs.setLoggedIn(false);
        }
        handler.next(error);
      },
    ));

    // LogInterceptor only in debug mode
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestBody: false,
        responseBody: false,
        error: true,
      ));
    }
  }

  Future<Response<T>> post<T>(String path, {Object? data, Map<String, dynamic>? queryParameters}) =>
      dio.post<T>(path, data: data, queryParameters: queryParameters);

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParameters}) =>
      dio.get<T>(path, queryParameters: queryParameters);

  Future<Response<T>> put<T>(String path, {Object? data, Map<String, dynamic>? queryParameters}) =>
      dio.put<T>(path, data: data, queryParameters: queryParameters);

  Future<Response<T>> delete<T>(String path, {Object? data}) =>
      dio.delete<T>(path, data: data);
}
