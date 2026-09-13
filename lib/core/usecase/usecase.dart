import 'package:fpdart/fpdart.dart';
import 'package:terapeuta_assistente_mobile/core/error/failure.dart';

abstract interface class UseCase<SuccessType, Params> {
  Future<Either<Failure, SuccessType>> call(Params params);
}

class NoParams {}