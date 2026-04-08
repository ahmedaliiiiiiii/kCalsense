// lib/features/auth/presention/cubit/authcubit_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/user_friendly_error.dart';
import '../../../../core/storge/shared_preferences_helper.dart';
import '../../../../core/storge/token_storage.dart';
import '../../data/repositories/auth_repository.dart';
import 'authcubit_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository repo;
  final TokenStorage storage;

  AuthCubit({required this.repo, required this.storage})
      : super(const AuthState());

  void clearError() => emit(state.copyWith(error: null));

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final user = await repo.login(email: email, password: password);
      await storage.saveAuth(
        token: user.token,
        email: user.email,
        userName: user.userName,
      );
      // ✅ حفظ حالة تسجيل الدخول
      await SharedPreferencesHelper.setLoggedIn(true);
      emit(state.copyWith(loading: false, user: user, error: null));
    } catch (e) {
      final msg = userFriendlyMessage(e is ApiException ? e : e);
      emit(state.copyWith(loading: false, error: msg));
    }
  }

  Future<void> register({
    required String userName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final user = await repo.register(
        userName: userName,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );
      await storage.saveAuth(
        token: user.token,
        email: user.email,
        userName: user.userName,
      );
      // ✅ حفظ حالة تسجيل الدخول
      await SharedPreferencesHelper.setLoggedIn(true);
      emit(state.copyWith(loading: false, user: user, error: null));
    } catch (e) {
      final msg = userFriendlyMessage(e is ApiException ? e : e);
      emit(state.copyWith(loading: false, error: msg));
    }
  }
}
