import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';

/// GraphQL client configuration and setup
class GraphQLClientProvider {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'graphql_auth_token';

  /// Get the HTTP link for GraphQL endpoint
  static HttpLink get _httpLink => HttpLink(
        AppConfig.graphqlApiUrl,
      );

  /// Auth link to add JWT token to headers
  static AuthLink get _authLink => AuthLink(
        getToken: () async {
          final token = await getToken();
          return token != null ? 'Bearer $token' : null;
        },
      );

  /// Combined link with auth headers
  static Link get _link => _authLink.concat(_httpLink);

  /// Create the GraphQL client instance
  static ValueNotifier<GraphQLClient> createClient() {
    final client = GraphQLClient(
      link: _link,
      cache: GraphQLCache(store: InMemoryStore()),
    );
    return ValueNotifier(client);
  }

  /// Store JWT token securely
  static Future<void> setToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Retrieve JWT token
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Delete JWT token (logout)
  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  /// Check if user has a valid token
  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}

/// Main GraphQL client accessor
class GraphQLClientSingleton {
  static GraphQLClient? _client;

  static GraphQLClient get client {
    _client ??= GraphQLClient(
      link: GraphQLClientProvider._link,
      cache: GraphQLCache(store: InMemoryStore()),
    );
    return _client!;
  }

  /// Refresh client (call after token changes)
  static void refresh() {
    _client = null;
  }
}
