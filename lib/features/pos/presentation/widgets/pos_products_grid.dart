import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/mock_data_providers.dart';
import '../../../menu/presentation/providers/menu_provider.dart';
import '../../domain/entities/order_modifier.dart';
import '../providers/active_order_provider.dart';
import '../providers/search_provider.dart';
import 'categories_panel.dart';

/// Grid de productos para el POS
class POSProductsGrid extends ConsumerWidget {
  const POSProductsGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategoryId = ref.watch(selectedCategoryProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final isSmallScreen = MediaQuery.of(context).size.width < 400;
    
    // Usar filteredProductsProvider en lugar de productsProvider
    final productsAsync = ref.watch(productsProvider(selectedCategoryId));

    return Container(
      color: Theme.of(context).colorScheme.background,
      child: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: EdgeInsets.all(isSmallScreen ? 8 : 16),
            child: TextField(
              style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
              decoration: InputDecoration(
                hintText: 'Buscar producto...',
                hintStyle: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                prefixIcon: Icon(Icons.search, size: isSmallScreen ? 20 : 24),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 12 : 16,
                  vertical: isSmallScreen ? 8 : 12,
                ),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          ref.read(searchQueryProvider.notifier).state = '';
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
              },
            ),
          ),

          // Grid de productos
          Expanded(
            child: productsAsync.when(
              data: (allProducts) {
                // Filtrar productos según búsqueda
                final products = searchQuery.isEmpty
                    ? allProducts
                    : allProducts.where((product) {
                        final name = product.name.toLowerCase();
                        final description = (product.description ?? '').toLowerCase();
                        final query = searchQuery.toLowerCase();
                        return name.contains(query) || description.contains(query);
                      }).toList();
                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: Theme.of(context)
                              .colorScheme
                              .onBackground
                              .withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay productos disponibles',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground
                                        .withOpacity(0.5),
                                  ),
                        ),
                      ],
                    ),
                  );
                }

                final screenWidth = MediaQuery.of(context).size.width;
                final isSmallScreen = screenWidth < 400;
                final isMediumScreen = screenWidth < 600;
                
                return GridView.builder(
                  padding: EdgeInsets.all(isSmallScreen ? 8 : (isMediumScreen ? 12 : 16)),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    // Responsive: ajustar tamaño según ancho de pantalla
                    maxCrossAxisExtent: isSmallScreen ? 140 : (isMediumScreen ? 160 : 180),
                    childAspectRatio: isSmallScreen ? 0.65 : (isMediumScreen ? 0.7 : 0.75),
                    crossAxisSpacing: isSmallScreen ? 6 : (isMediumScreen ? 8 : 12),
                    mainAxisSpacing: isSmallScreen ? 6 : (isMediumScreen ? 8 : 12),
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _ProductCard(product: product);
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error al cargar productos',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta de producto individual optimizada para táctil
class _ProductCard extends ConsumerWidget {
  final product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final modifierGroups = ref.watch(mockModifierGroupsProvider(product.id));
    final isSmallScreen = MediaQuery.of(context).size.width < 400;

    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      child: InkWell(
        onTap: () async {
          // Si el producto tiene modificadores, mostrar diálogo
          if (modifierGroups.isNotEmpty) {
            await _showModifiersDialog(context, ref, product, modifierGroups);
          } else {
            // Si no tiene modificadores, agregar directamente
            ref.read(activeOrderProvider.notifier).addProduct(product);

            // Feedback visual
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${product.name} agregado'),
                  duration: const Duration(milliseconds: 800),
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
                ),
              );
            }
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagen o placeholder
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.grey200,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: product.imageUrls.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.network(
                          product.imageUrls.first,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _ProductPlaceholder(
                              name: product.name,
                            );
                          },
                        ),
                      )
                    : _ProductPlaceholder(name: product.name),
              ),
            ),

            // Info del producto
            Padding(
              padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Nombre
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: isSmallScreen ? 12 : 14,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Precio y botón
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          currencyFormat.format(product.price),
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                fontSize: isSmallScreen ? 13 : 16,
                              ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(isSmallScreen ? 4 : 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: isSmallScreen ? 16 : 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder cuando no hay imagen
class _ProductPlaceholder extends StatelessWidget {
  final String name;

  const _ProductPlaceholder({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.3),
            AppColors.primary.withOpacity(0.1),
          ],
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(12),
        ),
      ),
      child: Center(
        child: Icon(
          Icons.fastfood,
          size: 48,
          color: AppColors.primary.withOpacity(0.5),
        ),
      ),
    );
  }
}

/// Diálogo para seleccionar modificadores de producto
Future<void> _showModifiersDialog(
  BuildContext context,
  WidgetRef ref,
  dynamic product,
  List modifierGroups,
) async {
  final result = await showDialog<Map<String, dynamic>>(
    context: context,
    builder: (context) => _ModifiersDialog(
      product: product,
      modifierGroups: modifierGroups,
    ),
  );

  if (result != null && context.mounted) {
    // Agregar producto con modificadores seleccionados
    ref.read(activeOrderProvider.notifier).addProductWithModifiers(
          product,
          result['modifiers'],
          quantity: result['quantity'],
          notes: result['notes'],
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} agregado con personalizaciones'),
        duration: const Duration(milliseconds: 800),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
      ),
    );
  }
}

/// Diálogo de modificadores
class _ModifiersDialog extends StatefulWidget {
  final dynamic product;
  final List modifierGroups;

  const _ModifiersDialog({
    required this.product,
    required this.modifierGroups,
  });

  @override
  State<_ModifiersDialog> createState() => _ModifiersDialogState();
}

class _ModifiersDialogState extends State<_ModifiersDialog> {
  final Map<String, List<String>> _selectedOptions = {};
  final TextEditingController _notesController = TextEditingController();
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    // Inicializar con opciones por defecto
    for (final group in widget.modifierGroups) {
      final defaultOptions = group.options
          .where((opt) => opt.isDefault)
          .map((opt) => opt.id)
          .toList();
      if (defaultOptions.isNotEmpty) {
        _selectedOptions[group.id] = defaultOptions;
      } else {
        _selectedOptions[group.id] = [];
      }
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  double get _totalPrice {
    double total = widget.product.price;
    
    for (final group in widget.modifierGroups) {
      final selectedIds = _selectedOptions[group.id] ?? [];
      for (final optionId in selectedIds) {
        final option = group.options.firstWhere((opt) => opt.id == optionId);
        total += option.priceAdjustment;
      }
    }
    
    return total * _quantity;
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: isMobile 
          ? const EdgeInsets.symmetric(horizontal: 16, vertical: 24)
          : const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : 600,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(isMobile ? 16 : 20),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.product.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  Text(
                    'Personaliza tu pedido',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                  ),
                ],
              ),
            ),

            // Body - Scrollable
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Grupos de modificadores
                    ...widget.modifierGroups.map((group) => _buildModifierGroup(group)),
                    
                    const SizedBox(height: 20),
                    
                    // Notas especiales
                    TextField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Notas especiales (opcional)',
                        hintText: 'Ej: Sin cebolla, término medio, etc.',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Cantidad
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).dividerColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: _quantity > 1
                              ? () => setState(() => _quantity--)
                              : null,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            '$_quantity',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => setState(() => _quantity++),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Botón agregar
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _canAddToOrder ? _addToOrder : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Agregar ${currencyFormat.format(_totalPrice)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModifierGroup(dynamic group) {
    final selectedIds = _selectedOptions[group.id] ?? [];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  group.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              if (group.isRequired)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.posCancel.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'REQUERIDO',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.posCancel,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ...group.options.map((option) {
            final isSelected = selectedIds.contains(option.id);
            final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
            
            return CheckboxListTile(
              value: isSelected,
              onChanged: (value) {
                setState(() {
                  if (group.allowMultiple) {
                    // Multi-selección
                    if (value == true) {
                      _selectedOptions[group.id] = [...selectedIds, option.id];
                    } else {
                      _selectedOptions[group.id] = selectedIds.where((id) => id != option.id).toList();
                    }
                  } else {
                    // Selección única
                    _selectedOptions[group.id] = value == true ? [option.id] : [];
                  }
                });
              },
              title: Text(option.name),
              subtitle: option.priceAdjustment != 0
                  ? Text(
                      '${option.priceAdjustment > 0 ? '+' : ''}${currencyFormat.format(option.priceAdjustment)}',
                      style: TextStyle(
                        color: option.priceAdjustment > 0
                            ? AppColors.posKitchen
                            : Colors.green,
                      ),
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              tileColor: isSelected
                  ? AppColors.primary.withOpacity(0.05)
                  : null,
            );
          }).toList(),
        ],
      ),
    );
  }

  bool get _canAddToOrder {
    // Verificar que todos los grupos requeridos tengan selección
    for (final group in widget.modifierGroups) {
      if (group.isRequired) {
        final selected = _selectedOptions[group.id] ?? [];
        if (selected.isEmpty) return false;
      }
    }
    return true;
  }

  void _addToOrder() {
    // Construir lista de modificadores seleccionados
    final modifiers = <OrderModifier>[];
    const uuid = Uuid();
    
    for (final group in widget.modifierGroups) {
      final selectedIds = _selectedOptions[group.id] ?? [];
      for (final optionId in selectedIds) {
        final option = group.options.firstWhere((opt) => opt.id == optionId);
        modifiers.add(
          OrderModifier(
            id: uuid.v4(),
            name: '${group.name}: ${option.name}',
            priceAdjustment: option.priceAdjustment,
            type: option.priceAdjustment >= 0 ? ModifierType.add : ModifierType.remove,
          ),
        );
      }
    }

    Navigator.of(context).pop({
      'modifiers': modifiers,
      'quantity': _quantity,
      'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    });
  }
}
