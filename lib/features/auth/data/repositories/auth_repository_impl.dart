import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/graphql/auth_service.dart';
import '../../../../core/utils/failure.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

/// Implementación del repositorio de autenticación con GraphQL
class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;
  final SharedPreferences _prefs;

  AuthRepositoryImpl({
    required SharedPreferences prefs,
  })  : _authService = AuthService(),
        _prefs = prefs;

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      // Get branchId from preferences or use default
      final branchId = _prefs.getString(AppConstants.prefBranchId) ??
          '00000000-0000-0000-0000-000000000001';

      final result = await _authService.login(
        email: email,
        password: password,
        branchId: branchId,
      );

      if (!result.success) {
        return Left(AuthFailure(result.error ?? 'Login failed'));
      }

      if (result.user == null || result.token == null) {
        return const Left(AuthFailure('Invalid response from server'));
      }

      // Parse user data from GraphQL response
      final userData = result.user!;
      final userModel = UserModel(
        id: userData['id'] as String,
        email: userData['email'] as String,
        name: userData['name'] as String,
        phone: userData['phone'] as String?,
        photoUrl: userData['photoUrl'] as String?,
        role: userData['role'] as String? ?? UserRole.customer.value,
        createdAt: DateTime.tryParse(userData['createdAt'] as String? ?? '') ?? DateTime.now(),
        updatedAt: userData['updatedAt'] != null
            ? DateTime.tryParse(userData['updatedAt'] as String)
            : null,
        isActive: userData['isActive'] as bool? ?? true,
      );

      // Save user data locally
      await _saveUserData(userModel);

      return Right(userModel.toEntity());
    } catch (e) {
      return Left(AuthFailure('Connection error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    try {
      // Get branchId from preferences or use default
      final branchId = _prefs.getString(AppConstants.prefBranchId) ??
          '00000000-0000-0000-0000-000000000001';

      final result = await _authService.register(
        branchId: branchId,
        email: email,
        password: password,
        name: name,
        role: UserRole.customer.value,
      );

      if (!result.success) {
        return Left(AuthFailure(result.error ?? 'Registration failed'));
      }

      if (result.user == null) {
        return const Left(AuthFailure('Invalid response from server'));
      }

      // Parse user data from GraphQL response
      final userData = result.user!;
      final userModel = UserModel(
        id: userData['id'] as String,
        email: userData['email'] as String,
        name: userData['name'] as String,
        phone: phone,
        role: _parseUserRole(userData['role']).value,
        createdAt: DateTime.now(),
        isActive: true,
      );

      await _saveUserData(userModel);

      return Right(userModel.toEntity());
    } catch (e) {
      return Left(AuthFailure('Connection error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _authService.logout();
      await _clearUserData();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure('Error al cerrar sesión: $e'));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final userData = await _authService.getCurrentUser();

      if (userData == null) {
        return const Right(null);
      }

      final userModel = UserModel(
        id: userData['id'] as String,
        email: userData['email'] as String,
        name: userData['name'] as String,
        phone: userData['phone'] as String?,
        photoUrl: userData['photoUrl'] as String?,
        role: userData['role'] as String? ?? UserRole.customer.value,
        createdAt: DateTime.tryParse(userData['createdAt'] as String? ?? '') ?? DateTime.now(),
        updatedAt: userData['updatedAt'] != null
            ? DateTime.tryParse(userData['updatedAt'] as String)
            : null,
        isActive: userData['isActive'] as bool? ?? true,
      );

      return Right(userModel.toEntity());
    } catch (e) {
      return Left(AuthFailure('Error al obtener usuario: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile({
    required String userId,
    String? name,
    String? phone,
    String? photoUrl,
  }) async {
    // Profile update via GraphQL would require a separate mutation
    // For now, return unsupported error as this needs GraphQL mutation
    return const Left(ServerFailure(
        'Profile update via GraphQL not implemented yet'));
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    // Password change via GraphQL would require a separate mutation
    return const Left(ServerFailure(
        'Password change via GraphQL not implemented yet'));
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String email,
  }) async {
    // Password reset via GraphQL would require a separate mutation
    return const Left(ServerFailure(
        'Password reset via GraphQL not implemented yet'));
  }

  @override
  Future<bool> isAuthenticated() async {
    return await _authService.isAuthenticated();
  }

  // ====== MÉTODOS AUXILIARES ======

  UserRole _parseUserRole(dynamic value) {
    if (value is UserRole) return value;
    if (value is String) return UserRole.fromString(value);
    return UserRole.customer;
  }

  Future<void> _saveUserData(UserModel user) async {
    await _prefs.setString(AppConstants.prefUserId, user.id);
    await _prefs.setString(AppConstants.prefUserRole, user.role);
  }

  Future<void> _clearUserData() async {
    await _prefs.remove(AppConstants.prefUserId);
    await _prefs.remove(AppConstants.prefUserRole);
    await _prefs.remove(AppConstants.prefToken);
  }
}
