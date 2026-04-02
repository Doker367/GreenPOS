import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'core/providers/repository_providers.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/services/notification_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background messages
  debugPrint('Handling background message: ${message.messageId}');
}

void main() async {
  // Asegurar inicialización de Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp();

  // Registrar handler para mensajes en background
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Inicializar SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  // Ejecutar app
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    _setupNotifications();
  }

  Future<void> _setupNotifications() async {
    final messaging = FirebaseMessaging.instance;

    // Obtener token inicial
    final token = await messaging.getToken();
    if (token != null) {
      debugPrint('FCM Token: ${token.substring(0, 20)}...');
    }

    // Escuchar cambios de token
    messaging.onTokenRefresh.listen((newToken) async {
      debugPrint('FCM Token refreshed: ${newToken.substring(0, 20)}...');
      // Guardar y subir nuevo token
    });

    // Configurar handlers para mensajes
    _configureMessageHandlers();
  }

  void _configureMessageHandlers() {
    final messaging = FirebaseMessaging.instance;

    // Handler para mensajes cuando la app está abierta (foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground message received: ${message.notification?.title}');
      ref.read(notificationServiceProvider.notifier).handleForegroundMessage(message);
      _showNotificationSnackBar(message);
    });

    // Handler para cuando el usuario toca una notificación y la app está abierta
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Message opened app: ${message.notification?.title}');
      _handleNotificationTap(message);
    });

    // Verificar si había una notificación al abrir la app
    _checkInitialMessage();
  }

  Future<void> _checkInitialMessage() async {
    final messaging = FirebaseMessaging.instance;
    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('App opened from terminated state via notification');
      _handleNotificationTap(initialMessage);
    }
  }

  void _showNotificationSnackBar(RemoteMessage message) {
    // El snackbar se muestra desde el provider o un overlay
    final notification = PushNotification.fromRemoteMessage(message);
    debugPrint('Notification: ${notification.title} - ${notification.body}');
  }

  void _handleNotificationTap(RemoteMessage message) {
    final notification = PushNotification.fromRemoteMessage(message);
    final type = notification.notificationType;
    final orderId = notification.orderId;

    if (type == 'ORDER_READY' && orderId != null) {
      // Navegar a la pantalla de órdenes o mostrar detalle
      debugPrint('Order ready notification tapped for order: $orderId');
      // AppRouter.router.push('/orders/$orderId');
    } else if (type == 'NEW_ORDER' && orderId != null) {
      // Navegar a pantalla de cocina
      debugPrint('New order notification tapped for order: $orderId');
      // AppRouter.router.push('/kitchen');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'GreenPOS',
      debugShowCheckedModeBanner: false,

      // Temas
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

      // Routing
      routerConfig: AppRouter.router,
    );
  }
}
