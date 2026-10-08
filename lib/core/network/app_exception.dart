class AppException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  AppException({
    required this.message,
    this.statusCode,
    this.details,
  });

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException({required super.message, super.statusCode, super.details});
}

class ServerException extends AppException {
  ServerException({required super.message, super.statusCode, super.details});
}

class AuthException extends AppException {
  AuthException({required super.message, super.statusCode, super.details});
}

class CancelledException extends AppException {
  CancelledException({super.message = 'Operation was cancelled'});
}
