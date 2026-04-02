import 'package:graphql_flutter/graphql_flutter.dart';
import 'client.dart';
import 'queries.dart';

/// Result wrapper for authentication operations
class AuthResult {
  final bool success;
  final String? token;
  final Map<String, dynamic>? user;
  final String? error;

  AuthResult({
    required this.success,
    this.token,
    this.user,
    this.error,
  });

  factory AuthResult.fromSuccess(String token, Map<String, dynamic> user) {
    return AuthResult(
      success: true,
      token: token,
      user: user,
    );
  }

  factory AuthResult.fromError(String error) {
    return AuthResult(
      success: false,
      error: error,
    );
  }
}

/// GraphQL Authentication Service
/// Handles login, register, logout, and token management
class AuthService {
  final GraphQLClient _client;

  AuthService() : _client = GraphQLClientSingleton.client;

  /// Login with email, password and branch ID
  Future<AuthResult> login({
    required String email,
    required String password,
    required String branchId,
  }) async {
    final options = MutationOptions(
      document: gql(GQLMutations.login),
      variables: LoginVariables(
        email: email,
        password: password,
        branchId: branchId,
      ).toJson(),
    );

    try {
      final result = await _client.mutate(options);

      if (result.hasException) {
        return AuthResult.fromError(
          result.exception?.graphqlErrors.firstOrNull?.message ??
              'Login failed',
        );
      }

      final data = result.data?['login'];
      if (data == null) {
        return AuthResult.fromError('Invalid response from server');
      }

      final token = data['token'] as String;
      final user = data['user'] as Map<String, dynamic>;

      // Store token
      await GraphQLClientProvider.setToken(token);
      GraphQLClientSingleton.refresh();

      return AuthResult.fromSuccess(token, user);
    } catch (e) {
      return AuthResult.fromError('Connection error: ${e.toString()}');
    }
  }

  /// Register a new user
  Future<AuthResult> register({
    required String branchId,
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    final options = MutationOptions(
      document: gql(GQLMutations.createUser),
      variables: CreateUserVariables(
        branchId: branchId,
        email: email,
        password: password,
        name: name,
        role: role,
      ).toJson(),
    );

    try {
      final result = await _client.mutate(options);

      if (result.hasException) {
        return AuthResult.fromError(
          result.exception?.graphqlErrors.firstOrNull?.message ??
              'Registration failed',
        );
      }

      final data = result.data?['createUser'];
      if (data == null) {
        return AuthResult.fromError('Invalid response from server');
      }

      // Auto-login after registration
      return login(
        email: email,
        password: password,
        branchId: branchId,
      );
    } catch (e) {
      return AuthResult.fromError('Connection error: ${e.toString()}');
    }
  }

  /// Logout - clear token and refresh client
  Future<void> logout() async {
    await GraphQLClientProvider.deleteToken();
    GraphQLClientSingleton.refresh();
  }

  /// Get current user data
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final token = await GraphQLClientProvider.getToken();
    if (token == null) return null;

    final options = QueryOptions(
      document: gql(GQLQueries.me),
      fetchPolicy: FetchPolicy.networkOnly,
    );

    try {
      final result = await _client.query(options);

      if (result.hasException) {
        return null;
      }

      return result.data?['me'] as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return await GraphQLClientProvider.hasToken();
  }
}
