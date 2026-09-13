import 'package:fpdart/fpdart.dart';
import 'package:terapeuta_assistente_mobile/core/common/entities/user.dart';
import 'package:terapeuta_assistente_mobile/core/error/failure.dart';
import 'package:terapeuta_assistente_mobile/core/usecase/usecase.dart';
import 'package:terapeuta_assistente_mobile/features/auth/domain/repositories/auth_repository.dart';

class LoginWithEmailUsecase implements UseCase<User, LoginWithEmailParams> {
  final AuthRepository repository;
  LoginWithEmailUsecase(this.repository);

  @override
  Future<Either<Failure, User>> call(LoginWithEmailParams params) {
    return repository.loginWithEmail(email: params.email, password: params.password);
  }
}

class LoginWithEmailParams {
  final String email;
  final String password;
  LoginWithEmailParams({required this.email, required this.password});
}
