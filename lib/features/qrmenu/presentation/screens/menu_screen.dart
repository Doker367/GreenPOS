import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/qrmenu_entities.dart';
import '../../providers/qrmenu_provider.dart';
import '../widgets/category_tab.dart';
import '../widgets/product_card.dart';
import '../widgets/cart_button.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';

/// Main menu screen for the QR menu - displays categories and products
class MenuScreen extends ConsumerStatefulWidget {
  final String branchId;
  final String qrCodeToken;
  final List<CategoryWithProducts> categories;

  const MenuScreen({
    super.key,
    required this.branchId,
    required this.qrCodeToken,
    required this.categories,
  });

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.categories.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    // Update tab controller if categories change
    if (_tabController.length != widget.categories.length) {
      _tabController.dispose();
      _tabController = TabController(
        length: widget.categories.length,
        vsync: this,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menú Digital'),
        centerTitle: true,
        elevation: 0,
        bottom: widget.categories.length > 1
            ? TabBar(
                controller: _tabController,
                isScrollable: widget.categories.length > 4,
                tabs: widget.categories
                    .map((cat) => CategoryTab(
                          category: cat,
                          isSelected:
                              widget.categories.indexOf(cat) == selectedCategory,
                        ))
                    .toList(),
                onTap: (index) {
                  ref.read(selectedCategoryProvider.notifier).state = index;
                },
              )
            : null,
        actions: [
          // Cart button with badge
          CartButton(
            itemCount: cartState.totalItems,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CartScreen(
                    branchId: widget.branchId,
                    qrCodeToken: widget.qrCodeToken,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: widget.categories.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant_menu, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No hay productos disponibles',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: widget.categories.map((category) {
                return _buildProductGrid(category);
              }).toList(),
            ),
      // Floating cart summary
      bottomNavigationBar: cartState.isEmpty
          ? null
          : _buildCartSummary(context, cartState),
    );
  }

  Widget _buildProductGrid(CategoryWithProducts category) {
    if (category.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.no_food, size: 48, color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              'No hay productos en "${category.name}"',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: category.products.length,
      itemBuilder: (context, index) {
        final product = category.products[index];
        return ProductCard(
          product: product,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(
                  product: product,
                  branchId: widget.branchId,
                  qrCodeToken: widget.qrCodeToken,
                ),
              ),
            );
          },
          onAddToCart: () {
            ref.read(cartProvider.notifier).addItem(product);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${product.name} agregado al carrito'),
                duration: const Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(
                  label: 'DESHACER',
                  onPressed: () {
                    ref.read(cartProvider.notifier).removeItem(product.id);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCartSummary(BuildContext context, CartState cartState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CartScreen(
                  branchId: widget.branchId,
                  qrCodeToken: widget.qrCodeToken,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${cartState.totalItems} ${cartState.totalItems == 1 ? 'item' : 'items'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '\$${cartState.subtotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Row(
                children: [
                  Text(
                    'Ver carrito',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
