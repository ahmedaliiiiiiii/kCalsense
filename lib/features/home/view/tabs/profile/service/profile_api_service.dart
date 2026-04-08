// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../../../core/storge/token_storage.dart';
import '../viewmodel/profile_api_models.dart';

class ProfileApiService {
  static const String _base = "http://foodrecognitionapp.runasp.net";
  final TokenStorage _tokenStorage;

  ProfileApiService({TokenStorage? tokenStorage})
      : _tokenStorage = tokenStorage ?? TokenStorage();

  Future<Map<String, String>> _headers() async {
    final token = await _tokenStorage.getToken();
    return {
      "Content-Type": "application/json",
      "Accept": "application/json",
      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
    };
  }

  Future<ProfileSetupResponse> setup(ProfileSetupRequest req) async {
    final res = await http.post(
      Uri.parse("$_base/api/Profile/setup"),
      headers: await _headers(),
      body: jsonEncode(req.toJson()),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("setup failed: ${res.statusCode} ${res.body}");
    }

    return ProfileSetupResponse.fromJson(jsonDecode(res.body));
  }

  Future<void> update(ProfileSetupRequest req) async {
    final res = await http.put(
      Uri.parse("$_base/api/Profile/update"),
      headers: await _headers(),
      body: jsonEncode(req.toJson()),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("update failed: ${res.statusCode} ${res.body}");
    }
  }
}
