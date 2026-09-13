
import 'package:terapeuta_assistente_mobile/features/auth/domain/models/user_model.dart';

abstract interface class AuthRemoteDataSource {
  Future<UserModel> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  });
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<UserModel> signUpWithGoogleAccount();
  Future<UserModel> signInWithGoogleAccount();
  Future<UserModel> currentUser();
}