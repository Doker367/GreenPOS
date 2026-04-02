import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/qrmenu_entities.dart';

/// Provider for SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main');
});

/// State class for the cart
class CartState {
  final List<CartItem> items;
  final String? customerName;
  final String? customerPhone;
  final String? notes;

  const CartState({
    this.items = const [],
    this.customerName,
    this.customerPhone,
    this.notes,
  });

  double get subtotal => items.fold(0, (sum, item) => sum + item.totalPrice);

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  bool get isEmpty => items.isEmpty;

  CartState copyWith({
    List<CartItem>? items,
    String? customerName,
    String? customerPhone,
    String? notes,
  }) {
    return CartState(
      items: items ?? this.items,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'items': items
            .map((e) => {
                  'product': e.product.toJson(),
                  'quantity': e.quantity,
                  'notes': e.notes,
                })
            .toList(),
        'customerName': customerName,
        'customerPhone': customerPhone,
        'notes': notes,
      };

  factory CartState.fromJson(Map<String, dynamic> json) {
    return CartState(
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => CartItem(
                    product: PublicProduct.fromJson(e['product']),
                    quantity: e['quantity'] as int,
                    notes: e['notes'] as String?,
                  ))
              .toList() ??
          [],
      customerName: json['customerName'] as String?,
      customerPhone: json['customerPhone'] as String?,
      notes: json['notes'] as String?,
    );
  }
}

/// Cart notifier that manages cart state with local storage persistence
class CartNotifier extends StateNotifier<CartState> {
  final SharedPreferences _prefs;
  static const String _cartKey = 'qrmenu_cart';

  CartNotifier(this._prefs) : super(const CartState()) {
    _loadFromStorage();
  }

  void _loadFromStorage() {
    final cartJson = _prefs.getString(_cartKey);
    if (cartJson != null) {
      try {
        final data = jsonDecode(cartJson) as Map<String, dynamic>;
        state = CartState.fromJson(data);
      } catch (e) {
        // If parsing fails, start with empty cart
        state = const CartState();
      }
    }
  }

  Future<void> _saveToStorage() async {
    await _prefs.setString(_cartKey, jsonEncode(state.toJson()));
  }

  void addItem(PublicProduct product, {int quantity = 1, String? notes}) {
    final existingIndex =
        state.items.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      // Update existing item
      final updatedItems = List<CartItem>.from(state.items);
      final existing = updatedItems[existingIndex];
      updatedItems[existingIndex] = existing.copyWith(
        quantity: existing.quantity + quantity,
        notes: notes ?? existing.notes,
      );
      state = state.copyWith(items: updatedItems);
    } else {
      // Add new item
      state = state.copyWith(
        items: [
          ...state.items,
          CartItem(product: product, quantity: quantity, notes: notes),
        ],
      );
    }
    _saveToStorage();
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }

    final updatedItems = state.items.map((item) {
      if (item.product.id == productId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    state = state.copyWith(items: updatedItems);
    _saveToStorage();
  }

  void removeItem(String productId) {
    state = state.copyWith(
      items: state.items.where((item) => item.product.id != productId).toList(),
    );
    _saveToStorage();
  }

  void updateNotes(String productId, String? notes) {
    final updatedItems = state.items.map((item) {
      if (item.product.id == productId) {
        return item.copyWith(notes: notes);
      }
      return item;
    }).toList();

    state = state.copyWith(items: updatedItems);
    _saveToStorage();
  }

  void setCustomerInfo({String? name, String? phone}) {
    state = state.copyWith(
      customerName: name ?? state.customerName,
      customerPhone: phone ?? state.customerPhone,
    );
    _saveToStorage();
  }

  void setOrderNotes(String? notes) {
    state = state.copyWith(notes: notes);
    _saveToStorage();
  }

  void clearCart() {
    state = const CartState();
    _saveToStorage();
  }

  CreateClientOrderInput toOrderInput(String qrCodeToken) {
    return CreateClientOrderInput(
      qrCodeToken: qrCodeToken,
      customerName: state.customerName ?? 'Cliente Mostrador',
      customerPhone: state.customerPhone,
      items: state.items
          .map((item) => ClientOrderItemInput(
                productId: item.product.id,
                quantity: item.quantity,
                notes: item.notes,
              ))
          .toList(),
      notes: state.notes,
    );
  }
}

/// Provider for the cart notifier
final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return CartNotifier(prefs);
});

/// Provider for menu data
final menuDataProvider =
    FutureProvider.family<List<CategoryWithProducts>, String>(
  (ref, branchId) async {
    // This would normally fetch from the repository
    // For now, returning empty list - actual implementation needed
    return [];
  },
);

/// Provider for selected category index
final selectedCategoryProvider = StateProvider<int>((ref) => 0);
