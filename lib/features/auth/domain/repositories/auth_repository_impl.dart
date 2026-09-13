import 'package:fpdart/fpdart.dart';
import 'package:terapeuta_assistente_mobile/core/common/entities/user.dart';
import 'package:terapeuta_assistente_mobile/core/error/exceptions.dart';
import 'package:terapeuta_assistente_mobile/core/error/failure.dart';
import 'package:terapeuta_assistente_mobile/features/auth/data/datasource/auth_remote_data_source.dart';
import 'package:terapeuta_assistente_mobile/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, User>> currentUser() {
    return _call(remoteDataSource.currentUser);
  }

  @override
  Future<Either<Failure, User>> loginWithEmail({
    required String email,
    required String password,
  }) {
    return _call(
      () => remoteDataSource.signInWithEmailAndPassword(email: email, password: password),
    );
  }

  @override
  Future<Either<Failure, User>> loginWithGoogle() {
    return _call(remoteDataSource.signInWithGoogleAccount);
  }

  @override
  Future<Either<Failure, User>> signUpWihtGoogle() {
    return _call(remoteDataSource.signUpWithGoogleAccount);
  }

  @override
  Future<Either<Failure, User>> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) {
    return _call(
      () => remoteDataSource.signUpWithEmailAndPassword(name: name, email: email, password: password),
    );
  }

  Future<Either<Failure, User>> _call(Future<User> Function() action) async {
    try {
      final user = await action();
      return Right(user);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (_) {
      return Left(Failure());
    }
  }
}
