import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/providers/repository_providers.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';

void main() async {
  // Asegurar inicialización de Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase (opcional - modo demo sin Firebase)
  // NOTA: Para habilitar Firebase, ejecuta: flutterfire configure
  bool firebaseInitialized = false;
  try {
    await Firebase.initializeApp();
    firebaseInitialized = true;
    debugPrint('✅ Firebase inicializado correctamente');
  } catch (e) {
    debugPrint('⚠️  Ejecutando en modo DEMO sin Firebase');
    debugPrint('   Para configurar Firebase: dart run flutterfire configure');
    // Continuar sin Firebase - la app funciona en modo local
  }

  // Inicializar SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  // Ejecutar app
  runApp(
    ProviderScope(
      overrides: [
        // Override del provider de SharedPreferences con la instancia real
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: MyApp(firebaseEnabled: firebaseInitialized),
    ),
  );
}

class MyApp extends ConsumerWidget {
  final bool firebaseEnabled;
  
  const MyApp({super.key, this.firebaseEnabled = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'GreenPOS ${!firebaseEnabled ? "(Demo)" : ""}',
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
