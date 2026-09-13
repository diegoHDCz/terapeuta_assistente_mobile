import 'package:fpdart/fpdart.dart';
import 'package:terapeuta_assistente_mobile/core/common/entities/user.dart';
import 'package:terapeuta_assistente_mobile/core/error/failure.dart';
import 'package:terapeuta_assistente_mobile/core/usecase/usecase.dart';
import 'package:terapeuta_assistente_mobile/features/auth/domain/repositories/auth_repository.dart';

class SignUpWithEmailUsecase implements UseCase<User, SignUpWithEmailParams> {
  final AuthRepository repository;
  SignUpWithEmailUsecase(this.repository);

  @override
  Future<Either<Failure, User>> call(SignUpWithEmailParams params) {
    return repository.signUpWithEmail(
      email: params.email,
      password: params.password,
      name: params.name,
    );
  }
}

class SignUpWithEmailParams {
  final String email;
  final String password;
  final String name;
  SignUpWithEmailParams({required this.email, required this.password, required this.name});
}
