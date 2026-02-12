import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
// import '../../features/menu/data/repositories/menu_repository_impl.dart';
// import '../../features/menu/domain/repositories/menu_repository.dart';

// ====== PROVIDERS DE INFRAESTRUCTURA ======

/// Provider de SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences debe ser inicializado en main');
});

/// Provider de FirebaseAuth
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// Provider de Firestore
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// ====== PROVIDERS DE REPOSITORIOS ======

/// Provider del repositorio de autenticación
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
    prefs: ref.watch(sharedPreferencesProvider),
  );
});

// /// Provider del repositorio de menú
// final menuRepositoryProvider = Provider<MenuRepository>((ref) {
//   return MenuRepositoryImpl(
//     firestore: ref.watch(firestoreProvider),
//   );
// });
