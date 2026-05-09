// ignore_for_file: avoid_print, curly_braces_in_flow_control_structures

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../../../core/utils/permission_helper.dart';
import '../api/food_recognition_api.dart';
import '../model/food_recognition_result.dart';
import 'reco_state.dart';

class ScanCubit extends Cubit<ScanState> {
  Function(List<FoodRecognitionResult> results)? onFoodRecognized; // // Ù‚Ø§Ø¦Ù…Ø©
  final ImagePicker _picker = ImagePicker();
  final FoodRecognitionApi _api = FoodRecognitionApi();
  bool _isBottomSheetShown = false;

  ScanCubit() : super(ScanState.initial());

  void clearEffect() {
    if (!isClosed) emit(state.copyWith(clearEffect: true));
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
        if (!isClosed)
          emit(state.copyWith(
              effect:
                  const ScanSnackEffect('Gallery permission denied', false)));
        return;
      }
      final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1200,
          maxHeight: 1200,
          imageQuality: 85);
      if (image != null && !isClosed) {
        emit(state.copyWith(
          image: File(image.path),
          effect: const ScanSnackEffect('Image selected successfully!', true),
          clearResult: true,
          clearError: true,
        ));
      }
    } catch (e) {
      if (!isClosed)
        emit(state.copyWith(
            effect: ScanSnackEffect('Error: ${e.toString()}', false)));
    }
  }

  Future<void> takePhoto() async {
    try {
      bool hasPermission = await PermissionHelper.requestCameraPermission();
      if (!hasPermission) {
        if (!isClosed)
          emit(state.copyWith(
              effect:
                  const ScanSnackEffect('Camera permission denied', false)));
        return;
      }
      final XFile? image = await _picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1200,
          maxHeight: 1200,
          imageQuality: 85);
      if (image != null && !isClosed) {
        emit(state.copyWith(
          image: File(image.path),
          effect: const ScanSnackEffect('Photo captured successfully!', true),
          clearResult: true,
          clearError: true,
        ));
      }
    } catch (e) {
      if (!isClosed)
        emit(state.copyWith(
            effect: ScanSnackEffect('Error: ${e.toString()}', false)));
    }
  }

  Future<String> _saveImageToAppDirectory(File image) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'food_scan_$timestamp.png';
      final savedImage = File('${directory.path}/$fileName');
      await image.copy(savedImage.path);
      print('// Image saved to: ${savedImage.path}');
      return savedImage.path;
    } catch (e) {
      print('âŒ Error saving image: $e');
      return image.path;
    }
  }

  Future<void> analyze() async {
    try {
      if (state.image == null) {
        if (!isClosed)
          emit(state.copyWith(
              effect: const ScanSnackEffect('No image selected', false)));
        return;
      }
      emit(
          state.copyWith(isLoading: true, clearError: true, clearResult: true));
      final List<FoodRecognitionResult> results =
          await _api.recognizeFood(state.image!);
      final savedImagePath = await _saveImageToAppDirectory(state.image!);
      final resultsWithImage =
          results.map((r) => r.copyWith(imagePath: savedImagePath)).toList();
      
      if (!isClosed) {
        _isBottomSheetShown = false;
        emit(state.copyWith(
            isLoading: false,
            result: resultsWithImage,
            effect: const ScanSnackEffect('Analysis complete!', true)));
      }
    } on DioException catch (e) {
      final errorMessage = _handleDioError(e);
      if (!isClosed)
        emit(state.copyWith(
            isLoading: false,
            errorMessage: errorMessage,
            effect: ScanSnackEffect(errorMessage, false)));
    } catch (e) {
      if (!isClosed)
        emit(state.copyWith(
            isLoading: false,
            errorMessage: 'Analysis failed: $e',
            effect: const ScanSnackEffect(
                'Analysis failed. Please try again', false)));
    }
  }

  String _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout)
      return 'Connection timeout. Please check your internet.';
    if (e.type == DioExceptionType.connectionError)
      return 'No internet connection.';
    if (e.response?.statusCode == 401)
      return 'Session expired. Please login again.';
    if (e.response?.statusCode == 500) return 'Server error. Please try later.';
    return 'Network error: ${e.message ?? 'unknown'}';
  }

  FoodRecognitionResult? getCurrentResult() =>
      state.result?.isNotEmpty == true ? state.result!.first : null;
}
