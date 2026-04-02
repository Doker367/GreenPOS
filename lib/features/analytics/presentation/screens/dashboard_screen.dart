import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/analytics_data.dart';
import '../providers/analytics_provider.dart';
import '../widgets/metrics_cards.dart';
import '../widgets/sales_chart.dart';
import '../widgets/top_products.dart';
import '../../../../core/utils/responsive_utils.dart';

/// Main analytics dashboard screen
class AnalyticsDashboardScreen extends ConsumerStatefulWidget {
  final String? branchId;

  const AnalyticsDashboardScreen({
    super.key,
    this.branchId,
  });

  @override
  ConsumerState<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState
    extends ConsumerState<AnalyticsDashboardScreen> {
  AnalyticsPeriod _selectedPeriod = AnalyticsPeriod.week;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    // Load mock data initially since we don't have a real branch ID
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analyticsProvider.notifier).loadMockData();
      _initialized = true;
    });
  }

  void _onPeriodChanged(AnalyticsPeriod period) {
    setState(() => _selectedPeriod = period);
    // In production, this would reload data from the backend
    // For demo, we just reload mock data
    ref.read(analyticsProvider.notifier).loadMockData();
  }

  Future<void> _onRefresh() async {
    ref.read(analyticsProvider.notifier).loadMockData();
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    final analyticsState = ref.watch(analyticsProvider);
    final isTablet = ResponsiveUtils.isTablet(context);
    final isDesktop = ResponsiveUtils.isDesktop(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Analytics'),
        centerTitle: false,
        elevation: 0,
        actions: [
          // Period selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SegmentedButton<AnalyticsPeriod>(
              segments: AnalyticsPeriod.values
                  .map((p) => ButtonSegment(
                        value: p,
                        label: Text(p.label),
                      ))
                  .toList(),
              selected: {_selectedPeriod},
              onSelectionChanged: (selection) {
                _onPeriodChanged(selection.first);
              },
              showSelectedIcon: false,
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                textStyle: WidgetStateProperty.all(
                  Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: analyticsState.isLoading ? null : _onRefresh,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(context, analyticsState, isTablet, isDesktop),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AnalyticsState state,
    bool isTablet,
    bool isDesktop,
  ) {
    if (state.isLoading && state.metrics == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando métricas...'),
          ],
        ),
      );
    }

    if (state.error != null && state.metrics == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar datos',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(state.error!),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (state.metrics == null) {
      return const Center(child: Text('No hay datos disponibles'));
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: isDesktop
          ? _buildDesktopLayout(context, state)
          : isTablet
              ? _buildTabletLayout(context, state)
              : _buildMobileLayout(context, state),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, AnalyticsState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Metrics cards
          MetricsCardsGrid(metrics: state.metrics!),
          const SizedBox(height: 24),

          // Charts row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: SalesBarChart(dailySales: state.dailySales),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: RevenueLineChart(dailySales: state.dailySales),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Top products
          TopProductsWidget(products: state.topProducts),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context, AnalyticsState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Metrics cards (compact)
          MetricsCardsGrid(metrics: state.metrics!, isCompact: true),
          const SizedBox(height: 16),

          // Sales chart
          SalesBarChart(dailySales: state.dailySales),
          const SizedBox(height: 16),

          // Revenue line chart
          RevenueLineChart(dailySales: state.dailySales),
          const SizedBox(height: 16),

          // Top products
          TopProductsWidget(products: state.topProducts, isCompact: true),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, AnalyticsState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Metrics cards (compact 2 columns)
          MetricsCardsGrid(metrics: state.metrics!, isCompact: true),
          const SizedBox(height: 12),

          // Sales chart
          SalesBarChart(dailySales: state.dailySales),
          const SizedBox(height: 12),

          // Top products (table only for mobile)
          TopProductsTable(products: state.topProducts),
        ],
      ),
    );
  }
}

/// Error widget for displaying error states
class AnalyticsErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AnalyticsErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Loading placeholder widget
class AnalyticsLoadingWidget extends StatelessWidget {
  const AnalyticsLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Cargando analytics...'),
        ],
      ),
    );
  }
}
