// Sync Status Widget
// Shows sync status and provides manual sync button

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/sync_providers.dart';

/// Widget que muestra el estado de sincronización
class SyncStatusWidget extends ConsumerWidget {
  const SyncStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatus = ref.watch(syncStatusProvider);
    final syncNotifier = ref.read(syncStatusProvider.notifier);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Icon(
                  syncStatus.isOnline ? Icons.cloud_done : Icons.cloud_off,
                  color: syncStatus.isOnline ? Colors.green : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  syncStatus.isOnline ? 'Conectado' : 'Sin conexión',
                  style: TextStyle(
                    color: syncStatus.isOnline ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (syncStatus.isSyncing)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),

            // Pending orders indicator
            if (syncStatus.pendingOrdersCount > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.pending, color: Colors.orange, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      '${syncStatus.pendingOrdersCount} órdenes pendientes',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Last sync info
            if (syncStatus.lastSyncMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                syncStatus.lastSyncMessage!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],

            // Sync button
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: syncStatus.isSyncing
                    ? null
                    : () => syncNotifier.forceFullSync(),
                icon: const Icon(Icons.sync),
                label: Text(syncStatus.isSyncing ? 'Sincronizando...' : 'Forzar Sync'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact sync status indicator for app bar or status bar
class SyncStatusIndicator extends ConsumerWidget {
  const SyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatus = ref.watch(syncStatusProvider);

    if (syncStatus.pendingOrdersCount > 0) {
      return Badge(
        label: Text('${syncStatus.pendingOrdersCount}'),
        child: Icon(
          syncStatus.isOnline ? Icons.cloud_sync : Icons.cloud_off,
          color: syncStatus.isOnline ? Colors.green : Colors.orange,
        ),
      );
    }

    return Icon(
      syncStatus.isOnline ? Icons.cloud_done : Icons.cloud_off,
      color: syncStatus.isOnline ? Colors.green : Colors.grey,
      size: 20,
    );
  }
}

/// Sync status chip for showing in lists or grids
class SyncStatusChip extends ConsumerWidget {
  const SyncStatusChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatus = ref.watch(syncStatusProvider);

    if (syncStatus.pendingOrdersCount > 0) {
      return Chip(
        avatar: const Icon(Icons.pending, size: 16, color: Colors.orange),
        label: Text('${syncStatus.pendingOrdersCount} pendientes'),
        backgroundColor: Colors.orange[100],
        labelStyle: const TextStyle(color: Colors.orange, fontSize: 12),
        visualDensity: VisualDensity.compact,
      );
    }

    if (syncStatus.hasError) {
      return Chip(
        avatar: const Icon(Icons.error, size: 16, color: Colors.red),
        label: const Text('Error'),
        backgroundColor: Colors.red[100],
        labelStyle: const TextStyle(color: Colors.red, fontSize: 12),
        visualDensity: VisualDensity.compact,
      );
    }

    return Chip(
      avatar: Icon(
        syncStatus.isOnline ? Icons.check : Icons.cloud_off,
        size: 16,
        color: syncStatus.isOnline ? Colors.green : Colors.grey,
      ),
      label: Text(syncStatus.isOnline ? 'Sincronizado' : 'Offline'),
      backgroundColor: syncStatus.isOnline ? Colors.green[100] : Colors.grey[200],
      labelStyle: TextStyle(
        color: syncStatus.isOnline ? Colors.green : Colors.grey,
        fontSize: 12,
      ),
      visualDensity: VisualDensity.compact,
    );
  }
}
