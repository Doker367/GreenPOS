import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/user.dart';

/// Repositorio de autenticación (Interfaz del dominio)
abstract class AuthRepository {
  /// Login con email y contraseña
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  /// Registro de nuevo usuario
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String name,
    String? phone,
  });

  /// Logout
  Future<Either<Failure, void>> logout();

  /// Obtener usuario actual
  Future<Either<Failure, User?>> getCurrentUser();

  /// Actualizar perfil de usuario
  Future<Either<Failure, User>> updateProfile({
    required String userId,
    String? name,
    String? phone,
    String? photoUrl,
  });

  /// Cambiar contraseña
  Future<Either<Failure, void>> changePassword({
    required String oldPassword,
    required String newPassword,
  });

  /// Resetear contraseña
  Future<Either<Failure, void>> resetPassword({
    required String email,
  });

  /// Verificar si el usuario está autenticado
  Future<bool> isAuthenticated();
}
