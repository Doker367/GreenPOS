import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../qrmenu/data/repositories/qrmenu_repository.dart';
import '../../../qrmenu/domain/entities/qrmenu_entities.dart';
import '../../domain/entities/restaurant_table.dart';
import '../providers/tables_provider.dart';

/// Screen for managing QR codes for tables
/// Staff can generate, view, and print QR codes for each table
class QRManagementScreen extends ConsumerStatefulWidget {
  const QRManagementScreen({super.key});

  @override
  ConsumerState<QRManagementScreen> createState() =>
      _QRManagementScreenState();
}

class _QRManagementScreenState extends ConsumerState<QRManagementScreen> {
  final Map<String, TableQRCode?> _qrCodes = {};
  final Map<String, bool> _loadingQR = {};
  final QRMenuRepository _repository = QRMenuRepository();

  @override
  Widget build(BuildContext context) {
    final tablesState = ref.watch(tablesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Código QR por Mesa'),
        centerTitle: true,
      ),
      body: tablesState.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code_2, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No hay mesas registradas',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tablesState.length,
              itemBuilder: (context, index) {
                final table = tablesState[index];
                return _buildTableQRCard(table);
              },
            ),
    );
  }

  Widget _buildTableQRCard(RestaurantTable table) {
    final qrCode = _qrCodes[table.id];
    final isLoading = _loadingQR[table.id] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with table info
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.table_restaurant,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mesa ${table.number}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Capacidad: ${table.capacity} personas',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(table.status),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // QR Code section
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (qrCode != null) ...[
              Center(
                child: Column(
                  children: [
                    // QR Code with logo
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: QrImageView(
                        data: qrCode.accessUrl,
                        version: QrVersions.auto,
                        size: 180,
                        backgroundColor: Colors.white,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: Colors.black,
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: Colors.black,
                        ),
                        // Note: Logo overlay would require custom implementation
                        // For now, we just display the QR code
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Token: ${qrCode.qrToken.substring(0, 8)}...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Access URL
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.link, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        qrCode.accessUrl,
                        style: const TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _printQRCode(table, qrCode),
                      icon: const Icon(Icons.print),
                      label: const Text('Imprimir'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _regenerateQRCode(table),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Actualizar'),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // No QR code yet - show generate button
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.qr_code_2,
                      size: 64,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sin código QR',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _generateQRCode(table),
                      icon: const Icon(Icons.add),
                      label: const Text('Generar Código QR'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status.toUpperCase()) {
      case 'AVAILABLE':
        color = Colors.green;
        label = 'Disponible';
        break;
      case 'OCCUPIED':
        color = Colors.orange;
        label = 'Ocupada';
        break;
      case 'RESERVED':
        color = Colors.blue;
        label = 'Reservada';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Future<void> _generateQRCode(RestaurantTable table) async {
    setState(() {
      _loadingQR[table.id] = true;
    });

    final result = await _repository.generateTableQR(tableId: table.id);

    result.fold(
      (failure) {
        if (mounted) {
          setState(() => _loadingQR[table.id] = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${failure.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      (qrCode) {
        if (mounted) {
          setState(() {
            _qrCodes[table.id] = qrCode;
            _loadingQR[table.id] = false;
          });
        }
      },
    );
  }

  Future<void> _regenerateQRCode(RestaurantTable table) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Actualizar Código QR'),
        content: const Text(
          '¿Deseas generar un nuevo código QR? El código anterior dejará de ser válido.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _generateQRCode(table);
    }
  }

  void _printQRCode(RestaurantTable table, TableQRCode qrCode) {
    // In a real app, this would trigger printing functionality
    // For now, we just show a message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Imprimiendo QR para Mesa ${table.number}...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
