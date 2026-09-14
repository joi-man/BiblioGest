class Failure {
  final String message;
  final int? statusCode;

  const Failure({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => 'Failure(message: $message, statusCode: $statusCode)';
}

class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'Error del servidor',
    super.statusCode,
  });

  factory ServerFailure.fromResponse(dynamic response) {
    return ServerFailure(
      message: response['detail'] ?? 'Error del servidor',
      statusCode: response['statusCode'],
    );
  }
}

class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Error de cache',
  });
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Error de conexion',
  });
}
