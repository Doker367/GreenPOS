import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/providers/repository_providers.dart';

/// Estado de autenticación
class AuthState {
  final User? user;
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
    User? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

/// Notifier de autenticación
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(const AuthState()) {
    // Verificar estado de autenticación al iniciar
    _checkAuthStatus();
  }

  /// Verificar si hay un usuario autenticado
  Future<void> _checkAuthStatus() async {
    state = state.copyWith(isLoading: true);

    final result = await _authRepository.getCurrentUser();

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (user) => state = state.copyWith(
        user: user,
        isLoading: false,
        isAuthenticated: user != null,
      ),
    );
  }

  /// Login
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authRepository.login(
      email: email,
      password: password,
    );

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (user) => state = state.copyWith(
        user: user,
        isLoading: false,
        isAuthenticated: true,
        error: null,
      ),
    );
  }

  /// Registro
  Future<void> register({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authRepository.register(
      email: email,
      password: password,
      name: name,
      phone: phone,
    );

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (user) => state = state.copyWith(
        user: user,
        isLoading: false,
        isAuthenticated: true,
        error: null,
      ),
    );
  }

  /// Logout
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    final result = await _authRepository.logout();

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (_) => state = const AuthState(
        isAuthenticated: false,
        isLoading: false,
      ),
    );
  }

  /// Actualizar perfil
  Future<void> updateProfile({
    required String userId,
    String? name,
    String? phone,
    String? photoUrl,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authRepository.updateProfile(
      userId: userId,
      name: name,
      phone: phone,
      photoUrl: photoUrl,
    );

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (user) => state = state.copyWith(
        user: user,
        isLoading: false,
        error: null,
      ),
    );
  }

  /// Limpiar error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider del notifier de autenticación
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.watch(authRepositoryProvider)),
);

/// Provider para verificar si el usuario es admin
final isAdminProvider = Provider<bool>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.user?.role.value == 'admin';
});
