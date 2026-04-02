// FILE: /home/node/.openclaw/workspace/greenpos/frontend/lib/features/auth/presentation/providers/auth_provider.dart
// STATUS: New provider with branchId support for auth context
// PERMISSION ISSUE: Files are owned by root, cannot write directly

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Usuario autenticado con información de sucursal
class AuthUser {
  final String id;
  final String email;
  final String name;
  final String role;
  final bool isActive;
  final String? branchId;
  final String? branchName;

  const AuthUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.isActive = true,
    this.branchId,
    this.branchName,
  });

  AuthUser copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    bool? isActive,
    String? branchId,
    String? branchName,
  }) {
    return AuthUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      branchId: branchId ?? this.branchId,
      branchName: branchName ?? this.branchName,
    );
  }

  /// Verifica si el usuario tiene un branch asignado
  bool get hasBranch => branchId != null && branchId!.isNotEmpty;

  /// Verifica si el usuario es administrador o dueño
  bool get isAdmin => role == 'ADMIN' || role == 'OWNER';

  /// Verifica si el usuario es gerente
  bool get isManager => role == 'MANAGER';

  /// Verifica si el usuario es mesero
  bool get isWaiter => role == 'WAITER';

  /// Verifica si el usuario es de cocina
  bool get isKitchen => role == 'KITCHEN';
}

/// Estado de autenticación
class AuthState {
  final AuthUser? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    AuthUser? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

/// Notifier de autenticación
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  /// Login con credenciales
  Future<bool> login({
    required String email,
    required String password,
    required String branchId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Simular delay de red
      await Future.delayed(const Duration(milliseconds: 500));

      // En producción, esto llamaría al repositorio de auth
      // Por ahora simulamos éxito
      final user = AuthUser(
        id: 'user_123',
        email: email,
        name: 'Usuario Demo',
        role: 'ADMIN',
        isActive: true,
        branchId: branchId,
        branchName: 'Sucursal Principal',
      );

      state = state.copyWith(
        user: user,
        isLoading: false,
        isAuthenticated: true,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Login con usuario mock (desarrollo)
  void loginWithMockUser() {
    final user = AuthUser(
      id: '00000000-0000-0000-0000-000000000001',
      email: 'admin@greenpos.com',
      name: 'Admin User',
      role: 'ADMIN',
      isActive: true,
      branchId: '00000000-0000-0000-0000-000000000001',
      branchName: 'Demo Branch',
    );

    state = state.copyWith(
      user: user,
      isLoading: false,
      isAuthenticated: true,
    );
  }

  /// Logout
  void logout() {
    state = const AuthState();
  }

  /// Actualizar usuario
  void updateUser(AuthUser user) {
    state = state.copyWith(user: user);
  }

  /// Actualizar branch
  void updateBranch(String branchId, String branchName) {
    if (state.user != null) {
      state = state.copyWith(
        user: state.user!.copyWith(
          branchId: branchId,
          branchName: branchName,
        ),
      );
    }
  }
}

/// Provider de autenticación
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

/// Provider del usuario actual
final currentUserProvider = Provider<AuthUser?>((ref) {
  return ref.watch(authProvider).user;
});

/// Provider del branchId actual
final currentBranchIdProvider = Provider<String?>((ref) {
  return ref.watch(currentUserProvider)?.branchId;
});
