import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/home/view/tabs/profile/service/profile_api_service.dart';
import '../../features/home/view/tabs/profile/service/profile_local_storage.dart';
import '../network/api_client.dart';
import '../services/meal_api_service.dart';
import '../storage/app_prefs.dart';
import '../storage/token_storage.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator(SharedPreferences prefs) async {
  // 1. SharedPreferences
  sl.registerSingleton<SharedPreferences>(prefs);

  // 2. AppPrefs (preferences manager)
  sl.registerLazySingleton<AppPrefs>(() => AppPrefs(sl<SharedPreferences>()));

  // 3. TokenStorage
  sl.registerLazySingleton<TokenStorage>(
      () => TokenStorage(sl<SharedPreferences>()));

  // 4. ApiClient
  sl.registerLazySingleton<ApiClient>(
      () => ApiClient(sl<TokenStorage>(), sl<AppPrefs>()));

  // 5. ProfileLocalStorage
  sl.registerLazySingleton<ProfileLocalStorage>(
      () => ProfileLocalStorage(sl<SharedPreferences>()));

  // 6. ProfileApiService
  sl.registerLazySingleton<ProfileApiService>(
      () => ProfileApiService(tokenStorage: sl<TokenStorage>()));

  // 7. AuthRepositoryImpl
  sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl<ApiClient>()));

  // 8. MealApiService
  sl.registerLazySingleton<MealApiService>(
      () => MealApiService(sl<ApiClient>()));

  // 9. AuthCubit (now requires AppPrefs and TokenStorage)
  sl.registerFactory<AuthCubit>(() => AuthCubit(
        repo: sl<AuthRepository>(),
        tokenStorage: sl<TokenStorage>(),
        appPrefs: sl<AppPrefs>(),
      ));
}
