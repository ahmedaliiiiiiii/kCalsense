import 'package:get_it/get_it.dart';

import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/presention/cubit/authcubit_cubit.dart';
import '../../features/home/view/tabs/profile/service/profile_api_service.dart';
import '../../features/home/view/tabs/profile/service/profile_local_storage.dart';
import '../network/api_client.dart';
import '../storge/token_storage.dart';

final sl = GetIt.instance;

void setupServiceLocator() {
  sl.registerLazySingleton<TokenStorage>(() => TokenStorage());
  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl<TokenStorage>()));

  sl.registerLazySingleton<ProfileLocalStorage>(() => ProfileLocalStorage());
  sl.registerLazySingleton<ProfileApiService>(
      () => ProfileApiService(tokenStorage: sl<TokenStorage>()));

  sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl<ApiClient>()));
  sl.registerFactory<AuthCubit>(
      () => AuthCubit(repo: sl<AuthRepository>(), storage: sl<TokenStorage>()));
}
