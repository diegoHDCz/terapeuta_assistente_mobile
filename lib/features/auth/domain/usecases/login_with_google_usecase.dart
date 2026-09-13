import 'package:fpdart/fpdart.dart';
import 'package:terapeuta_assistente_mobile/core/common/entities/user.dart';
import 'package:terapeuta_assistente_mobile/core/error/failure.dart';
import 'package:terapeuta_assistente_mobile/core/usecase/usecase.dart';
import 'package:terapeuta_assistente_mobile/features/auth/domain/repositories/auth_repository.dart';

class LoginWithGoogleUsecase implements UseCase<User, NoParams> {
  final AuthRepository repository;
  LoginWithGoogleUsecase(this.repository);

  @override
  Future<Either<Failure, User>> call(NoParams params) {
    return repository.loginWithGoogle();
  }
}
