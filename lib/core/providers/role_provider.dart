import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../enums/user_role.dart';

/// Proveedor global del rol actual (modo local, sin backend)
final roleProvider = StateProvider<UserRole>((ref) => UserRole.admin);
