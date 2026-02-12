import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/utils/failure.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

/// Implementación del repositorio de autenticación con Firebase
class AuthRepositoryImpl implements AuthRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final SharedPreferences _prefs;

  AuthRepositoryImpl({
    required firebase_auth.FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
    required SharedPreferences prefs,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore,
        _prefs = prefs;

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      // Autenticar con Firebase Auth
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        return const Left(AuthFailure('Error al iniciar sesión'));
      }

      // Obtener datos adicionales del usuario desde Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      if (!userDoc.exists) {
        return const Left(AuthFailure('Usuario no encontrado'));
      }

      final userModel = UserModel.fromJson({
        ...userDoc.data()!,
        'id': userDoc.id,
      });

      // Guardar token y datos en preferencias
      await _saveUserData(userModel);

      return Right(userModel.toEntity());
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(AuthFailure(_getAuthErrorMessage(e.code)));
    } catch (e) {
      return Left(AuthFailure('Error inesperado: $e'));
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
      // Crear usuario en Firebase Auth
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        return const Left(AuthFailure('Error al registrar usuario'));
      }

      // Crear documento del usuario en Firestore
      final userModel = UserModel(
        id: credential.user!.uid,
        email: email,
        name: name,
        phone: phone,
        role: UserRole.customer.value,
        createdAt: DateTime.now(),
        isActive: true,
      );

      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(userModel.toJson());

      // Actualizar nombre en Firebase Auth
      await credential.user!.updateDisplayName(name);

      // Guardar datos en preferencias
      await _saveUserData(userModel);

      return Right(userModel.toEntity());
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(AuthFailure(_getAuthErrorMessage(e.code)));
    } catch (e) {
      return Left(AuthFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _firebaseAuth.signOut();
      await _clearUserData();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure('Error al cerrar sesión: $e'));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      
      if (firebaseUser == null) {
        return const Right(null);
      }

      final userDoc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (!userDoc.exists) {
        return const Right(null);
      }

      final userModel = UserModel.fromJson({
        ...userDoc.data()!,
        'id': userDoc.id,
      });

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
    try {
      final updateData = <String, dynamic>{};
      
      if (name != null) updateData['name'] = name;
      if (phone != null) updateData['phone'] = phone;
      if (photoUrl != null) updateData['photo_url'] = photoUrl;
      updateData['updated_at'] = FieldValue.serverTimestamp();

      await _firestore.collection('users').doc(userId).update(updateData);

      // Actualizar también en Firebase Auth si es el nombre
      if (name != null) {
        await _firebaseAuth.currentUser?.updateDisplayName(name);
      }
      if (photoUrl != null) {
        await _firebaseAuth.currentUser?.updatePhotoURL(photoUrl);
      }

      // Obtener usuario actualizado
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userModel = UserModel.fromJson({
        ...userDoc.data()!,
        'id': userDoc.id,
      });

      return Right(userModel.toEntity());
    } catch (e) {
      return Left(ServerFailure('Error al actualizar perfil: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null || user.email == null) {
        return const Left(AuthFailure('Usuario no autenticado'));
      }

      // Re-autenticar usuario
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );
      
      await user.reauthenticateWithCredential(credential);

      // Cambiar contraseña
      await user.updatePassword(newPassword);

      return const Right(null);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(AuthFailure(_getAuthErrorMessage(e.code)));
    } catch (e) {
      return Left(AuthFailure('Error al cambiar contraseña: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String email,
  }) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return const Right(null);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(AuthFailure(_getAuthErrorMessage(e.code)));
    } catch (e) {
      return Left(AuthFailure('Error al enviar email: $e'));
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    return _firebaseAuth.currentUser != null;
  }

  // ====== MÉTODOS AUXILIARES ======

  Future<void> _saveUserData(UserModel user) async {
    await _prefs.setString(AppConstants.prefUserId, user.id);
    await _prefs.setString(AppConstants.prefUserRole, user.role);
  }

  Future<void> _clearUserData() async {
    await _prefs.remove(AppConstants.prefUserId);
    await _prefs.remove(AppConstants.prefUserRole);
    await _prefs.remove(AppConstants.prefToken);
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Usuario no encontrado';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'email-already-in-use':
        return 'El email ya está registrado';
      case 'invalid-email':
        return 'Email inválido';
      case 'weak-password':
        return 'La contraseña es muy débil';
      case 'user-disabled':
        return 'Usuario deshabilitado';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta más tarde';
      default:
        return 'Error de autenticación: $code';
    }
  }
}
