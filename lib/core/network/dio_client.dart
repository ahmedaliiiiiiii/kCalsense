import 'package:dio/dio.dart';

Dio buildDio() {
  return Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(seconds: 30),
  ));
}
