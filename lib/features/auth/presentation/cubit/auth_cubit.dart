import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/user_friendly_error.dart';
import '../../../../core/storage/app_prefs.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository repo;
  final TokenStorage tokenStorage;
  final AppPrefs appPrefs;

  late final LoginUseCase _loginUseCase;
  late final RegisterUseCase _registerUseCase;

  AuthCubit({
    required this.repo,
    required this.tokenStorage,
    required this.appPrefs,
  }) : super(const AuthState()) {
    _loginUseCase = LoginUseCase(repo);
    _registerUseCase = RegisterUseCase(repo);
  }

  void clearError() => emit(state.copyWith(error: null));

  Future<void> login({required String email, required String password}) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final user = await _loginUseCase(email: email, password: password);

      await tokenStorage.saveAuth(
        token: user.token,
        email: user.email,
        userName: user.userName,
      );
      await appPrefs.setLoggedIn(true);
      // ✅ تعيين الإعداد كمكتمل – لتجنب إعادة توجيه إلى Setup
      await appPrefs.setSetupCompleted(true);

      emit(state.copyWith(loading: false, user: user));
    } catch (e) {
      final msg = userFriendlyMessage(
          e is ApiException ? e : ApiException(e.toString()));
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
      final user = await _registerUseCase(
        userName: userName,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );

      await tokenStorage.saveAuth(
        token: user.token,
        email: user.email,
        userName: user.userName,
      );
      await appPrefs.setLoggedIn(true);
      // ✅ بعد التسجيل يحتاج إلى إكمال الإعداد – لا نضع setupCompleted = true

      emit(state.copyWith(loading: false, user: user));
    } catch (e) {
      final msg = userFriendlyMessage(
          e is ApiException ? e : ApiException(e.toString()));
      emit(state.copyWith(loading: false, error: msg));
    }
  }

  Future<void> logout() async {
    await tokenStorage.clear();
    await appPrefs.setLoggedIn(false);
    await appPrefs.setSetupCompleted(false);
    emit(const AuthState());
  }
}
