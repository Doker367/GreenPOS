/// QR Menu domain entities
/// These represent the core business objects for the public menu feature

/// Represents a product available in the public menu
class PublicProduct {
  final String id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final int preparationTime;
  final List<String> allergens;

  const PublicProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.preparationTime,
    required this.allergens,
  });

  factory PublicProduct.fromJson(Map<String, dynamic> json) {
    return PublicProduct(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String?,
      preparationTime: json['preparationTime'] as int? ?? 0,
      allergens: (json['allergens'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'imageUrl': imageUrl,
        'preparationTime': preparationTime,
        'allergens': allergens,
      };
}

/// Represents a category with its available products
class CategoryWithProducts {
  final String id;
  final String name;
  final String description;
  final int sortOrder;
  final List<PublicProduct> products;

  const CategoryWithProducts({
    required this.id,
    required this.name,
    required this.description,
    required this.sortOrder,
    required this.products,
  });

  factory CategoryWithProducts.fromJson(Map<String, dynamic> json) {
    return CategoryWithProducts(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      sortOrder: json['sortOrder'] as int? ?? 0,
      products: (json['products'] as List<dynamic>?)
              ?.map((e) => PublicProduct.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'sortOrder': sortOrder,
        'products': products.map((e) => e.toJson()).toList(),
      };
}

/// Represents a table's QR code information
class TableQRCode {
  final String id;
  final String tableId;
  final String qrToken;
  final String accessUrl;
  final bool isActive;
  final String createdAt;

  const TableQRCode({
    required this.id,
    required this.tableId,
    required this.qrToken,
    required this.accessUrl,
    required this.isActive,
    required this.createdAt,
  });

  factory TableQRCode.fromJson(Map<String, dynamic> json) {
    return TableQRCode(
      id: json['id'] as String,
      tableId: json['tableId'] as String,
      qrToken: json['qrToken'] as String,
      accessUrl: json['accessUrl'] as String,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] as String,
    );
  }
}

/// Represents a cart item in the QR menu
class CartItem {
  final PublicProduct product;
  int quantity;
  String? notes;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.notes,
  });

  double get totalPrice => product.price * quantity;

  CartItem copyWith({
    PublicProduct? product,
    int? quantity,
    String? notes,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
    );
  }
}

/// Represents a client order confirmation
class OrderConfirmation {
  final String orderId;
  final String orderToken;
  final String status;
  final String message;
  final int? estimatedReadyTime;

  const OrderConfirmation({
    required this.orderId,
    required this.orderToken,
    required this.status,
    required this.message,
    this.estimatedReadyTime,
  });

  factory OrderConfirmation.fromJson(Map<String, dynamic> json) {
    return OrderConfirmation(
      orderId: json['orderId'] as String,
      orderToken: json['orderToken'] as String,
      status: json['status'] as String,
      message: json['message'] as String,
      estimatedReadyTime: json['estimatedReadyTime'] as int?,
    );
  }
}

/// Input for creating a client order item
class ClientOrderItemInput {
  final String productId;
  final int quantity;
  final String? notes;

  const ClientOrderItemInput({
    required this.productId,
    required this.quantity,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'quantity': quantity,
        if (notes != null) 'notes': notes,
      };
}

/// Input for creating a client order
class CreateClientOrderInput {
  final String qrCodeToken;
  final String customerName;
  final String? customerPhone;
  final List<ClientOrderItemInput> items;
  final String? notes;

  const CreateClientOrderInput({
    required this.qrCodeToken,
    required this.customerName,
    this.customerPhone,
    required this.items,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'qrCodeToken': qrCodeToken,
        'customerName': customerName,
        if (customerPhone != null) 'customerPhone': customerPhone,
        'items': items.map((e) => e.toJson()).toList(),
        if (notes != null) 'notes': notes,
      };
}
