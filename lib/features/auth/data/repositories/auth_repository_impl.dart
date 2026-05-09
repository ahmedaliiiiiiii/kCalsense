import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/auth_response.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient api;

  AuthRepositoryImpl(this.api);

  @override
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await api.post(ApiEndpoints.login, data: {
        "email": email,
        "password": password,
      });

      final data = res.data;
      if (data is Map<String, dynamic>) {
        return AuthResponse.fromJson(data);
      }
      throw ApiException("Invalid response");
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  @override
  Future<AuthResponse> register({
    required String userName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final res = await api.post(ApiEndpoints.register, data: {
        "userName": userName,
        "email": email,
        "password": password,
        "confirmPassword": confirmPassword,
      });

      final data = res.data;
      if (data is Map<String, dynamic>) {
        return AuthResponse.fromJson(data);
      }
      throw ApiException("Invalid response");
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
