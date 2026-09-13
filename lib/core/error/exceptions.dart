import 'package:terapeuta_assistente_mobile/core/error/common_error.dart';

class ServerException implements Exception {
  final String message;
  final CommonError type;

  ServerException(this.message, [this.type = CommonError.unknown]);
}
