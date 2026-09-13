import 'package:dio/dio.dart';

import '../constants/app_constants.dart';

/// Shared [Dio] instance preconfigured with [AppConstants.baseUrl].
///
/// Add auth/logging interceptors here as the app grows.
class DioClient {
  DioClient._();

  static final Dio instance = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );
}
