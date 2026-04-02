/// GraphQL Queries for Analytics Dashboard
class AnalyticsGQLQueries {
  /// Get dashboard metrics for a branch
  static const String dashboardMetrics = r'''
    query DashboardMetrics($branchId: UUID!, $period: String!) {
      dashboardMetrics(branchId: $branchId, period: $period) {
        totalRevenue
        todayRevenue
        weekRevenue
        monthRevenue
        totalOrders
        ordersToday
        ordersThisWeek
        ordersThisMonth
        averageTicket
        activeOrders
        totalTables
        availableTables
        topProducts {
          productId
          productName
          quantitySold
          revenue
        }
        dailySales {
          date
          orders
          revenue
        }
      }
    }
  ''';

  /// Get sales by day for a branch
  static const String salesByDay = r'''
    query SalesByDay($branchId: UUID!, $days: Int!) {
      salesByDay(branchId: $branchId, days: $days) {
        date
        orders
        revenue
      }
    }
  ''';

  /// Get top products for a branch
  static const String topProducts = r'''
    query TopProducts($branchId: UUID!, $limit: Int, $period: String) {
      topProducts(branchId: $branchId, limit: $limit, period: $period) {
        productId
        productName
        quantitySold
        revenue
      }
    }
  ''';

  /// Get orders by status for a branch
  static const String ordersByStatus = r'''
    query OrdersByStatus($branchId: UUID!) {
      ordersByStatus(branchId: $branchId) {
        status
        count
      }
    }
  ''';

  /// Get revenue by period for a branch
  static const String revenueByPeriod = r'''
    query RevenueByPeriod($branchId: UUID!, $period: String!) {
      revenueByPeriod(branchId: $branchId, period: $period) {
        totalRevenue
        totalOrders
        averageTicket
        byStatus {
          status
          count
        }
        dailySales {
          date
          orders
          revenue
        }
      }
    }
  ''';
}
