// ignore_for_file: avoid_print, unused_element

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../../core/utiles/permission_helper.dart';
import '../api/food_recognition_api.dart';
import '../model/food_recognition_result.dart';
import 'reco_state.dart';

class ScanCubit extends Cubit<ScanState> {
  Function(FoodRecognitionResult)? onFoodRecognized;
  final ImagePicker _picker = ImagePicker();
  final FoodRecognitionApi _api = FoodRecognitionApi();
  bool _isBottomSheetShown = false;

  ScanCubit() : super(ScanState.initial());

  void clearEffect() {
    if (!isClosed) {
      emit(state.copyWith(clearEffect: true));
    }
  }

  Future<void> clearImage() async {
    if (!isClosed) {
      _isBottomSheetShown = false;
      emit(ScanState.initial());
    }
  }

  bool canShowBottomSheet() {
    if (state.result != null && !_isBottomSheetShown) {
      _isBottomSheetShown = true;
      return true;
    }
    return false;
  }

  Future<void> pickFromGallery() async {
    try {
      bool hasPermission = await PermissionHelper.requestGalleryPermission();

      if (!hasPermission) {
        if (!isClosed) {
          emit(state.copyWith(
            effect: const ScanSnackEffect('Gallery permission denied', false),
          ));
        }
        return;
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (image != null) {
        if (!isClosed) {
          emit(state.copyWith(
            image: File(image.path),
            effect: const ScanSnackEffect('Image selected successfully!', true),
            clearResult: true,
            clearError: true,
          ));
        }
      }
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(
          effect: ScanSnackEffect('Error: ${e.toString()}', false),
        ));
      }
    }
  }

  Future<void> takePhoto() async {
    try {
      bool hasPermission = await PermissionHelper.requestCameraPermission();

      if (!hasPermission) {
        if (!isClosed) {
          emit(state.copyWith(
            effect: const ScanSnackEffect('Camera permission denied', false),
          ));
        }
        return;
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (image != null) {
        if (!isClosed) {
          emit(state.copyWith(
            image: File(image.path),
            effect: const ScanSnackEffect('Photo captured successfully!', true),
            clearResult: true,
            clearError: true,
          ));
        }
      }
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(
          effect: ScanSnackEffect('Error: ${e.toString()}', false),
        ));
      }
    }
  }

  Future<void> _saveMealLocally(FoodRecognitionResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final mealsKey = 'meals_$today';
    final List<String> meals = prefs.getStringList(mealsKey) ?? [];
    meals.add(jsonEncode({
      'foodName': result.foodName,
      'calories': result.calories,
      'protein': result.protein,
      'carbs': result.carbs,
      'fats': result.fats,
      'imagePath': result.imagePath,
      'timestamp': DateTime.now().toIso8601String(),
    }));
    await prefs.setStringList(mealsKey, meals);
  }

  // ✅ دالة لحفظ الصورة في مجلد التطبيق
  Future<String> _saveImageToAppDirectory(File image) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'food_scan_$timestamp.png';
      final savedImage = File('${directory.path}/$fileName');

      await image.copy(savedImage.path);
      print('✅ Image saved to: ${savedImage.path}');
      return savedImage.path;
    } catch (e) {
      print('❌ Error saving image: $e');
      return image.path;
    }
  }

  Future<void> analyze() async {
    try {
      if (state.image == null) {
        if (!isClosed) {
          emit(state.copyWith(
            effect: const ScanSnackEffect('No image selected', false),
          ));
        }
        return;
      }

      if (!isClosed) {
        emit(state.copyWith(
          isLoading: true,
          clearError: true,
          clearResult: true,
        ));
      }

      print('===== Starting analysis with API =====');
      print('Image path: ${state.image!.path}');

      final result = await _api.recognizeFood(state.image!);

      // ✅ حفظ الصورة في مجلد التطبيق
      final savedImagePath = await _saveImageToAppDirectory(state.image!);

      // ✅ إضافة الصورة للنتيجة
      final resultWithImage = result.copyWith(imagePath: savedImagePath);

      print('🖼️ Saved image path: $savedImagePath');
      print('📊 Confidence: ${resultWithImage.confidenceScore}');

      if (onFoodRecognized != null) {
        onFoodRecognized!(resultWithImage);
      }

      if (!isClosed) {
        _isBottomSheetShown = false;
        emit(state.copyWith(
          isLoading: false,
          result: resultWithImage,
          effect: const ScanSnackEffect('Analysis complete!', true),
        ));
      }

      print('===== Analysis completed successfully =====');
    } on DioException catch (e) {
      print('Dio error: $e');
      String errorMessage = _handleDioError(e);

      if (!isClosed) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: errorMessage,
          effect: ScanSnackEffect(errorMessage, false),
        ));
      }
    } catch (e) {
      print('General error: $e');

      if (!isClosed) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Analysis failed: ${e.toString()}',
          effect:
              const ScanSnackEffect('Analysis failed. Please try again', false),
        ));
      }
    }
  }

  String _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Connection timeout. Please check your internet.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'No internet connection.';
    }
    if (e.response?.statusCode == 401) {
      return 'Session expired. Please login again.';
    }
    if (e.response?.statusCode == 500) {
      return 'Server error. Please try later.';
    }
    return 'Network error: ${e.message ?? 'unknown'}';
  }

  FoodRecognitionResult? getCurrentResult() {
    return state.result;
  }
}
