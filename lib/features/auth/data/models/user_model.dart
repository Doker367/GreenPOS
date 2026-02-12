import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user.dart';
import '../../../../core/enums/user_role.dart';

part 'user_model.g.dart';

/// Modelo de datos de Usuario (Data Layer)
@JsonSerializable()
class UserModel {
  final String id;
  final String email;
  final String name;
  final String? phone;
  @JsonKey(name: 'photo_url')
  final String? photoUrl;
  final String role;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  @JsonKey(name: 'is_active')
  final bool isActive;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.photoUrl,
    required this.role,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  /// Convertir de JSON
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// Convertir a JSON
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  /// Convertir de entidad de dominio
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      phone: user.phone,
      photoUrl: user.photoUrl,
      role: user.role.value,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      isActive: user.isActive,
    );
  }

  /// Convertir a entidad de dominio
  User toEntity() {
    return User(
      id: id,
      email: email,
      name: name,
      phone: phone,
      photoUrl: photoUrl,
      role: UserRole.fromString(role),
      createdAt: createdAt,
      updatedAt: updatedAt,
      isActive: isActive,
    );
  }
}
