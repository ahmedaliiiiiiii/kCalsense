import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final DioExceptionType? dioType;

  ApiException(this.message, {this.statusCode, this.dioType});

  factory ApiException.fromDio(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return ApiException("TIMEOUT",
          statusCode: e.response?.statusCode, dioType: e.type);
    }

    if (e.type == DioExceptionType.connectionError) {
      return ApiException("NO_INTERNET",
          statusCode: e.response?.statusCode, dioType: e.type);
    }

    if (e.type == DioExceptionType.cancel) {
      return ApiException("CANCELLED",
          statusCode: e.response?.statusCode, dioType: e.type);
    }

    final status = e.response?.statusCode;
    final data = e.response?.data;

    String? extracted;

    if (data is Map) {
      final errors = data["errors"];

      if (errors is List && errors.isNotEmpty) {
        final first = errors.first;
        if (first is Map) {
          final list = first["errors"];
          if (list is List && list.isNotEmpty) {
            extracted = list.first.toString();
          }
        }
      }

      if (extracted == null && errors is Map && errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) {
          extracted = first.first.toString();
        }
      }

      extracted ??= (data["message"] ??
              data["errorMessage"] ??
              data["error"] ??
              data["title"])
          ?.toString();
    }

    if (extracted == null && data is String && data.trim().isNotEmpty) {
      extracted = data.trim();
    }

    extracted ??= e.message ?? "UNKNOWN";

    return ApiException(extracted, statusCode: status, dioType: e.type);
  }

  @override
  String toString() => message;
}
