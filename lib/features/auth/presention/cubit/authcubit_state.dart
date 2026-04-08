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

  static const _noChange = Object();

  AuthState copyWith({
    bool? loading,
    Object? error = _noChange,
    AuthResponse? user,
  }) {
    return AuthState(
      loading: loading ?? this.loading,
      error: identical(error, _noChange) ? this.error : error as String?,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [loading, error, user];
}
