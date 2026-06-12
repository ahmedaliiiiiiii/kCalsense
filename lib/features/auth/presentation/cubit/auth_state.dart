import 'package:equatable/equatable.dart';

import '../../data/models/auth_response.dart';

class AuthState extends Equatable {
  final bool loading;
  final String? error;
  final AuthResponse? user;

  const AuthState({
    this.loading = false,
    this.error,
    this.user,
  });

  AuthState copyWith({
    bool? loading,
    String? error,
    AuthResponse? user,
  }) {
    return AuthState(
      loading: loading ?? this.loading,
      error: error ?? this.error,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [loading, error, user];
}
