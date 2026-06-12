import '../../data/models/auth_response.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repo;
  LoginUseCase(this._repo);

  Future<AuthResponse> call({required String email, required String password}) =>
      _repo.login(email: email, password: password);
}

class RegisterUseCase {
  final AuthRepository _repo;
  RegisterUseCase(this._repo);

  Future<AuthResponse> call({
    required String userName,
    required String email,
    required String password,
    required String confirmPassword,
  }) =>
      _repo.register(
        userName: userName,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );
}
