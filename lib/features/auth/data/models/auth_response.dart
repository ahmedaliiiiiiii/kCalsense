class AuthResponse {
  final String userName;
  final String email;
  final String token;

  AuthResponse({
    required this.userName,
    required this.email,
    required this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      userName: (json["userName"] ?? "").toString(),
      email: (json["email"] ?? "").toString(),
      token: (json["token"] ?? "").toString(),
    );
  }
}
