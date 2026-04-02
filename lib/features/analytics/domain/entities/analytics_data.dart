import 'package:equatable/equatable.dart';

/// Represents a daily sales entry
class DailySales extends Equatable {
  final String date;
  final int orders;
  final double revenue;

  const DailySales({
    required this.date,
    required this.orders,
    required this.revenue,
  });

  factory DailySales.fromJson(Map<String, dynamic> json) {
    return DailySales(
      date: json['date'] as String? ?? '',
      orders: json['orders'] as int? ?? 0,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'orders': orders,
        'revenue': revenue,
      };

  @override
  List<Object?> get props => [date, orders, revenue];
}

/// Represents a top selling product
class TopProduct extends Equatable {
  final String productId;
  final String productName;
  final int quantitySold;
  final double revenue;

  const TopProduct({
    required this.productId,
    required this.productName,
    required this.quantitySold,
    required this.revenue,
  });

  factory TopProduct.fromJson(Map<String, dynamic> json) {
    return TopProduct(
      productId: json['productId'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      quantitySold: json['quantitySold'] as int? ?? 0,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'productName': productName,
        'quantitySold': quantitySold,
        'revenue': revenue,
      };

  @override
  List<Object?> get props => [productId, productName, quantitySold, revenue];
}

/// Represents order count by status
class StatusCount extends Equatable {
  final String status;
  final int count;

  const StatusCount({
    required this.status,
    required this.count,
  });

  factory StatusCount.fromJson(Map<String, dynamic> json) {
    return StatusCount(
      status: json['status'] as String? ?? '',
      count: json['count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'count': count,
      };

  @override
  List<Object?> get props => [status, count];
}

/// Represents complete dashboard metrics
class DashboardMetrics extends Equatable {
  final double totalRevenue;
  final double todayRevenue;
  final double weekRevenue;
  final double monthRevenue;
  final int totalOrders;
  final int ordersToday;
  final int ordersThisWeek;
  final int ordersThisMonth;
  final double averageTicket;
  final int activeOrders;
  final int totalTables;
  final int availableTables;
  final List<TopProduct> topProducts;
  final List<DailySales> dailySales;

  const DashboardMetrics({
    required this.totalRevenue,
    required this.todayRevenue,
    required this.weekRevenue,
    required this.monthRevenue,
    required this.totalOrders,
    required this.ordersToday,
    required this.ordersThisWeek,
    required this.ordersThisMonth,
    required this.averageTicket,
    required this.activeOrders,
    required this.totalTables,
    required this.availableTables,
    required this.topProducts,
    required this.dailySales,
  });

  factory DashboardMetrics.fromJson(Map<String, dynamic> json) {
    return DashboardMetrics(
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      todayRevenue: (json['todayRevenue'] as num?)?.toDouble() ?? 0.0,
      weekRevenue: (json['weekRevenue'] as num?)?.toDouble() ?? 0.0,
      monthRevenue: (json['monthRevenue'] as num?)?.toDouble() ?? 0.0,
      totalOrders: json['totalOrders'] as int? ?? 0,
      ordersToday: json['ordersToday'] as int? ?? 0,
      ordersThisWeek: json['ordersThisWeek'] as int? ?? 0,
      ordersThisMonth: json['ordersThisMonth'] as int? ?? 0,
      averageTicket: (json['averageTicket'] as num?)?.toDouble() ?? 0.0,
      activeOrders: json['activeOrders'] as int? ?? 0,
      totalTables: json['totalTables'] as int? ?? 0,
      availableTables: json['availableTables'] as int? ?? 0,
      topProducts: (json['topProducts'] as List<dynamic>?)
              ?.map((e) => TopProduct.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      dailySales: (json['dailySales'] as List<dynamic>?)
              ?.map((e) => DailySales.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'totalRevenue': totalRevenue,
        'todayRevenue': todayRevenue,
        'weekRevenue': weekRevenue,
        'monthRevenue': monthRevenue,
        'totalOrders': totalOrders,
        'ordersToday': ordersToday,
        'ordersThisWeek': ordersThisWeek,
        'ordersThisMonth': ordersThisMonth,
        'averageTicket': averageTicket,
        'activeOrders': activeOrders,
        'totalTables': totalTables,
        'availableTables': availableTables,
        'topProducts': topProducts.map((e) => e.toJson()).toList(),
        'dailySales': dailySales.map((e) => e.toJson()).toList(),
      };

  @override
  List<Object?> get props => [
        totalRevenue,
        todayRevenue,
        weekRevenue,
        monthRevenue,
        totalOrders,
        ordersToday,
        ordersThisWeek,
        ordersThisMonth,
        averageTicket,
        activeOrders,
        totalTables,
        availableTables,
        topProducts,
        dailySales,
      ];
}

/// Available time periods for analytics
enum AnalyticsPeriod {
  today('today', 'Hoy'),
  week('week', 'Esta Semana'),
  month('month', 'Este Mes'),
  year('year', 'Este Año');

  final String value;
  final String label;

  const AnalyticsPeriod(this.value, this.label);
}
