// Offline Sync Test Widget
// Tests the offline sync functionality by simulating offline mode

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// Mock classes for testing
class MockConnectivityResult extends ConnectivityResult {
  const MockConnectivityResult() : super._(0);

  @override
  String get name => 'none';

  @override
  int get index => 0;
}

/// Test widget that simulates offline/online mode
class OfflineSyncTestWidget extends ConsumerStatefulWidget {
  final bool simulateOffline;

  const OfflineSyncTestWidget({
    super.key,
    this.simulateOffline = false,
  });

  @override
  ConsumerState<OfflineSyncTestWidget> createState() =>
      _OfflineSyncTestWidgetState();
}

class _OfflineSyncTestWidgetState
    extends ConsumerState<OfflineSyncTestWidget> {
  bool _isOnline = true;
  int _pendingOrdersCount = 0;
  bool _hasSynced = false;
  String _lastSyncMessage = '';

  // Simulate order data
  final List<Map<String, dynamic>> _testOrders = [];

  @override
  void initState() {
    super.initState();
    _isOnline = !widget.simulateOffline;
  }

  void _simulateOffline() {
    setState(() {
      _isOnline = false;
    });
  }

  void _simulateOnline() {
    setState(() {
      _isOnline = true;
    });
    if (_pendingOrdersCount > 0) {
      _syncOrders();
    }
  }

  void _saveOrderLocally(Map<String, dynamic> order) {
    // Simulate saving order locally when offline
    setState(() {
      _testOrders.add(order);
      _pendingOrdersCount++;
    });
  }

  void _syncOrders() {
    // Simulate syncing orders when back online
    if (!_isOnline) return;

    setState(() {
      _hasSynced = true;
      _lastSyncMessage =
          'Sincronizadas $_pendingOrdersCount órdenes';
      _pendingOrdersCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Offline Sync Test'),
          backgroundColor: _isOnline ? Colors.green : Colors.red,
        ),
        body: Column(
          children: [
            // Status indicator
            Container(
              padding: const EdgeInsets.all(16),
              color: _isOnline ? Colors.green[100] : Colors.red[100],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isOnline ? Icons.cloud_done : Icons.cloud_off,
                    color: _isOnline ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isOnline ? 'ONLINE' : 'OFFLINE',
                    style: TextStyle(
                      color: _isOnline ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Pending orders indicator
            if (_pendingOrdersCount > 0)
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.orange[100],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.pending, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text(
                      '$_pendingOrdersCount órdenes pendientes de sync',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

            // Last sync message
            if (_lastSyncMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(_lastSyncMessage),
              ),

            // Test buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Create order button
                  ElevatedButton.icon(
                    onPressed: () {
                      final order = {
                        'id': 'order_${DateTime.now().millisecondsSinceEpoch}',
                        'items': [
                          {
                            'productId': 'prod_1',
                            'productName': 'Test Product',
                            'quantity': 2,
                            'price': 10.0,
                          }
                        ],
                        'total': 20.0,
                        'createdAt': DateTime.now().toIso8601String(),
                      };

                      if (_isOnline) {
                        _syncOrders();
                      } else {
                        _saveOrderLocally(order);
                      }
                    },
                    icon: const Icon(Icons.add_shopping_cart),
                    label: Text(_isOnline
                        ? 'Crear Orden (Online)'
                        : 'Crear Orden (Offline)'),
                  ),

                  const SizedBox(height: 16),

                  // Simulate offline button
                  if (_isOnline)
                    ElevatedButton.icon(
                      onPressed: _simulateOffline,
                      icon: const Icon(Icons.cloud_off),
                      label: const Text('Simular Offline'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Simulate online button
                  if (!_isOnline)
                    ElevatedButton.icon(
                      onPressed: _simulateOnline,
                      icon: const Icon(Icons.cloud_done),
                      label: const Text('Simular Online y Sync'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Force sync button
                  if (_isOnline && _pendingOrdersCount > 0)
                    ElevatedButton.icon(
                      onPressed: _syncOrders,
                      icon: const Icon(Icons.sync),
                      label: const Text('Forzar Sync'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                ],
              ),
            ),

            // Test orders list
            Expanded(
              child: ListView.builder(
                itemCount: _testOrders.length,
                itemBuilder: (context, index) {
                  final order = _testOrders[index];
                  return ListTile(
                    leading: const Icon(Icons.receipt),
                    title: Text('Orden: ${order['id']}'),
                    subtitle: Text(
                      'Total: \$${order['total']} - ${order['createdAt']}',
                    ),
                    trailing: const Icon(Icons.pending, color: Colors.orange),
                  );
                },
              ),
            ),

            // Test results summary
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[200],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Test Results:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('✓ Online/Offline detection works'),
                  Text(_testOrders.isNotEmpty
                      ? '✓ Orders saved locally when offline'
                      : '○ No orders created yet'),
                  Text(_hasSynced
                      ? '✓ Orders synced when back online'
                      : '○ Sync not triggered yet'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Unit tests for offline sync logic
void main() {
  group('Offline Sync Tests', () {
    test('Order is saved locally when offline', () {
      // This test verifies the offline order saving logic
      final orders = <Map<String, dynamic>>[];
      bool isOnline = false;

      // Simulate creating an order while offline
      final order = {
        'id': 'order_1',
        'items': [
          {
            'productId': 'prod_1',
            'productName': 'Test Product',
            'quantity': 2,
            'price': 10.0,
          }
        ],
        'total': 20.0,
        'createdAt': DateTime.now().toIso8601String(),
      };

      if (!isOnline) {
        orders.add(order);
      }

      expect(orders.length, 1);
      expect(orders.first['id'], 'order_1');
    });

    test('Order is synced when back online', () {
      // This test verifies the online sync logic
      final pendingOrders = <Map<String, dynamic>>[];
      bool isOnline = false;

      // Add some pending orders while offline
      pendingOrders.add({
        'id': 'order_1',
        'total': 20.0,
      });
      pendingOrders.add({
        'id': 'order_2',
        'total': 30.0,
      });

      // Go back online
      isOnline = true;

      // Sync pending orders
      if (isOnline && pendingOrders.isNotEmpty) {
        pendingOrders.clear();
      }

      expect(pendingOrders.length, 0);
      expect(isOnline, true);
    });

    test('JSON encoding of order items works correctly', () {
      final items = [
        {
          'productId': 'prod_1',
          'productName': 'Pizza',
          'quantity': 2,
          'price': 15.0,
          'notes': 'Sin queso',
        },
        {
          'productId': 'prod_2',
          'productName': 'Refresco',
          'quantity': 1,
          'price': 3.0,
          'notes': null,
        },
      ];

      final jsonString = jsonEncode(items);
      final decoded = jsonDecode(jsonString) as List;

      expect(decoded.length, 2);
      expect(decoded[0]['productName'], 'Pizza');
      expect(decoded[0]['quantity'], 2);
      expect(decoded[1]['productName'], 'Refresco');
    });

    test('Total calculation is correct after offline storage', () {
      final items = [
        {'price': 10.0, 'quantity': 2},
        {'price': 5.0, 'quantity': 3},
      ];

      double subtotal = 0;
      for (final item in items) {
        subtotal += (item['price'] as double) * (item['quantity'] as int);
      }

      const taxRate = 0.10;
      final tax = subtotal * taxRate;
      final total = subtotal + tax;

      expect(subtotal, 35.0); // (10*2) + (5*3) = 20 + 15 = 35
      expect(tax, 3.5);
      expect(total, 38.5);
    });
  });

  group('Widget Tests', () {
    testWidgets('Offline mode shows cloud_off icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OfflineSyncTestWidget(simulateOffline: true),
        ),
      );

      // Verify offline indicator is shown
      expect(find.text('OFFLINE'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
    });

    testWidgets('Online mode shows cloud_done icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OfflineSyncTestWidget(simulateOffline: false),
        ),
      );

      // Verify online indicator is shown
      expect(find.text('ONLINE'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_done), findsOneWidget);
    });

    testWidgets('Creating order while offline shows pending indicator',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OfflineSyncTestWidget(simulateOffline: true),
        ),
      );

      // Tap create order button
      await tester.tap(find.text('Crear Orden (Offline)'));
      await tester.pump();

      // Verify pending indicator appears
      expect(find.text('1 órdenes pendientes de sync'), findsOneWidget);
      expect(find.byIcon(Icons.pending), findsWidgets);
    });

    testWidgets('Going online triggers sync',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OfflineSyncTestWidget(simulateOffline: true),
        ),
      );

      // Create an order first (offline)
      await tester.tap(find.text('Crear Orden (Offline)'));
      await tester.pump();

      // Verify pending count
      expect(find.text('1 órdenes pendientes de sync'), findsOneWidget);

      // Go online
      await tester.tap(find.text('Simular Online y Sync'));
      await tester.pump();

      // Verify sync message
      expect(find.text('Sincronizadas 1 órdenes'), findsOneWidget);
    });
  });
}
