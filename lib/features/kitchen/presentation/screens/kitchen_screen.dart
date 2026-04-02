import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/enums/pos_order_status.dart';
import '../providers/kitchen_orders_provider.dart';
import '../widgets/order_ticket.dart';

/// Main Kitchen Display Screen - shows all orders currently being prepared
/// Designed for fullscreen use on kitchen tablets
class KitchenScreen extends ConsumerStatefulWidget {
  final String branchId;

  const KitchenScreen({
    super.key,
    required this.branchId,
  });

  @override
  ConsumerState<KitchenScreen> createState() => _KitchenScreenState();
}

class _KitchenScreenState extends ConsumerState<KitchenScreen> {
  @override
  void initState() {
    super.initState();
    // Enter fullscreen mode
    _enterFullscreen();
  }

  void _enterFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    // Restore system UI when leaving
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _markOrderReady(String orderId) async {
    await ref.read(kitchenOrdersProvider(widget.branchId).notifier).markOrderReady(orderId);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(kitchenOrdersProvider(widget.branchId));
    final sortedOrders = state.sortedOrders;

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with title and stats
            _buildTopBar(context, state),
            
            // Orders grid
            Expanded(
              child: _buildOrdersGrid(sortedOrders, state.newOrderIds),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, KitchenOrdersState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          // Title
          const Icon(
            Icons.restaurant,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(width: 12),
          const Text(
            'COCINA',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          
          const Spacer(),
          
          // Order stats
          _buildStatChip(
            'Pendientes',
            sortedOrders.length.toString(),
            Colors.orange,
          ),
          const SizedBox(width: 16),
          
          // Loading indicator
          if (state.isLoading)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () => ref.read(kitchenOrdersProvider(widget.branchId).notifier).refresh(),
              tooltip: 'Actualizar',
            ),
          
          const SizedBox(width: 8),
          
          // Exit button
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Salir',
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersGrid(List orders, Set<String> newOrderIds) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant,
              size: 100,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 20),
            Text(
              'No hay órdenes en preparación',
              style: TextStyle(
                fontSize: 24,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Las nuevas órdenes aparecerán aquí automáticamente',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate how many tickets can fit in a row
        final ticketWidth = 320.0;
        final ticketHeight = 450.0;
        final spacing = 16.0;
        
        final crossAxisCount = ((constraints.maxWidth - spacing) / (ticketWidth + spacing)).floor().clamp(1, 5);
        
        return GridView.builder(
          padding: const EdgeInsets.all(spacing),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: ticketWidth / ticketHeight,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
          ),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            final isNew = newOrderIds.contains(order.id);
            
            return OrderTicket(
              order: order,
              isNew: isNew,
              onMarkReady: () => _markOrderReady(order.id),
            );
          },
        );
      },
    );
  }
}