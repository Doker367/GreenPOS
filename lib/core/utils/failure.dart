import 'package:equatable/equatable.dart';

/// Clase base para manejar errores en la aplicación
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Error de servidor
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Error de caché/almacenamiento local
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Error de red/conexión
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Error de autenticación
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// Error de validación
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Error de almacenamiento/operación local (offline)
class LocalFailure extends Failure {
  const LocalFailure(super.message);
}
