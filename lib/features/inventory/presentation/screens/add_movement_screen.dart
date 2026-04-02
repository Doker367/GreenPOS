import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/inventory_item.dart';
import '../providers/inventory_provider.dart';

/// Tipo de movimiento seleccionado
enum MovementAction { add, remove, adjust }

/// Screen para agregar/quitar stock con razón
class AddMovementScreen extends ConsumerStatefulWidget {
  final String? itemId; // If provided, pre-select this item

  const AddMovementScreen({
    super.key,
    this.itemId,
  });

  @override
  ConsumerState<AddMovementScreen> createState() => _AddMovementScreenState();
}

class _AddMovementScreenState extends ConsumerState<AddMovementScreen> {
  late TextEditingController _quantityController;
  late TextEditingController _reasonController;
  late TextEditingController _costController;
  
  String? _selectedItemId;
  MovementAction _action = MovementAction.add;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController();
    _reasonController = TextEditingController();
    _costController = TextEditingController();
    _selectedItemId = widget.itemId;
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _reasonController.dispose();
    _costController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(inventoryProvider);
    final isMobile = MediaQuery.of(context).size.width < 600;

    final selectedItem = _selectedItemId != null
        ? items.firstWhere(
            (i) => i.id == _selectedItemId,
            orElse: () => items.first,
          )
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Movimiento de Stock'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 8 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Producto',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedItemId,
                      decoration: const InputDecoration(
                        labelText: 'Seleccionar producto',
                        prefixIcon: Icon(Icons.inventory),
                        border: OutlineInputBorder(),
                      ),
                      items: items.map((item) {
                        return DropdownMenuItem(
                          value: item.id,
                          child: Row(
                            children: [
                              if (item.isLowStock)
                                const Padding(
                                  padding: EdgeInsets.only(right: 8),
                                  child: Icon(Icons.warning, color: Colors.orange, size: 16),
                                ),
                              if (item.isOutOfStock)
                                const Padding(
                                  padding: EdgeInsets.only(right: 8),
                                  child: Icon(Icons.error, color: Colors.red, size: 16),
                                ),
                              Expanded(child: Text(item.name)),
                              Text(
                                '${item.currentStock} ${item.unit.symbol}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedItemId = value;
                          if (value != null) {
                            final item = items.firstWhere((i) => i.id == value);
                            _costController.text = item.costPerUnit.toString();
                          }
                        });
                      },
                    ),
                    if (selectedItem != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Stock actual:'),
                            Text(
                              '${selectedItem.currentStock} ${selectedItem.unit.symbol}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Action type selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tipo de Movimiento',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<MovementAction>(
                      segments: const [
                        ButtonSegment(
                          value: MovementAction.add,
                          label: Text('Agregar'),
                          icon: Icon(Icons.add),
                        ),
                        ButtonSegment(
                          value: MovementAction.remove,
                          label: Text('Quitar'),
                          icon: Icon(Icons.remove),
                        ),
                        ButtonSegment(
                          value: MovementAction.adjust,
                          label: Text('Ajustar'),
                          icon: Icon(Icons.tune),
                        ),
                      ],
                      selected: {_action},
                      onSelectionChanged: (selection) {
                        setState(() {
                          _action = selection.first;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Quantity and reason
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cantidad',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    if (_action == MovementAction.adjust) ...[
                      TextField(
                        controller: _quantityController,
                        decoration: InputDecoration(
                          labelText: 'Nueva cantidad total',
                          prefixIcon: const Icon(Icons.numbers),
                          suffixText: selectedItem?.unit.symbol ?? '',
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ] else ...[
                      TextField(
                        controller: _quantityController,
                        decoration: InputDecoration(
                          labelText: _action == MovementAction.add
                              ? 'Cantidad a agregar'
                              : 'Cantidad a quitar',
                          prefixIcon: Icon(
                            _action == MovementAction.add ? Icons.add : Icons.remove,
                          ),
                          suffixText: selectedItem?.unit.symbol ?? '',
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                    if (_action == MovementAction.add) ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: _costController,
                        decoration: const InputDecoration(
                          labelText: 'Costo por unidad (\$)',
                          prefixIcon: Icon(Icons.attach_money),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                    const SizedBox(height: 16),
                    TextField(
                      controller: _reasonController,
                      decoration: const InputDecoration(
                        labelText: 'Razón / Motivo',
                        prefixIcon: Icon(Icons.note),
                        border: OutlineInputBorder(),
                        hintText: 'Ej: Compra semanal, Merma, Ajuste de inventario...',
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _selectedItemId != null && _quantityController.text.isNotEmpty
                    ? _submitMovement
                    : null,
                icon: Icon(_action == MovementAction.add
                    ? Icons.add
                    : _action == MovementAction.remove
                        ? Icons.remove
                        : Icons.tune),
                label: Text(
                  _action == MovementAction.add
                      ? 'Agregar Stock'
                      : _action == MovementAction.remove
                          ? 'Quitar Stock'
                          : 'Ajustar Stock',
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: _action == MovementAction.add
                      ? Colors.green
                      : _action == MovementAction.remove
                          ? Colors.red
                          : Colors.orange,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitMovement() {
    final quantity = double.tryParse(_quantityController.text);
    final cost = double.tryParse(_costController.text);
    final reason = _reasonController.text;

    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese una cantidad válida')),
      );
      return;
    }

    final items = ref.read(inventoryProvider);
    final item = items.firstWhere((i) => i.id == _selectedItemId);

    switch (_action) {
      case MovementAction.add:
        // Add stock
        ref.read(stockMovementsProvider.notifier).recordPurchase(
              itemId: _selectedItemId!,
              quantity: quantity,
              cost: cost ?? item.costPerUnit,
              notes: reason.isEmpty ? null : reason,
            );
        // Update the item stock in the provider
        ref.read(inventoryProvider.notifier).updateStock(
              _selectedItemId!,
              item.currentStock + quantity,
            );
        break;

      case MovementAction.remove:
        if (quantity > item.currentStock) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'No hay suficiente stock. Disponible: ${item.currentStock} ${item.unit.symbol}',
              ),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        // Record waste
        ref.read(stockMovementsProvider.notifier).recordWaste(
              itemId: _selectedItemId!,
              quantity: quantity,
              notes: reason.isEmpty ? 'Stock removido' : reason,
            );
        // Update the item stock
        ref.read(inventoryProvider.notifier).updateStock(
              _selectedItemId!,
              item.currentStock - quantity,
            );
        break;

      case MovementAction.adjust:
        // Adjust stock to specific value
        ref.read(stockMovementsProvider.notifier).recordAdjustment(
              _selectedItemId!,
              quantity,
              reason.isEmpty ? 'Ajuste de inventario' : reason,
            );
        // Update the item stock
        ref.read(inventoryProvider.notifier).updateStock(
              _selectedItemId!,
              quantity,
            );
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _action == MovementAction.add
              ? 'Stock agregado exitosamente'
              : _action == MovementAction.remove
                  ? 'Stock removido exitosamente'
                  : 'Stock ajustado exitosamente',
        ),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }
}
