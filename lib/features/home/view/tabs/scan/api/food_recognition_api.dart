// ignore_for_file: avoid_print

import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../../../core/storge/token_storage.dart';
import '../model/food_recognition_result.dart';

class FoodRecognitionApi {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  FoodRecognitionApi({
    Dio? dio,
    TokenStorage? tokenStorage,
  })  : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: 'http://foodrecognitionapp.runasp.net',
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 30),
              ),
            ),
        _tokenStorage = tokenStorage ?? TokenStorage();

  // ✅ التعرف على الأكل من الصورة
  Future<FoodRecognitionResult> recognizeFood(File image) async {
    try {
      final token = await _tokenStorage.getToken();
      print('Token: $token');

      if (token == null || token.isEmpty) {
        throw Exception('TOKEN_MISSING');
      }

      print('Preparing image: ${image.path}');
      final form = FormData.fromMap({
        'Image': await MultipartFile.fromFile(
          image.path,
          filename: image.path.split(Platform.pathSeparator).last,
        ),
      });

      print('Sending request to API...');
      final response = await _dio.post(
        '/api/foodrecognition/recognize',
        data: form,
        options: Options(
          contentType: 'multipart/form-data',
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.data == null) {
        throw Exception('EMPTY_RESPONSE');
      }

      final data = response.data;

      if (data is Map<String, dynamic>) {
        return FoodRecognitionResult.fromJson(data);
      } else if (data is Map) {
        return FoodRecognitionResult.fromJson(Map<String, dynamic>.from(data));
      }

      throw Exception('BAD_RESPONSE_FORMAT');
    } on DioException catch (e) {
      print('DioException: $e');
      print('Response: ${e.response}');

      final code = e.response?.statusCode;

      if (code == 401) {
        throw Exception('TOKEN_INVALID');
      }

      throw Exception('NETWORK_ERROR: ${e.message ?? 'unknown'}');
    }
  }

  // ✅ جلب الأكلات الحديثة (Recent Foods)
  Future<List<FoodRecognitionResult>> getRecentRecognitions() async {
    try {
      final token = await _tokenStorage.getToken();

      if (token == null || token.isEmpty) {
        print('No token available for recent foods');
        return [];
      }

      final response = await _dio.get(
        '/api/foodrecognition/recent',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      print('Recent foods response status: ${response.statusCode}');
      print('Recent foods response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is List) {
          return data
              .map((item) => FoodRecognitionResult.fromJson(item))
              .toList();
        } else if (data is Map && data.containsKey('items')) {
          // لو الـ API بيرجع Map بدل List
          final items = data['items'];
          if (items is List) {
            return items
                .map((item) => FoodRecognitionResult.fromJson(item))
                .toList();
          }
        }
      }

      return [];
    } on DioException catch (e) {
      print('DioException in getRecentRecognitions: $e');
      print('Response: ${e.response}');
      return [];
    } catch (e) {
      print('Error getting recent foods: $e');
      return [];
    }
  }

  Future<void> saveMeal(
      FoodRecognitionResult result, int quantityInGrams) async {
    final token = await _tokenStorage.getToken();
    if (token == null) throw Exception('TOKEN_MISSING');
    final response = await _dio.post(
      '/api/Meal/log',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
      data: {
        'foodName': result.foodName, // ✅ استخدم اسم الطعام بدلاً من ID
        'calories': result.calories,
        'protein': result.protein,
        'carbs': result.carbs,
        'fat': result.fats,
        'quantity': quantityInGrams,
        'mealType': 'Snack',
      },
    );
    // معالجة الاستجابة...
  }

// ❌ تم تعليق دالة saveMeal لأن FoodRecognitionResult لا يحتوي على foodId
// إذا كانت هناك حاجة لحفظ الوجبات عبر API، قم بإضافة حقل foodId إلى FoodRecognitionResult وضبطه في fromJson
/*
  Future<void> saveMeal(FoodRecognitionResult result, int quantityInGrams) async {
    final token = await _tokenStorage.getToken();
    if (token == null) throw Exception('TOKEN_MISSING');
    final response = await _dio.post(
      '/api/Meal/log',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
      data: {
        'foodName': result.foodName, // استخدام foodName بدلاً من foodId
        'calories': result.calories,
        'quantity': quantityInGrams,
        'mealType': 'Snack',
      },
    );
    // معالجة الاستجابة...
  }
  */
}
