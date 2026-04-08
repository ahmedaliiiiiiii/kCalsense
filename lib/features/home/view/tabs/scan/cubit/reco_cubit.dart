// ignore_for_file: avoid_print

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../../core/utiles/permission_helper.dart';
import '../api/food_recognition_api.dart';
import '../model/food_recognition_result.dart';
import 'reco_state.dart';

class ScanCubit extends Cubit<ScanState> {
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

  // دالة اختيار صورة من المعرض
  Future<void> pickFromGallery() async {
    try {
      print('===== Starting pickFromGallery =====');

      bool hasPermission = await PermissionHelper.requestGalleryPermission();
      print('Permission granted: $hasPermission');

      if (!hasPermission) {
        print('Permission denied - showing error message');
        if (!isClosed) {
          emit(state.copyWith(
            effect: const ScanSnackEffect('Gallery permission denied', false),
          ));
        }
        return;
      }

      print('Opening gallery...');
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (image != null) {
        print('Image selected: ${image.path}');
        if (!isClosed) {
          emit(state.copyWith(
            image: File(image.path),
            effect: const ScanSnackEffect('Image selected successfully!', true),
            clearResult: true,
            clearError: true,
          ));
        }
      } else {
        print('No image selected');
      }
    } catch (e) {
      print('Gallery error: $e');
      if (!isClosed) {
        emit(state.copyWith(
          effect: ScanSnackEffect('Error: ${e.toString()}', false),
        ));
      }
    }
    print('===== End pickFromGallery =====');
  }

  // دالة التقاط صورة بالكاميرا
  Future<void> takePhoto() async {
    try {
      print('===== Starting takePhoto =====');

      bool hasPermission = await PermissionHelper.requestCameraPermission();
      print('Camera permission granted: $hasPermission');

      if (!hasPermission) {
        if (!isClosed) {
          emit(state.copyWith(
            effect: const ScanSnackEffect('Camera permission denied', false),
          ));
        }
        return;
      }

      print('Opening camera...');
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (image != null) {
        print('Photo captured: ${image.path}');
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
      print('Camera error: $e');
      if (!isClosed) {
        emit(state.copyWith(
          effect: ScanSnackEffect('Error: ${e.toString()}', false),
        ));
      }
    }
    print('===== End takePhoto =====');
  }

  // دالة التحليل الحقيقية مع API
  Future<void> analyze() async {
    try {
      // التحقق من وجود صورة
      if (state.image == null) {
        if (!isClosed) {
          emit(state.copyWith(
            effect: const ScanSnackEffect('No image selected', false),
          ));
        }
        return;
      }

      // بدء التحميل
      if (!isClosed) {
        emit(state.copyWith(
          isLoading: true,
          clearError: true,
          clearResult: true,
        ));
      }

      print('===== Starting analysis with API =====');
      print('Image path: ${state.image!.path}');

      // استدعاء API
      final FoodRecognitionResult result =
          await _api.recognizeFood(state.image!);

      print('Analysis result: ${result.foodName}');
      print('Calories: ${result.calories}');
      print('Protein: ${result.protien}');
      print('Carbs: ${result.carbs}');
      print('Fats: ${result.fats}');
      print('Category: ${result.categoryName}');
      print('Confidence: ${result.confidenceScore}');

      // تحديث الحالة بالنتيجة
      if (!isClosed) {
        _isBottomSheetShown = false;
        emit(state.copyWith(
          isLoading: false,
          result: result,
          effect: const ScanSnackEffect('Analysis complete!', true),
        ));
      }

      print('===== Analysis completed successfully =====');
    } on DioException catch (e) {
      // معالجة أخطاء Dio
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
      // معالجة أي أخطاء أخرى
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

  // دالة مساعدة لمعالجة أخطاء Dio
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
}
