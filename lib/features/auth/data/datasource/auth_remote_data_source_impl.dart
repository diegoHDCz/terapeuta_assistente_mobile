import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:terapeuta_assistente_mobile/core/constants/app_constants.dart';
import 'package:terapeuta_assistente_mobile/core/error/common_error.dart';
import 'package:terapeuta_assistente_mobile/core/error/exceptions.dart';
import 'package:terapeuta_assistente_mobile/features/auth/data/datasource/auth_remote_data_source.dart';
import 'package:terapeuta_assistente_mobile/features/auth/domain/models/user_model.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;
  AuthRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw ServerException(CommonError.server.message, CommonError.server);
      }
      return _mapUser(user);
    } catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {'name': name, 'role': 'user'},
      );

      final user = response.user;
      if (user == null) {
        throw ServerException(CommonError.server.message, CommonError.server);
      }
      return _mapUser(user);
    } catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<UserModel> currentUser() async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) {
      throw ServerException(CommonError.unauthenticated.message, CommonError.unauthenticated);
    }
    return _mapUser(user);
  }

  @override
  Future<UserModel> signInWithGoogleAccount() => _signInWithGoogle();

  @override
  Future<UserModel> signUpWithGoogleAccount() => _signInWithGoogle();

  /// Supabase doesn't distinguish sign-in from sign-up for OAuth providers:
  /// the same call creates the account on first login and signs in on the next.
  Future<UserModel> _signInWithGoogle() async {
    try {
      final launched = await supabaseClient.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: AppConstants.googleOAuthRedirectUrl,
      );

      if (!launched) {
        throw ServerException(CommonError.unknown.message, CommonError.unknown);
      }

      final authState = await supabaseClient.auth.onAuthStateChange
          .firstWhere((state) => state.event == AuthChangeEvent.signedIn)
          .timeout(const Duration(minutes: 2));

      final user = authState.session?.user;
      if (user == null) {
        throw ServerException(CommonError.unknown.message, CommonError.unknown);
      }
      return _mapUser(user);
    } on TimeoutException {
      throw ServerException(CommonError.requestTimeout.message, CommonError.requestTimeout);
    } catch (e) {
      throw _mapError(e);
    }
  }

  UserModel _mapUser(User user) {
    final metadata = user.userMetadata ?? {};
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      name: metadata['name'] as String? ?? '',
      role: metadata['role'] as String? ?? 'user',
    );
  }

  ServerException _mapError(Object error) {
    if (error is ServerException) return error;

    if (error is AuthRetryableFetchException) {
      return ServerException(CommonError.noInternet.message, CommonError.noInternet);
    }
    if (error is AuthException) {
      final type = error.statusCode == '429' ? CommonError.tooManyRequests : CommonError.server;
      return ServerException(error.message, type);
    }
    if (error is SocketException) {
      return ServerException(CommonError.noInternet.message, CommonError.noInternet);
    }
    if (error is TimeoutException) {
      return ServerException(CommonError.requestTimeout.message, CommonError.requestTimeout);
    }
    if (error is FormatException || error is TypeError) {
      return ServerException(CommonError.serialization.message, CommonError.serialization);
    }
    return ServerException(CommonError.unknown.message, CommonError.unknown);
  }
}
