// ignore_for_file: curly_braces_in_flow_control_structures, await_only_futures

import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../../../core/di/service_locator.dart';
import '../../../../../../core/storage/token_storage.dart';
import '../model/food_recognition_result.dart';

class FoodRecognitionApi {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  FoodRecognitionApi({Dio? dio, TokenStorage? tokenStorage})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: 'http://foodrecognitionapp.runasp.net',
              connectTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(seconds: 30),
            )),
        _tokenStorage = tokenStorage ?? sl<TokenStorage>();

  Future<List<FoodRecognitionResult>> recognizeFood(File image) async {
    try {
      final token = await _tokenStorage.getToken();
      if (token == null || token.isEmpty) throw Exception('TOKEN_MISSING');

      final form = FormData.fromMap({
        'Image': await MultipartFile.fromFile(image.path,
            filename: image.path.split(Platform.pathSeparator).last),
      });

      log("📤 Sending image: ${image.path}");
      final response = await _dio.post(
        '/api/FoodRecognition/recognize',
        data: form,
        options: Options(
            contentType: 'multipart/form-data',
            headers: {'Authorization': 'Bearer $token'}),
      );

      log("📥 Response status: ${response.statusCode}");
      log("📥 Response data: ${response.data}");

      if (response.data == null) throw Exception('EMPTY_RESPONSE');
      final data = response.data;

      List<FoodRecognitionResult> results = [];

      if (data is List) {
        log("✅ Response is List of ${data.length} items");
        for (var item in data) {
          final map = Map<String, dynamic>.from(item as Map);
          results.add(FoodRecognitionResult.fromJson(map));
        }
      } else if (data is Map) {
        log("✅ Response is a single Map");
        final map = Map<String, dynamic>.from(data);
        results.add(FoodRecognitionResult.fromJson(map));
      } else {
        throw Exception('BAD_RESPONSE_FORMAT: ${data.runtimeType}');
      }

      log("🎯 Total results parsed: ${results.length}");
      return results;
    } on DioException catch (e) {
      log("❌ Dio error: $e");
      if (e.response?.statusCode == 401) throw Exception('TOKEN_INVALID');
      throw Exception('NETWORK_ERROR: ${e.message ?? 'unknown'}');
    }
  }
}
