import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

import '../../../../core/services/notification_service.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(notificationServiceProvider);
    final notificationNotifier =
        ref.read(notificationServiceProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración de Notificaciones'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        children: [
          // Permission status card
          _buildPermissionCard(notificationState),

          const Divider(),

          // Main toggle
          SwitchListTile(
            title: const Text('Habilitar Notificaciones'),
            subtitle: const Text('Recibir alertas de nuevas órdenes y cambios'),
            value: notificationState.notificationsEnabled,
            onChanged: (value) async {
              if (value && !notificationState.permissionGranted) {
                // Request permission first
                final granted =
                    await notificationNotifier.requestPermission();
                if (!granted) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Para habilitar notificaciones, concede el permiso en configuración'),
                        action: SnackBarAction(
                          label: 'Abrir',
                          onPressed: _openAppSettings,
                        ),
                      ),
                    );
                  }
                  return;
                }
              }
              await notificationNotifier.setNotificationsEnabled(value);
            },
          ),

          const Divider(),

          // Token info
          if (notificationState.fcmToken != null)
            ListTile(
              title: const Text('Token de Dispositivo'),
              subtitle: Text(
                '${notificationState.fcmToken!.substring(0, 20)}...',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () async {
                  await notificationNotifier.refreshToken();
                },
              ),
            ),

          const Divider(),

          // Notification history
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Historial de Notificaciones',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (notificationState.notifications.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      notificationNotifier.clearNotifications();
                    },
                    child: const Text('Limpiar'),
                  ),
              ],
            ),
          ),

          if (notificationState.notifications.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No hay notificaciones',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else
            ...notificationState.notifications.asMap().entries.map((entry) {
              final index = entry.key;
              final notification = entry.value;
              return _buildNotificationTile(notification, index);
            }),

          const Divider(),

          // Test notification button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: _isLoading
                  ? null
                  : () => _sendTestNotification(notificationState),
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              label: const Text('Enviar Notificación de Prueba'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionCard(NotificationState state) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (!state.permissionGranted) {
      statusColor = Colors.red;
      statusIcon = Icons.notifications_off;
      statusText = 'Permiso denegado';
    } else if (state.notificationsEnabled) {
      statusColor = Colors.green;
      statusIcon = Icons.notifications_active;
      statusText = 'Activas';
    } else {
      statusColor = Colors.orange;
      statusIcon = Icons.notifications_paused;
      statusText = 'Pausadas';
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(statusIcon, color: statusColor, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Estado de Notificaciones',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    statusText,
                    style: TextStyle(color: statusColor),
                  ),
                ],
              ),
            ),
            if (!state.permissionGranted)
              TextButton(
                onPressed: _openAppSettings,
                child: const Text('Configurar'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTile(PushNotification notification, int index) {
    IconData icon;
    Color iconColor;

    switch (notification.notificationType) {
      case 'ORDER_READY':
        icon = Icons.check_circle;
        iconColor = Colors.green;
        break;
      case 'NEW_ORDER':
        icon = Icons.restaurant;
        iconColor = Colors.orange;
        break;
      case 'NEW_RESERVATION':
        icon = Icons.event;
        iconColor = Colors.blue;
        break;
      default:
        icon = Icons.notifications;
        iconColor = Colors.grey;
    }

    return Dismissible(
      key: Key('notification_$index'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        ref.read(notificationServiceProvider.notifier).removeNotification(index);
      },
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(notification.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.body),
            if (notification.tableName != null)
              Text(
                'Mesa: ${notification.tableName}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
        isThreeLine: true,
        trailing: notification.orderId != null
            ? IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () {
                  // Navigate to order detail
                  debugPrint('Navigate to order: ${notification.orderId}');
                },
              )
            : null,
      ),
    );
  }

  Future<void> _sendTestNotification(NotificationState state) async {
    if (state.fcmToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Primero necesitas un token de dispositivo'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get device info for the mutation
      final deviceInfo = await _getDeviceInfo();

      // The token would be sent to backend via GraphQL mutation:
      // mutation SaveFCMToken($token: String!, $device: String) {
      //   saveFCMToken(token: $token, device: $device) {
      //     success
      //     message
      //   }
      // }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notificación de prueba enviada al servidor'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<String> _getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return 'Android ${androidInfo.version.release} - ${androidInfo.model}';
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return 'iOS ${iosInfo.systemVersion} - ${iosInfo.model}';
    }
    return 'Unknown';
  }

  static void _openAppSettings() {
    // This would open the app settings page
    // On iOS: Util.openAppSettings();
    // On Android: DeviceInfoPlugin would need to use AppSettings package
  }
}

// Badge widget for showing pending notifications
class NotificationBadge extends StatelessWidget {
  final int count;
  final Widget child;

  const NotificationBadge({
    super.key,
    required this.count,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return child;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          right: -6,
          top: -6,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            constraints: const BoxConstraints(
              minWidth: 18,
              minHeight: 18,
            ),
            child: Text(
              count > 99 ? '99+' : count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
