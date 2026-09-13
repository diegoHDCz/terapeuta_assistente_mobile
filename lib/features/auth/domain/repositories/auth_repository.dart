import 'package:fpdart/fpdart.dart';
import 'package:terapeuta_assistente_mobile/core/common/entities/user.dart';
import 'package:terapeuta_assistente_mobile/core/error/failure.dart';


abstract interface class AuthRepository {
  Future<Either<Failure,User>> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  });

 Future<Either<Failure, User>> loginWithEmail({
    required String email,
    required String password,
  });

  Future<Either<Failure,User>> loginWithGoogle();
  Future<Either<Failure,User>> signUpWihtGoogle();
  Future<Either<Failure, User>> currentUser();
}