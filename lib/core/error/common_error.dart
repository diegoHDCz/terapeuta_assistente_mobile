enum CommonError {
  requestTimeout,
  tooManyRequests,
  noInternet,
  server,
  serialization,
  unknown,
}

extension CommonErrorMessage on CommonError {
  String get message {
    switch (this) {
      case CommonError.requestTimeout:
        return 'A requisição demorou demais. Tente novamente.';
      case CommonError.tooManyRequests:
        return 'Muitas tentativas. Aguarde um momento e tente novamente.';
      case CommonError.noInternet:
        return 'Sem conexão com a internet. Verifique sua rede.';
      case CommonError.server:
        return 'Não foi possível completar a solicitação. Tente novamente mais tarde.';
      case CommonError.serialization:
        return 'Não foi possível processar os dados recebidos.';
      case CommonError.unknown:
        return 'Ocorreu um erro inesperado. Tente novamente.';
    }
  }
}
