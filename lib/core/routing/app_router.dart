import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/pos/presentation/screens/pos_main_screen.dart';
import '../../features/kitchen/presentation/screens/kitchen_screen.dart';
import '../../features/tables/presentation/screens/tables_management_screen.dart';
import '../../features/pos/presentation/screens/order_history_screen.dart';
import '../../features/pos/presentation/screens/dashboard_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/employees/presentation/screens/employees_screen.dart';
import '../../features/inventory/presentation/screens/inventory_screen.dart';
import '../../features/invoices/presentation/screens/invoice_list_screen.dart';
import '../../features/invoices/presentation/screens/invoice_detail_screen.dart';
import '../../features/invoices/presentation/screens/create_invoice_screen.dart';
import '../../features/settings/presentation/screens/fiscal_config_screen.dart';
import '../../features/analytics/presentation/screens/dashboard_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Configuración de rutas de la aplicación
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/tables', // Inicia en gestión de mesas
    routes: [
      // Gestión de Mesas - Nueva pantalla principal
      GoRoute(
        path: '/tables',
        name: 'tables',
        builder: (context, state) => const TablesManagementScreen(),
      ),
      
      // POS (Punto de Venta)
      GoRoute(
        path: '/pos',
        name: 'pos',
        builder: (context, state) => const POSMainScreen(),
      ),
      
      // Vista de Cocina
      GoRoute(
        path: '/kitchen',
        name: 'kitchen',
        builder: (context, state) {
          final branchId = state.uri.queryParameters['branchId'] ?? '';
          return KitchenScreen(branchId: branchId);
        },
      ),
      
      // Historial de Ordenes
      GoRoute(
        path: '/history',
        name: 'history',
        builder: (context, state) => const OrderHistoryScreen(),
      ),
      
      // Dashboard
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      
      // Analytics Dashboard
      GoRoute(
        path: '/analytics',
        name: 'analytics',
        builder: (context, state) {
          final branchId = state.uri.queryParameters['branchId'];
          return AnalyticsDashboardScreen(branchId: branchId);
        },
      ),
      
      // Gestión de Empleados
      GoRoute(
        path: '/employees',
        name: 'employees',
        builder: (context, state) => const EmployeesScreen(),
      ),
      
      // Gestión de Inventario
      GoRoute(
        path: '/inventory',
        name: 'inventory',
        builder: (context, state) => const InventoryScreen(),
      ),
      
      // Login
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      
      // Register
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      
      // Ruta raíz redirige a mesas
      GoRoute(
        path: '/',
        redirect: (context, state) => '/tables',
      ),

      // Product detail (ejemplo, no implementado aún)
      GoRoute(
        path: '/product/:id',
        name: 'product-detail',
        builder: (context, state) {
          final productId = state.pathParameters['id']!;
          return Scaffold(
            appBar: AppBar(title: const Text('Detalle del Producto')),
            body: Center(
              child: Text('Producto ID: $productId\n(Pantalla en desarrollo)'),
            ),
          );
        },
      ),

      // Admin routes (ejemplo básico)
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Panel de Administración')),
          body: const Center(
            child: Text('Panel de administración en desarrollo'),
          ),
        ),
      ),

      // ===== FACTURAS / CFDI =====

      // Lista de facturas
      GoRoute(
        path: '/invoices',
        name: 'invoices',
        builder: (context, state) => const InvoiceListScreen(),
      ),

      // Crear nueva factura
      GoRoute(
        path: '/invoices/create',
        name: 'invoice-create',
        builder: (context, state) => const CreateInvoiceScreen(),
      ),

      // Detalle de factura
      GoRoute(
        path: '/invoices/:id',
        name: 'invoice-detail',
        builder: (context, state) {
          final invoiceId = state.pathParameters['id']!;
          return InvoiceDetailScreen(invoiceId: invoiceId);
        },
      ),

      // Configuración fiscal
      GoRoute(
        path: '/settings/fiscal',
        name: 'fiscal-config',
        builder: (context, state) => const FiscalConfigScreen(),
      ),
    ],
    
    // Error page
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Página no encontrada',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/tables'),
              child: const Text('Volver al inicio'),
            ),
          ],
        ),
      ),
    ),
  );
}
