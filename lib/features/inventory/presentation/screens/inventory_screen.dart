import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/inventory_item.dart';
import '../providers/inventory_provider.dart';
import '../../../../core/providers/role_provider.dart';
import '../../../../core/utils/permissions.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final role = ref.watch(roleProvider);

    if (!canManageInventory(role) && !canManageAll(role)) {
      return Scaffold(
        appBar: AppBar(title: const Text('Inventario')),
        body: const Center(child: Text('No autorizado para ver esta sección')),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario'),
        actions: [
          if (canManageInventory(role) || canManageAll(role))
            IconButton(
              icon: const Icon(Icons.add_box),
              onPressed: () => _showAddItemDialog(),
              tooltip: 'Agregar',
            ),
        ],
      ),
      body: isMobile
          ? Column(
              children: [
                Expanded(child: _buildSelectedView()),
              ],
            )
          : Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) {
                    setState(() => _selectedIndex = index);
                  },
                  labelType: NavigationRailLabelType.all,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.inventory),
                      label: Text('Inventario'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.warning),
                      label: Text('Alertas'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.history),
                      label: Text('Movimientos'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: _buildSelectedView(),
                ),
              ],
            ),
      bottomNavigationBar: isMobile
          ? NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() => _selectedIndex = index);
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.inventory),
                  label: 'Inventario',
                ),
                NavigationDestination(
                  icon: Icon(Icons.warning),
                  label: 'Alertas',
                ),
                NavigationDestination(
                  icon: Icon(Icons.history),
                  label: 'Movimientos',
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildSelectedView() {
    switch (_selectedIndex) {
      case 0:
        return _buildInventoryView();
      case 1:
        return _buildAlertsView();
      case 2:
        return _buildMovementsView();
      default:
        return _buildInventoryView();
    }
  }

  Widget _buildInventoryView() {
    final items = ref.watch(inventoryProvider);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(isMobile ? 8 : 16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Buscar...',
              prefixIcon: const Icon(Icons.search),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? const Center(
                  child: Text('No hay productos en inventario'),
                )
              : ListView.builder(
                  itemCount: items.length,
                  padding: EdgeInsets.all(isMobile ? 8 : 16),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _InventoryItemCard(
                      item: item,
                      isMobile: isMobile,
                      onAdjustStock: () => _showAdjustStockDialog(item),
                      onAddStock: () => _showAddStockDialog(item),
                      onRecordWaste: () => _showRecordWasteDialog(item),
                      onEdit: () => _showEditItemDialog(item),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAlertsView() {
    final lowStockItems = ref.read(inventoryProvider.notifier).getLowStockItems();
    final outOfStockItems = ref.read(inventoryProvider.notifier).getOutOfStockItems();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (outOfStockItems.isNotEmpty) ...[
          const ListTile(
            leading: Icon(Icons.error, color: Colors.red, size: 32),
            title: Text(
              'Sin Stock',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...outOfStockItems.map((item) => Card(
                color: Colors.red.shade50,
                child: ListTile(
                  leading: const Icon(Icons.error, color: Colors.red),
                  title: Text(item.name),
                  subtitle: Text(
                    'Stock agotado - Min: ${item.minStock} ${item.unit.symbol}',
                  ),
                  trailing: FilledButton.icon(
                    onPressed: () => _showAddStockDialog(item),
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar Stock'),
                  ),
                ),
              )),
          const SizedBox(height: 16),
        ],
        if (lowStockItems.isNotEmpty) ...[
          const ListTile(
            leading: Icon(Icons.warning, color: Colors.orange, size: 32),
            title: Text(
              'Stock Bajo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...lowStockItems.map((item) => Card(
                color: Colors.orange.shade50,
                child: ListTile(
                  leading: const Icon(Icons.warning, color: Colors.orange),
                  title: Text(item.name),
                  subtitle: Text(
                    'Stock: ${item.currentStock} ${item.unit.symbol} - Min: ${item.minStock} ${item.unit.symbol}',
                  ),
                  trailing: FilledButton.icon(
                    onPressed: () => _showAddStockDialog(item),
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar Stock'),
                  ),
                ),
              )),
        ],
        if (lowStockItems.isEmpty && outOfStockItems.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.check_circle, size: 64, color: Colors.green),
                  SizedBox(height: 16),
                  Text(
                    'Todo el inventario está en niveles óptimos',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMovementsView() {
    final movements = ref.watch(stockMovementsProvider);
    final items = ref.watch(inventoryProvider);
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.history, size: 32),
              const SizedBox(width: 16),
              Text(
                'Movimientos de Stock',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
        ),
        Expanded(
          child: movements.isEmpty
              ? const Center(
                  child: Text('No hay movimientos registrados'),
                )
              : ListView.builder(
                  itemCount: movements.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final movement = movements[index];
                    final item = items.firstWhere(
                      (i) => i.id == movement.itemId,
                      orElse: () => InventoryItem(
                        id: '',
                        name: 'Desconocido',
                        description: 'Producto no encontrado',
                        category: InventoryCategory.other,
                        currentStock: 0,
                        minStock: 0,
                        maxStock: 0,
                        unit: Unit.pz,
                        costPerUnit: 0,
                        createdAt: DateTime.now(),
                      ),
                    );

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getMovementColor(movement.type),
                          child: Icon(
                            _getMovementIcon(movement.type),
                            color: Colors.white,
                          ),
                        ),
                        title: Text(item.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              '${movement.type.displayName} - ${movement.quantity} ${item.unit.symbol}',
                            ),
                            Text(
                              DateFormat('dd/MM/yyyy HH:mm').format(movement.date),
                            ),
                            if (movement.cost != null)
                              Text(
                                'Costo: ${currencyFormat.format(movement.cost)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            if (movement.notes != null)
                              Text(
                                movement.notes!,
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Color _getMovementColor(MovementType type) {
    switch (type) {
      case MovementType.purchase:
        return Colors.green;
      case MovementType.sale:
        return Colors.blue;
      case MovementType.waste:
        return Colors.red;
      case MovementType.adjustment:
        return Colors.orange;
    }
  }

  IconData _getMovementIcon(MovementType type) {
    switch (type) {
      case MovementType.purchase:
        return Icons.add_shopping_cart;
      case MovementType.sale:
        return Icons.point_of_sale;
      case MovementType.waste:
        return Icons.delete;
      case MovementType.adjustment:
        return Icons.tune;
    }
  }

  void _showAddItemDialog() {
    final nameController = TextEditingController();
    final minStockController = TextEditingController();
    final maxStockController = TextEditingController();
    final costController = TextEditingController();
    InventoryCategory selectedCategory = InventoryCategory.other;
    Unit selectedUnit = Unit.pz;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Agregar Producto'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del Producto',
                    prefixIcon: Icon(Icons.inventory),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<InventoryCategory>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Categoría',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: InventoryCategory.values.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedCategory = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Unit>(
                  value: selectedUnit,
                  decoration: const InputDecoration(
                    labelText: 'Unidad',
                    prefixIcon: Icon(Icons.scale),
                  ),
                  items: Unit.values.map((unit) {
                    return DropdownMenuItem(
                      value: unit,
                      child: Text('${unit.displayName} (${unit.symbol})'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedUnit = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: minStockController,
                  decoration: const InputDecoration(
                    labelText: 'Stock Mínimo',
                    prefixIcon: Icon(Icons.trending_down),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: maxStockController,
                  decoration: const InputDecoration(
                    labelText: 'Stock Máximo',
                    prefixIcon: Icon(Icons.trending_up),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: costController,
                  decoration: const InputDecoration(
                    labelText: 'Costo por Unidad (\$)',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    minStockController.text.isNotEmpty &&
                    maxStockController.text.isNotEmpty &&
                    costController.text.isNotEmpty) {
                  ref.read(inventoryProvider.notifier).addItem(
                        name: nameController.text,
                        category: selectedCategory,
                        unit: selectedUnit,
                        minStock: double.parse(minStockController.text),
                        maxStock: double.parse(maxStockController.text),
                        costPerUnit: double.parse(costController.text),
                      );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Producto agregado exitosamente'),
                    ),
                  );
                }
              },
              child: const Text('Agregar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditItemDialog(InventoryItem item) {
    final nameController = TextEditingController(text: item.name);
    final minStockController =
        TextEditingController(text: item.minStock.toString());
    final maxStockController =
        TextEditingController(text: item.maxStock.toString());
    final costController =
        TextEditingController(text: item.costPerUnit.toString());
    InventoryCategory selectedCategory = item.category;
    Unit selectedUnit = item.unit;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Editar Producto'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del Producto',
                    prefixIcon: Icon(Icons.inventory),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<InventoryCategory>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Categoría',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: InventoryCategory.values.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedCategory = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Unit>(
                  value: selectedUnit,
                  decoration: const InputDecoration(
                    labelText: 'Unidad',
                    prefixIcon: Icon(Icons.scale),
                  ),
                  items: Unit.values.map((unit) {
                    return DropdownMenuItem(
                      value: unit,
                      child: Text('${unit.displayName} (${unit.symbol})'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedUnit = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: minStockController,
                  decoration: const InputDecoration(
                    labelText: 'Stock Mínimo',
                    prefixIcon: Icon(Icons.trending_down),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: maxStockController,
                  decoration: const InputDecoration(
                    labelText: 'Stock Máximo',
                    prefixIcon: Icon(Icons.trending_up),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: costController,
                  decoration: const InputDecoration(
                    labelText: 'Costo por Unidad (\$)',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    minStockController.text.isNotEmpty &&
                    maxStockController.text.isNotEmpty &&
                    costController.text.isNotEmpty) {
                  // TODO: Implementar updateItem en el provider
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Producto actualizado'),
                    ),
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAdjustStockDialog(InventoryItem item) {
    final quantityController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ajustar Stock - ${item.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Stock actual: ${item.currentStock} ${item.unit.symbol}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              decoration: InputDecoration(
                labelText: 'Nueva cantidad (${item.unit.symbol})',
                prefixIcon: const Icon(Icons.tune),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Notas (opcional)',
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (quantityController.text.isNotEmpty) {
                ref.read(inventoryProvider.notifier).adjustStock(
                      itemId: item.id,
                      newQuantity: double.parse(quantityController.text),
                      notes: notesController.text.isEmpty
                          ? null
                          : notesController.text,
                    );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Stock ajustado'),
                  ),
                );
              }
            },
            child: const Text('Ajustar'),
          ),
        ],
      ),
    );
  }

  void _showAddStockDialog(InventoryItem item) {
    final quantityController = TextEditingController();
    final costController = TextEditingController(
      text: item.costPerUnit.toString(),
    );
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Agregar Stock - ${item.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Stock actual: ${item.currentStock} ${item.unit.symbol}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              decoration: InputDecoration(
                labelText: 'Cantidad a agregar (${item.unit.symbol})',
                prefixIcon: const Icon(Icons.add),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: costController,
              decoration: const InputDecoration(
                labelText: 'Costo por unidad (\$)',
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Notas (opcional)',
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (quantityController.text.isNotEmpty &&
                  costController.text.isNotEmpty) {
                final quantity = double.parse(quantityController.text);
                final cost = double.parse(costController.text);
                
                ref.read(stockMovementsProvider.notifier).recordPurchase(
                      itemId: item.id,
                      quantity: quantity,
                      cost: cost,
                      notes: notesController.text.isEmpty
                          ? null
                          : notesController.text,
                    );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Stock agregado'),
                  ),
                );
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _showRecordWasteDialog(InventoryItem item) {
    final quantityController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Registrar Merma - ${item.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Stock actual: ${item.currentStock} ${item.unit.symbol}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              decoration: InputDecoration(
                labelText: 'Cantidad perdida (${item.unit.symbol})',
                prefixIcon: const Icon(Icons.delete),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Motivo',
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (quantityController.text.isNotEmpty &&
                  notesController.text.isNotEmpty) {
                ref.read(stockMovementsProvider.notifier).recordWaste(
                      itemId: item.id,
                      quantity: double.parse(quantityController.text),
                      notes: notesController.text,
                    );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Merma registrada'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Registrar'),
          ),
        ],
      ),
    );
  }
}

class _InventoryItemCard extends StatelessWidget {
  final InventoryItem item;
  final bool isMobile;
  final VoidCallback onAdjustStock;
  final VoidCallback onAddStock;
  final VoidCallback onRecordWaste;
  final VoidCallback onEdit;

  const _InventoryItemCard({
    required this.item,
    required this.isMobile,
    required this.onAdjustStock,
    required this.onAddStock,
    required this.onRecordWaste,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final stockPercentage = (item.currentStock / item.maxStock).clamp(0.0, 1.0);

    Color stockColor = Colors.green;
    if (item.isOutOfStock) {
      stockColor = Colors.red;
    } else if (item.isLowStock) {
      stockColor = Colors.orange;
    }

    return Card(
      margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: stockColor,
          child: Text(
            item.currentStock.toStringAsFixed(0),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: isMobile ? 12 : 14,
            ),
          ),
        ),
        title: Text(
          item.name,
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${item.category.displayName} - ${currencyFormat.format(item.costPerUnit)}/${item.unit.symbol}',
              style: TextStyle(fontSize: isMobile ? 11 : 13),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: stockPercentage,
                    backgroundColor: Colors.grey.shade200,
                    color: stockColor,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${item.currentStock}/${item.maxStock} ${item.unit.symbol}',
                  style: TextStyle(
                    color: stockColor,
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 11 : 13,
                  ),
                ),
              ],
            ),
            if (item.isLowStock)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '⚠️ Stock bajo',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: isMobile ? 11 : 12,
                  ),
                ),
              ),
            if (item.isOutOfStock)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '❌ Sin stock',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: isMobile ? 11 : 12,
                  ),
                ),
              ),
          ],
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(isMobile ? 8 : 16),
            child: isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FilledButton.icon(
                        onPressed: onAddStock,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Agregar'),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: onRecordWaste,
                        icon: const Icon(Icons.delete, size: 18),
                        label: const Text('Merma'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton.icon(
                            onPressed: onAdjustStock,
                            icon: const Icon(Icons.tune, size: 18),
                            label: const Text('Ajustar'),
                          ),
                          TextButton.icon(
                            onPressed: onEdit,
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text('Editar'),
                          ),
                        ],
                      ),
                    ],
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.icon(
                        onPressed: onAddStock,
                        icon: const Icon(Icons.add),
                        label: const Text('Agregar Stock'),
                      ),
                      OutlinedButton.icon(
                        onPressed: onAdjustStock,
                        icon: const Icon(Icons.tune),
                        label: const Text('Ajustar'),
                      ),
                      OutlinedButton.icon(
                        onPressed: onRecordWaste,
                        icon: const Icon(Icons.delete),
                        label: const Text('Registrar Merma'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: onEdit,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
