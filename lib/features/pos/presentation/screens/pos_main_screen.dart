import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/categories_panel.dart';
import '../widgets/pos_products_grid.dart';
import '../widgets/active_order_panel.dart';
import '../providers/active_order_provider.dart';
import '../../../menu/presentation/providers/menu_provider.dart';

/// Pantalla principal del POS con layout de 3 columnas
class POSMainScreen extends ConsumerWidget {
  const POSMainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderState = ref.watch(activeOrderProvider);
    final isSmallScreen = MediaQuery.of(context).size.width < 400;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'POS',
          style: TextStyle(fontSize: isSmallScreen ? 16 : 20),
        ),
        actions: [
          // Badge de items en carrito (solo móvil)
          if (MediaQuery.of(context).size.width < 800) ...[
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  onPressed: () {
                    // Navegar a tab de pedido
                  },
                ),
                if (orderState.hasItems)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Center(
                        child: Text(
                          '${orderState.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 8),
          ],
          
          // Info de sesión (solo desktop)
          if (MediaQuery.of(context).size.width >= 800)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Row(
                  children: [
                    const Icon(Icons.person_outline, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Cajero: Admin',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(width: 24),
                    const Icon(Icons.access_time, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _getCurrentTime(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive: En pantallas pequeñas (móviles), usar tabs
          if (constraints.maxWidth < 800) {
            return const _MobileLayout();
          }

          // Layout mediano (tablets): 2 columnas sin categorías laterales
          if (constraints.maxWidth < 1200) {
            return const Row(
              children: [
                // Panel de Productos con categorías arriba (flexible)
                Expanded(
                  flex: 2,
                  child: POSProductsGrid(),
                ),

                // Divisor
                VerticalDivider(width: 1),

                // Panel de Pedido Activo (350px fijo)
                SizedBox(
                  width: 350,
                  child: ActiveOrderPanel(),
                ),
              ],
            );
          }

          // Layout desktop: 3 columnas completas
          return const Row(
            children: [
              // Panel de Categorías (180px fijo)
              SizedBox(
                width: 180,
                child: CategoriesPanel(),
              ),

              // Divisor
              VerticalDivider(width: 1),

              // Panel de Productos (flexible)
              Expanded(
                child: POSProductsGrid(),
              ),

              // Divisor
              VerticalDivider(width: 1),

              // Panel de Pedido Activo (350px fijo)
              SizedBox(
                width: 350,
                child: ActiveOrderPanel(),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
}

/// Layout responsive para móviles con tabs y categorías en chips
class _MobileLayout extends ConsumerStatefulWidget {
  const _MobileLayout();

  @override
  ConsumerState<_MobileLayout> createState() => _MobileLayoutState();
}

class _MobileLayoutState extends ConsumerState<_MobileLayout>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTab = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(activeOrderProvider);
    
    return Column(
      children: [
        // Tabs
        Container(
          color: Theme.of(context).colorScheme.surface,
          child: TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            indicatorColor: Theme.of(context).colorScheme.primary,
            tabs: [
              Tab(
                icon: const Icon(Icons.restaurant_menu),
                text: 'Productos',
              ),
              Tab(
                icon: Badge(
                  isLabelVisible: orderState.hasItems,
                  label: Text('${orderState.itemCount}'),
                  child: const Icon(Icons.shopping_cart),
                ),
                text: 'Pedido',
              ),
            ],
          ),
        ),
        
        // Categorías siempre visibles (solo en tab de Productos)
        if (_currentTab == 0) const _MobileCategoriesChips(),
        
        // Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: Solo productos (las categorías están arriba)
              const POSProductsGrid(),
              
              // Tab 2: Pedido activo
              const ActiveOrderPanel(),
            ],
          ),
        ),
      ],
    );
  }
}

/// Chips horizontales de categorías para móvil
class _MobileCategoriesChips extends ConsumerWidget {
  const _MobileCategoriesChips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedCategoryId = ref.watch(selectedCategoryProvider);
    final isSmallScreen = MediaQuery.of(context).size.width < 400;

    return categoriesAsync.when(
      data: (categories) {
        return Container(
          height: isSmallScreen ? 50 : 60,
          padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 6 : 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              // Chip "Todos"
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(
                    'Todos',
                    style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                  ),
                  selected: selectedCategoryId == null,
                  onSelected: (_) {
                    ref.read(selectedCategoryProvider.notifier).state = null;
                  },
                  avatar: Icon(Icons.grid_view, size: isSmallScreen ? 16 : 18),
                  visualDensity: isSmallScreen ? VisualDensity.compact : VisualDensity.standard,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              
              // Chips de categorías
              ...categories.map((category) {
                final isSelected = selectedCategoryId == category.id;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      category.name,
                      style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                    ),
                    selected: isSelected,
                    onSelected: (_) {
                      ref.read(selectedCategoryProvider.notifier).state = category.id;
                    },
                    visualDensity: isSmallScreen ? VisualDensity.compact : VisualDensity.standard,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
      loading: () => const SizedBox(height: 60),
      error: (_, __) => const SizedBox(height: 60),
    );
  }
}
