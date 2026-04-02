import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Model for push notifications
class PushNotification {
  final String title;
  final String body;
  final Map<String, dynamic>? data;

  PushNotification({
    required this.title,
    required this.body,
    this.data,
  });

  factory PushNotification.fromRemoteMessage(RemoteMessage message) {
    return PushNotification(
      title: message.notification?.title ?? '',
      body: message.notification?.body ?? '',
      data: message.data.isNotEmpty ? message.data : null,
    );
  }

  String? get orderId => data?['orderId'];
  String? get notificationType => data?['type'];
  String? get tableName => data?['tableName'];
}

// Provider for SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in ProviderScope');
});

// State notifier for notifications
class NotificationState {
  final bool permissionGranted;
  final String? fcmToken;
  final List<PushNotification> notifications;
  final bool notificationsEnabled;

  NotificationState({
    this.permissionGranted = false,
    this.fcmToken,
    this.notifications = const [],
    this.notificationsEnabled = true,
  });

  NotificationState copyWith({
    bool? permissionGranted,
    String? fcmToken,
    List<PushNotification>? notifications,
    bool? notificationsEnabled,
  }) {
    return NotificationState(
      permissionGranted: permissionGranted ?? this.permissionGranted,
      fcmToken: fcmToken ?? this.fcmToken,
      notifications: notifications ?? this.notifications,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

class NotificationStateNotifier extends StateNotifier<NotificationState> {
  final FirebaseMessaging _messaging;
  final SharedPreferences _prefs;

  static const _tokenKey = 'fcm_token';
  static const _enabledKey = 'notifications_enabled';

  NotificationStateNotifier(this._messaging, this._prefs)
      : super(NotificationState()) {
    _init();
  }

  Future<void> _init() async {
    // Load saved preferences
    final savedToken = _prefs.getString(_tokenKey);
    final enabled = _prefs.getBool(_enabledKey) ?? true;

    state = state.copyWith(
      fcmToken: savedToken,
      notificationsEnabled: enabled,
    );

    // Request permission if not already done
    await requestPermission();

    // Get and save token if enabled
    if (state.permissionGranted && enabled) {
      await _getAndSaveToken();
    }
  }

  Future<bool> requestPermission() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      final granted = settings.authorizationStatus == AuthorizationStatus.authorized;
      state = state.copyWith(permissionGranted: granted);
      return granted;
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
      return false;
    }
  }

  Future<void> _getAndSaveToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        state = state.copyWith(fcmToken: token);
        await _prefs.setString(_tokenKey, token);
        // Upload token to server
        await _uploadTokenToServer(token);
      }
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
    }
  }

  Future<void> _uploadTokenToServer(String token) async {
    // This will be called by the GraphQL service
    // The actual upload is handled by the GraphQL mutation
    debugPrint('FCM Token ready for upload: ${token.substring(0, 20)}...');
  }

  Future<void> refreshToken() async {
    if (!state.permissionGranted || !state.notificationsEnabled) return;
    await _getAndSaveToken();
  }

  void handleForegroundMessage(RemoteMessage message) {
    if (!state.notificationsEnabled) return;

    final notification = PushNotification.fromRemoteMessage(message);
    state = state.copyWith(
      notifications: [...state.notifications, notification],
    );

    // Show in-app notification
    _showInAppNotification(notification);
  }

  void _showInAppNotification(PushNotification notification) {
    // This will be handled by the UI layer
    debugPrint('In-app notification: ${notification.title} - ${notification.body}');
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(_enabledKey, enabled);
    state = state.copyWith(notificationsEnabled: enabled);

    if (enabled && state.permissionGranted) {
      await _getAndSaveToken();
    }
  }

  void clearNotifications() {
    state = state.copyWith(notifications: []);
  }

  void removeNotification(int index) {
    final updated = List<PushNotification>.from(state.notifications);
    if (index >= 0 && index < updated.length) {
      updated.removeAt(index);
      state = state.copyWith(notifications: updated);
    }
  }

  // Getters for UI
  bool get hasUnreadNotifications => state.notifications.isNotEmpty;
  int get unreadCount => state.notifications.length;
}

// Provider for notification service
final notificationServiceProvider =
    StateNotifierProvider<NotificationStateNotifier, NotificationState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final messaging = FirebaseMessaging.instance;
  return NotificationStateNotifier(messaging, prefs);
});

// GraphQL mutation helper
class NotificationGraphQL {
  static const String saveTokenMutation = '''
    mutation SaveFCMToken(\$token: String!, \$device: String) {
      saveFCMToken(token: \$token, device: \$device) {
        success
        message
      }
    }
  ''';

  static const String removeTokenMutation = '''
    mutation RemoveFCMToken(\$token: String!) {
      removeFCMToken(token: \$token) {
        success
        message
      }
    }
  ''';

  static Map<String, dynamic> saveTokenVariables(String token, String device) => {
        'token': token,
        'device': device,
      };

  static Map<String, dynamic> removeTokenVariables(String token) => {
        'token': token,
      };
}
