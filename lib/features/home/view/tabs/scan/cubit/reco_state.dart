import 'dart:io';

import '../model/food_recognition_result.dart';

class ScanSnackEffect {
  final String message;
  final bool success;
  const ScanSnackEffect(this.message, this.success);
}

class ScanState {
  final File? image;
  final bool isLoading;
  final List<FoodRecognitionResult>? result; // ✅ قائمة
  final String? errorMessage;
  final ScanSnackEffect? effect;
  final bool resultShown;

  const ScanState({
    required this.image,
    required this.isLoading,
    required this.result,
    required this.errorMessage,
    required this.effect,
    this.resultShown = false,
  });

  factory ScanState.initial() => const ScanState(
        image: null,
        isLoading: false,
        result: null,
        errorMessage: null,
        effect: null,
        resultShown: false,
      );

  ScanState copyWith({
    File? image,
    bool? isLoading,
    List<FoodRecognitionResult>? result,
    String? errorMessage,
    ScanSnackEffect? effect,
    bool? resultShown,
    bool clearResult = false,
    bool clearError = false,
    bool clearEffect = false,
  }) {
    return ScanState(
      image: image ?? this.image,
      isLoading: isLoading ?? this.isLoading,
      result: clearResult ? null : (result ?? this.result),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      effect: clearEffect ? null : (effect ?? this.effect),
      resultShown: resultShown ?? this.resultShown,
    );
  }
}
