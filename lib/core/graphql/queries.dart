/// GraphQL Queries and Mutations for GreenPOS
class GQLQueries {
  /// Get current authenticated user
  static const String me = r'''
    query Me {
      me {
        id
        email
        name
        role
        isActive
        branch {
          id
          name
        }
      }
    }
  ''';

  /// Get available branches for tenant
  static const String branches = r'''
    query Branches {
      branches {
        id
        name
        address
        isActive
      }
    }
  ''';
}

class GQLMutations {
  /// Login mutation - returns AuthPayload with token and user
  static const String login = r'''
    mutation Login($email: String!, $password: String!, $branchId: UUID!) {
      login(email: $email, password: $password, branchId: $branchId) {
        token
        user {
          id
          email
          name
          role
          isActive
          branch {
            id
            name
          }
        }
      }
    }
  ''';

  /// Register/Create user mutation
  static const String createUser = r'''
    mutation CreateUser($input: CreateUserInput!) {
      createUser(input: $input) {
        id
        email
        name
        role
        isActive
        branch {
          id
          name
        }
      }
    }
  ''';
}

/// GraphQL variable classes
class LoginVariables {
  final String email;
  final String password;
  final String branchId;

  LoginVariables({
    required this.email,
    required this.password,
    required this.branchId,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'branchId': branchId,
      };
}

class CreateUserVariables {
  final String branchId;
  final String email;
  final String password;
  final String name;
  final String role;

  CreateUserVariables({
    required this.branchId,
    required this.email,
    required this.password,
    required this.name,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
        'input': {
          'branchId': branchId,
          'email': email,
          'password': password,
          'name': name,
          'role': role,
        },
      };
}

// ====== ORDERS QUERIES & MUTATIONS ======

class OrderGQLQueries {
  /// Get orders by branch with optional status filter
  static const String orders = r'''
    query Orders($branchId: UUID!, $status: OrderStatus, $limit: Int) {
      orders(branchId: $branchId, status: $status, limit: $limit) {
        id
        userId
        userName
        userPhone
        items {
          id
          productId
          productName
          productImage
          price
          quantity
          specialInstructions
          modifiers {
            id
            name
            priceAdjustment
            type
          }
        }
        subtotal
        tax
        deliveryFee
        discount
        total
        status
        tableNumber
        deliveryAddress
        notes
        paymentMethod
        isPaid
        createdAt
        updatedAt
        completedAt
      }
    }
  ''';

  /// Get a single order by ID
  static const String order = r'''
    query Order($id: UUID!) {
      order(id: $id) {
        id
        userId
        userName
        userPhone
        items {
          id
          productId
          productName
          productImage
          price
          quantity
          specialInstructions
          modifiers {
            id
            name
            priceAdjustment
            type
          }
        }
        subtotal
        tax
        deliveryFee
        discount
        total
        status
        tableNumber
        deliveryAddress
        notes
        paymentMethod
        isPaid
        createdAt
        updatedAt
        completedAt
      }
    }
  ''';

  /// Get active orders for a branch (for kitchen/display)
  static const String activeOrders = r'''
    query ActiveOrders($branchId: UUID!) {
      activeOrders(branchId: $branchId) {
        id
        userId
        userName
        userPhone
        items {
          id
          productId
          productName
          productImage
          price
          quantity
          specialInstructions
          modifiers {
            id
            name
            priceAdjustment
            type
          }
        }
        subtotal
        tax
        deliveryFee
        discount
        total
        status
        tableNumber
        deliveryAddress
        notes
        paymentMethod
        isPaid
        createdAt
        updatedAt
        completedAt
      }
    }
  ''';
}

class OrderGQLMutations {
  /// Create a new order
  static const String createOrder = r'''
    mutation CreateOrder($input: CreateOrderInput!) {
      createOrder(input: $input) {
        id
        userId
        userName
        userPhone
        items {
          id
          productId
          productName
          productImage
          price
          quantity
          specialInstructions
          modifiers {
            id
            name
            priceAdjustment
            type
          }
        }
        subtotal
        tax
        deliveryFee
        discount
        total
        status
        tableNumber
        deliveryAddress
        notes
        paymentMethod
        isPaid
        createdAt
        updatedAt
        completedAt
      }
    }
  ''';

  /// Update order status
  static const String updateOrderStatus = r'''
    mutation UpdateOrderStatus($id: UUID!, $status: OrderStatus!) {
      updateOrderStatus(id: $id, status: $status) {
        id
        status
        updatedAt
      }
    }
  ''';

  /// Add item to existing order
  static const String addOrderItem = r'''
    mutation AddOrderItem($orderId: UUID!, $input: CreateOrderItemInput!) {
      addOrderItem(orderId: $orderId, input: $input) {
        id
        items {
          id
          productId
          productName
          price
          quantity
          specialInstructions
          modifiers {
            id
            name
            priceAdjustment
            type
          }
        }
        subtotal
        total
        updatedAt
      }
    }
  ''';

  /// Remove item from order
  static const String removeOrderItem = r'''
    mutation RemoveOrderItem($id: UUID!) {
      removeOrderItem(id: $id)
    }
  ''';

  /// Cancel an order
  static const String cancelOrder = r'''
    mutation CancelOrder($id: UUID!) {
      cancelOrder(id: $id) {
        id
        status
        updatedAt
      }
    }
  ''';
}

// ====== TABLES QUERIES & MUTATIONS ======

class TableGQLQueries {
  /// Get all tables for a branch
  static const String tables = r'''
    query Tables($branchId: UUID!) {
      tables(branchId: $branchId) {
        id
        number
        capacity
        status
        currentOrderId
        qrCode
        createdAt
        updatedAt
      }
    }
  ''';

  /// Get a single table by ID
  static const String table = r'''
    query Table($id: UUID!) {
      table(id: $id) {
        id
        number
        capacity
        status
        currentOrderId
        qrCode
        createdAt
        updatedAt
      }
    }
  ''';

  /// Get reservations for a branch
  static const String reservations = r'''
    query Reservations($branchId: UUID!, $date: String) {
      reservations(branchId: $branchId, date: $date) {
        id
        userId
        userName
        userPhone
        tableId
        tableNumber
        reservationDate
        numberOfPeople
        notes
        isConfirmed
        isCancelled
        createdAt
        updatedAt
      }
    }
  ''';

  /// Get a single reservation by ID
  static const String reservation = r'''
    query Reservation($id: UUID!) {
      reservation(id: $id) {
        id
        userId
        userName
        userPhone
        tableId
        tableNumber
        reservationDate
        numberOfPeople
        notes
        isConfirmed
        isCancelled
        createdAt
        updatedAt
      }
    }
  ''';
}

class TableGQLMutations {
  /// Create a new table
  static const String createTable = r'''
    mutation CreateTable($input: CreateTableInput!) {
      createTable(input: $input) {
        id
        number
        capacity
        status
        currentOrderId
        qrCode
        createdAt
        updatedAt
      }
    }
  ''';

  /// Update table details
  static const String updateTable = r'''
    mutation UpdateTable($id: UUID!, $number: String, $capacity: Int) {
      updateTable(id: $id, number: $number, capacity: $capacity) {
        id
        number
        capacity
        status
        updatedAt
      }
    }
  ''';

  /// Update table status
  static const String updateTableStatus = r'''
    mutation UpdateTableStatus($id: UUID!, $status: TableStatus!) {
      updateTableStatus(id: $id, status: $status) {
        id
        status
        currentOrderId
        updatedAt
      }
    }
  ''';

  /// Delete a table
  static const String deleteTable = r'''
    mutation DeleteTable($id: UUID!) {
      deleteTable(id: $id)
    }
  ''';

  /// Create a reservation
  static const String createReservation = r'''
    mutation CreateReservation($input: CreateReservationInput!) {
      createReservation(input: $input) {
        id
        userId
        userName
        userPhone
        tableId
        tableNumber
        reservationDate
        numberOfPeople
        notes
        isConfirmed
        isCancelled
        createdAt
        updatedAt
      }
    }
  ''';

  /// Update a reservation
  static const String updateReservation = r'''
    mutation UpdateReservation($id: UUID!, $input: CreateReservationInput!) {
      updateReservation(id: $id, input: $input) {
        id
        userId
        userName
        userPhone
        tableId
        tableNumber
        reservationDate
        numberOfPeople
        notes
        isConfirmed
        isCancelled
        updatedAt
      }
    }
  ''';

  /// Cancel a reservation
  static const String cancelReservation = r'''
    mutation CancelReservation($id: UUID!) {
      cancelReservation(id: $id) {
        id
        isCancelled
        updatedAt
      }
    }
  ''';
}
