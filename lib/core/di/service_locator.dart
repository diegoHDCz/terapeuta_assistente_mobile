import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
}
