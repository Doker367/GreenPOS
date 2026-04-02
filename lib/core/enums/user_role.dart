/// Roles de usuario en el sistema
enum UserRole {
  customer('customer', 'Cliente'),
  admin('admin', 'Administrador'),
  waiter('waiter', 'Mesero'),
  cashier('cashier', 'Cajero'),
  chef('chef', 'Chef');

  final String value;
  final String displayName;

  const UserRole(this.value, this.displayName);

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.customer,
    );
  }
}
