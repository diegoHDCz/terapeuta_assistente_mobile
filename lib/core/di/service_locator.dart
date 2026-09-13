import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/data/datasource/auth_remote_data_source.dart';
import '../../features/auth/data/datasource/auth_remote_data_source_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/usecases/current_user_usecase.dart';
import '../../features/auth/domain/usecases/login_with_email_usecase.dart';
import '../../features/auth/domain/usecases/login_with_google_usecase.dart';
import '../../features/auth/domain/usecases/sign_up_with_email_usecase.dart';
import '../../features/auth/domain/usecases/sign_up_with_google_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../common/widgets/cubits/app_user_cubit.dart';
import '../network/dio_client.dart';
import '../supabase/supabase_service.dart';

final GetIt sl = GetIt.instance;

/// Registers core singletons. Call after [SupabaseService.initialize] so
/// `Supabase.instance.client` is ready.
///
/// Feature modules should register their own data sources/repositories/cubits
/// here (or in their own `injection_container.dart` invoked from this one)
/// rather than growing this file into a dumping ground.
Future<void> setupServiceLocator() async {
  sl.registerLazySingleton<Dio>(() => DioClient.instance);
  sl.registerLazySingleton<SupabaseClient>(() => SupabaseService.client);

  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));

  sl.registerLazySingleton(() => CurrentUserUsecase(sl()));
  sl.registerLazySingleton(() => LoginWithEmailUsecase(sl()));
  sl.registerLazySingleton(() => SignUpWithEmailUsecase(sl()));
  sl.registerLazySingleton(() => LoginWithGoogleUsecase(sl()));
  sl.registerLazySingleton(() => SignUpWithGoogleUsecase(sl()));

  sl.registerLazySingleton(() => AppUserCubit());
  sl.registerLazySingleton(
    () => AuthBloc(
      currentUserUsecase: sl(),
      loginWithEmailUsecase: sl(),
      signUpWithEmailUsecase: sl(),
      loginWithGoogleUsecase: sl(),
      signUpWithGoogleUsecase: sl(),
      appUserCubit: sl(),
    ),
  );
}
