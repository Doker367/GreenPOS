import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../../core/graphql/analytics_queries.dart';
import '../../../../core/graphql/client.dart';
import '../../domain/entities/analytics_data.dart';

/// State for the analytics dashboard
class AnalyticsState {
  final DashboardMetrics? metrics;
  final List<DailySales> dailySales;
  final List<TopProduct> topProducts;
  final List<StatusCount> ordersByStatus;
  final bool isLoading;
  final String? error;
  final AnalyticsPeriod selectedPeriod;
  final String? branchId;

  const AnalyticsState({
    this.metrics,
    this.dailySales = const [],
    this.topProducts = const [],
    this.ordersByStatus = const [],
    this.isLoading = false,
    this.error,
    this.selectedPeriod = AnalyticsPeriod.week,
    this.branchId,
  });

  AnalyticsState copyWith({
    DashboardMetrics? metrics,
    List<DailySales>? dailySales,
    List<TopProduct>? topProducts,
    List<StatusCount>? ordersByStatus,
    bool? isLoading,
    String? error,
    AnalyticsPeriod? selectedPeriod,
    String? branchId,
  }) {
    return AnalyticsState(
      metrics: metrics ?? this.metrics,
      dailySales: dailySales ?? this.dailySales,
      topProducts: topProducts ?? this.topProducts,
      ordersByStatus: ordersByStatus ?? this.ordersByStatus,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      branchId: branchId ?? this.branchId,
    );
  }
}

/// Notifier for analytics state management
class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  AnalyticsNotifier() : super(const AnalyticsState());

  /// Load dashboard metrics
  Future<void> loadDashboardMetrics(String branchId, AnalyticsPeriod period) async {
    state = state.copyWith(isLoading: true, error: null, branchId: branchId, selectedPeriod: period);

    try {
      final client = GraphQLClientSingleton.client;

      final result = await client.query(
        QueryOptions(
          document: gql(AnalyticsGQLQueries.dashboardMetrics),
          variables: {
            'branchId': branchId,
            'period': period.value,
          },
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        state = state.copyWith(
          isLoading: false,
          error: result.exception?.graphqlErrors.firstOrNull?.message ??
                 result.exception?.linkException?.toString() ??
                 'Error al cargar métricas',
        );
        return;
      }

      final data = result.data?['dashboardMetrics'];
      if (data != null) {
        final metrics = DashboardMetrics.fromJson(data as Map<String, dynamic>);
        state = state.copyWith(
          metrics: metrics,
          dailySales: metrics.dailySales,
          topProducts: metrics.topProducts,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error inesperado: $e',
      );
    }
  }

  /// Load sales by day
  Future<void> loadSalesByDay(String branchId, int days) async {
    try {
      final client = GraphQLClientSingleton.client;

      final result = await client.query(
        QueryOptions(
          document: gql(AnalyticsGQLQueries.salesByDay),
          variables: {
            'branchId': branchId,
            'days': days,
          },
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        return;
      }

      final data = result.data?['salesByDay'] as List<dynamic>?;
      if (data != null) {
        final sales = data
            .map((e) => DailySales.fromJson(e as Map<String, dynamic>))
            .toList();
        state = state.copyWith(dailySales: sales);
      }
    } catch (_) {
      // Silently fail for secondary data
    }
  }

  /// Load top products
  Future<void> loadTopProducts(String branchId, {int limit = 10, String? period}) async {
    try {
      final client = GraphQLClientSingleton.client;

      final result = await client.query(
        QueryOptions(
          document: gql(AnalyticsGQLQueries.topProducts),
          variables: {
            'branchId': branchId,
            'limit': limit,
            'period': period,
          },
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        return;
      }

      final data = result.data?['topProducts'] as List<dynamic>?;
      if (data != null) {
        final products = data
            .map((e) => TopProduct.fromJson(e as Map<String, dynamic>))
            .toList();
        state = state.copyWith(topProducts: products);
      }
    } catch (_) {
      // Silently fail for secondary data
    }
  }

  /// Load orders by status
  Future<void> loadOrdersByStatus(String branchId) async {
    try {
      final client = GraphQLClientSingleton.client;

      final result = await client.query(
        QueryOptions(
          document: gql(AnalyticsGQLQueries.ordersByStatus),
          variables: {
            'branchId': branchId,
          },
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        return;
      }

      final data = result.data?['ordersByStatus'] as List<dynamic>?;
      if (data != null) {
        final statuses = data
            .map((e) => StatusCount.fromJson(e as Map<String, dynamic>))
            .toList();
        state = state.copyWith(ordersByStatus: statuses);
      }
    } catch (_) {
      // Silently fail for secondary data
    }
  }

  /// Change selected period and reload data
  Future<void> changePeriod(String branchId, AnalyticsPeriod period) async {
    await loadDashboardMetrics(branchId, period);
  }

  /// Refresh all data
  Future<void> refresh(String branchId) async {
    final period = state.selectedPeriod;
    await loadDashboardMetrics(branchId, period);
  }

  /// Load mock data for demo purposes
  void loadMockData() {
    final now = DateTime.now();
    final dailySales = List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      return DailySales(
        date: '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
        orders: 15 + index * 3 + (index % 3 == 0 ? 5 : 0),
        revenue: 2500 + index * 350.0 + (index % 2 == 0 ? 500 : 0),
      );
    });

    final topProducts = [
      const TopProduct(productId: '1', productName: 'Hamburguesa Clásica', quantitySold: 145, revenue: 21750.0),
      const TopProduct(productId: '2', productName: 'Pizza Margherita', quantitySold: 98, revenue: 19600.0),
      const TopProduct(productId: '3', productName: 'Ensalada César', quantitySold: 87, revenue: 13050.0),
      const TopProduct(productId: '4', productName: 'Pasta Carbonara', quantitySold: 76, revenue: 11400.0),
      const TopProduct(productId: '5', productName: 'Coca-Cola 600ml', quantitySold: 234, revenue: 2808.0),
      const TopProduct(productId: '6', productName: 'Ribeye 400g', quantitySold: 45, revenue: 22500.0),
      const TopProduct(productId: '7', productName: 'Salmón a la Parrilla', quantitySold: 38, revenue: 15200.0),
      const TopProduct(productId: '8', productName: 'Tiramisú', quantitySold: 67, revenue: 7370.0),
      const TopProduct(productId: '9', productName: 'Café Espresso', quantitySold: 189, revenue: 3780.0),
      const TopProduct(productId: '10', productName: 'Copa de Vino Tinto', quantitySold: 52, revenue: 7800.0),
    ];

    final ordersByStatus = [
      const StatusCount(status: 'PENDING', count: 8),
      const StatusCount(status: 'ACCEPTED', count: 5),
      const StatusCount(status: 'PREPARING', count: 3),
      const StatusCount(status: 'READY', count: 2),
      const StatusCount(status: 'DELIVERED', count: 127),
      const StatusCount(status: 'PAID', count: 145),
      const StatusCount(status: 'CANCELLED', count: 4),
    ];

    final metrics = DashboardMetrics(
      totalRevenue: 125750.0,
      todayRevenue: 8750.0,
      weekRevenue: 45600.0,
      monthRevenue: 125750.0,
      totalOrders: 294,
      ordersToday: 42,
      ordersThisWeek: 187,
      ordersThisMonth: 294,
      averageTicket: 427.89,
      activeOrders: 18,
      totalTables: 24,
      availableTables: 6,
      topProducts: topProducts,
      dailySales: dailySales,
    );

    state = state.copyWith(
      metrics: metrics,
      dailySales: dailySales,
      topProducts: topProducts,
      ordersByStatus: ordersByStatus,
      isLoading: false,
    );
  }
}

/// Provider for analytics state
final analyticsProvider =
    StateNotifierProvider<AnalyticsNotifier, AnalyticsState>((ref) {
  return AnalyticsNotifier();
});
