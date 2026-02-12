import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Manejo seguro de configuraciones y secretos
class AppConfig {
  static String get firebaseProjectId => 
      dotenv.env['FIREBASE_PROJECT_ID'] ?? 'demo-project';
  
  static String get firebaseApiKey => 
      dotenv.env['FIREBASE_API_KEY'] ?? '';
  
  static String get paymentApiKey => 
      dotenv.env['PAYMENT_API_KEY'] ?? '';
  
  static String get printServiceUrl => 
      dotenv.env['PRINT_SERVICE_URL'] ?? 'http://localhost:8080';
  
  static bool get isDebug => 
      dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true';
  
  static String get logLevel => 
      dotenv.env['LOG_LEVEL'] ?? 'info';
  
  /// Cargar configuraciones al iniciar la app
  static Future<void> load() async {
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      print("Warning: No .env file found, using defaults");
    }
  }
  
  /// Verificar si todas las configuraciones necesarias están presentes
  static bool get isConfigComplete {
    return firebaseApiKey.isNotEmpty && 
           firebaseProjectId != 'demo-project';
  }
}