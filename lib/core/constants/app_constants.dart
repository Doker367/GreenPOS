/// Constantes globales de la aplicación
class AppConstants {
  // API
  static const String baseUrl = 'https://your-api-url.com/api/v1';
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Roles de usuario
  static const String roleCustomer = 'customer';
  static const String roleAdmin = 'admin';
  static const String roleWaiter = 'waiter';
  static const String roleChef = 'chef';

  // Estados de pedido
  static const String orderStatusPending = 'pending';
  static const String orderStatusAccepted = 'accepted';
  static const String orderStatusPreparing = 'preparing';
  static const String orderStatusReady = 'ready';
  static const String orderStatusDelivered = 'delivered';
  static const String orderStatusCancelled = 'cancelled';

  // Estados de mesa
  static const String tableStatusAvailable = 'available';
  static const String tableStatusOccupied = 'occupied';
  static const String tableStatusReserved = 'reserved';

  // Métodos de pago
  static const String paymentCash = 'cash';
  static const String paymentCard = 'card';
  static const String paymentOnline = 'online';

  // Preferencias compartidas
  static const String prefToken = 'auth_token';
  static const String prefUserId = 'user_id';
  static const String prefUserRole = 'user_role';
  static const String prefBranchId = 'branch_id';
  static const String prefThemeMode = 'theme_mode';

  // Paginación
  static const int defaultPageSize = 20;

  // Validaciones
  static const int minPasswordLength = 6;
  static const int maxProductNameLength = 100;
  static const int maxDescriptionLength = 500;
}
