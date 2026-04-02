/// GraphQL queries and mutations for the QR Menu feature

class QRMenuQueries {
  /// Get public menu for a branch (no authentication required)
  static const String publicMenu = r'''
    query PublicMenu($branchId: UUID!) {
      publicMenu(branchId: $branchId) {
        id
        name
        description
        sortOrder
        products {
          id
          name
          description
          price
          imageUrl
          preparationTime
          allergens
        }
      }
    }
  ''';

  /// Get table info from QR token
  static const String tableByQRToken = r'''
    query TableByQRToken($token: String!) {
      tableByQRToken(token: $token) {
        id
        number
        capacity
        status
        qrCode
      }
    }
  ''';

  /// Get QR code info by token
  static const String getQRByToken = r'''
    query GetQRByToken($token: String!) {
      getQRByToken(token: $token) {
        id
        tableId
        qrToken
        accessUrl
        isActive
        createdAt
      }
    }
  ''';
}

class QRMenuMutations {
  /// Generate QR code for a table
  static const String generateTableQR = r'''
    mutation GenerateTableQR($tableId: UUID!) {
      generateTableQR(tableId: $tableId) {
        id
        tableId
        qrToken
        accessUrl
        isActive
        createdAt
      }
    }
  ''';

  /// Create a client order from QR menu
  static const String createClientOrder = r'''
    mutation CreateClientOrder($input: CreateClientOrderInput!) {
      createClientOrder(input: $input) {
        orderId
        orderToken
        status
        message
        estimatedReadyTime
      }
    }
  ''';
}
