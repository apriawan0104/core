// ignore_for_file: unused_local_variable

import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

/// Chart Service Example
///
/// This example demonstrates how to use the ChartService to create
/// various types of charts in your Flutter application.
///
/// Setup:
/// 1. Add syncfusion_flutter_charts to your pubspec.yaml
/// 2. Register ChartService in DI (see setupChartService below)
/// 3. Use the service to build charts

final getIt = GetIt.instance;

void main() {
  setupChartService();
  runApp(const ChartExampleApp());
}

/// Setup Chart Service in Dependency Injection
void setupChartService() {
  getIt.registerLazySingleton<ChartService>(
    () => SyncfusionChartServiceImpl(),
  );
}

class ChartExampleApp extends StatelessWidget {
  const ChartExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chart Service Examples',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const ChartExamplesPage(),
    );
  }
}

class ChartExamplesPage extends StatelessWidget {
  const ChartExamplesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chart Examples'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildExample(
            context,
            title: '1. Simple Line Chart',
            description: 'Basic line chart with monthly sales data',
            builder: (context) => const SimpleLineChartExample(),
          ),
          const SizedBox(height: 24),
          _buildExample(
            context,
            title: '2. Multiple Series Chart',
            description: 'Chart with multiple data series',
            builder: (context) => const MultipleSeriesChartExample(),
          ),
          const SizedBox(height: 24),
          _buildExample(
            context,
            title: '3. Pie Chart',
            description: 'Circular chart showing market share',
            builder: (context) => const PieChartExample(),
          ),
          const SizedBox(height: 24),
          _buildExample(
            context,
            title: '4. Column Chart',
            description: 'Vertical bar chart',
            builder: (context) => const ColumnChartExample(),
          ),
          const SizedBox(height: 24),
          _buildExample(
            context,
            title: '5. Sparkline Charts',
            description: 'Small inline charts for dashboards',
            builder: (context) => const SparklineChartExample(),
          ),
          const SizedBox(height: 24),
          _buildExample(
            context,
            title: '6. Stacked Area Chart',
            description: 'Stacked chart showing cumulative data',
            builder: (context) => const StackedAreaChartExample(),
          ),
        ],
      ),
    );
  }

  Widget _buildExample(
    BuildContext context, {
    required String title,
    required String description,
    required WidgetBuilder builder,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: builder(context),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example 1: Simple Line Chart
class SimpleLineChartExample extends StatelessWidget {
  const SimpleLineChartExample({super.key});

  @override
  Widget build(BuildContext context) {
    final chartService = getIt<ChartService>();

    final config = ChartConfig(
      title: 'Monthly Sales',
      series: [
        ChartSeries(
          name: 'Sales',
          type: ChartType.line,
          dataPoints: [
            const ChartDataPoint(x: 'Jan', y: 35),
            const ChartDataPoint(x: 'Feb', y: 28),
            const ChartDataPoint(x: 'Mar', y: 34),
            const ChartDataPoint(x: 'Apr', y: 32),
            const ChartDataPoint(x: 'May', y: 40),
            const ChartDataPoint(x: 'Jun', y: 45),
          ],
          showDataLabels: true,
          color: '#2196F3',
        ),
      ],
      primaryXAxis: const ChartAxisConfig(
        type: AxisType.category,
      ),
      primaryYAxis: const ChartAxisConfig(
        type: AxisType.numeric,
        minimum: 0,
        maximum: 50,
      ),
      legendConfig: const ChartLegendConfig(
        isVisible: true,
        position: LegendPosition.bottom,
      ),
      tooltipConfig: const ChartTooltipConfig(
        enable: true,
      ),
    );

    final result = chartService.buildCartesianChart(config);

    return result.fold(
      (failure) => Center(
        child: Text(
          'Error: ${failure.message}',
          style: const TextStyle(color: Colors.red),
        ),
      ),
      (chartWidget) => chartWidget,
    );
  }
}

/// Example 2: Multiple Series Chart
class MultipleSeriesChartExample extends StatelessWidget {
  const MultipleSeriesChartExample({super.key});

  @override
  Widget build(BuildContext context) {
    final chartService = getIt<ChartService>();

    final config = ChartConfig(
      title: 'Sales vs Revenue',
      series: [
        ChartSeries(
          name: 'Sales',
          type: ChartType.column,
          color: '#2196F3',
          dataPoints: const [
            ChartDataPoint(x: 'Q1', y: 35),
            ChartDataPoint(x: 'Q2', y: 28),
            ChartDataPoint(x: 'Q3', y: 34),
            ChartDataPoint(x: 'Q4', y: 32),
          ],
        ),
        ChartSeries(
          name: 'Revenue',
          type: ChartType.line,
          color: '#4CAF50',
          lineWidth: 3,
          dataPoints: const [
            ChartDataPoint(x: 'Q1', y: 40),
            ChartDataPoint(x: 'Q2', y: 35),
            ChartDataPoint(x: 'Q3', y: 38),
            ChartDataPoint(x: 'Q4', y: 42),
          ],
        ),
      ],
      legendConfig: const ChartLegendConfig(
        isVisible: true,
        position: LegendPosition.bottom,
      ),
      tooltipConfig: const ChartTooltipConfig(enable: true),
    );

    final result = chartService.buildCartesianChart(config);

    return result.fold(
      (failure) => Center(child: Text('Error: ${failure.message}')),
      (chartWidget) => chartWidget,
    );
  }
}

/// Example 3: Pie Chart
class PieChartExample extends StatelessWidget {
  const PieChartExample({super.key});

  @override
  Widget build(BuildContext context) {
    final chartService = getIt<ChartService>();

    final config = ChartConfig(
      title: 'Market Share',
      series: [
        ChartSeries(
          name: 'Share',
          type: ChartType.pie,
          dataPoints: const [
            ChartDataPoint(x: 'Product A', y: 45),
            ChartDataPoint(x: 'Product B', y: 30),
            ChartDataPoint(x: 'Product C', y: 15),
            ChartDataPoint(x: 'Product D', y: 10),
          ],
          showDataLabels: true,
        ),
      ],
      legendConfig: const ChartLegendConfig(
        isVisible: true,
        position: LegendPosition.right,
      ),
    );

    final result = chartService.buildCircularChart(config);

    return result.fold(
      (failure) => Center(child: Text('Error: ${failure.message}')),
      (chartWidget) => chartWidget,
    );
  }
}

/// Example 4: Column Chart
class ColumnChartExample extends StatelessWidget {
  const ColumnChartExample({super.key});

  @override
  Widget build(BuildContext context) {
    final chartService = getIt<ChartService>();

    final config = ChartConfig(
      title: 'Team Performance',
      series: [
        ChartSeries(
          name: 'Score',
          type: ChartType.column,
          color: '#FF9800',
          dataPoints: const [
            ChartDataPoint(x: 'Team A', y: 85),
            ChartDataPoint(x: 'Team B', y: 92),
            ChartDataPoint(x: 'Team C', y: 78),
            ChartDataPoint(x: 'Team D', y: 88),
            ChartDataPoint(x: 'Team E', y: 95),
          ],
          showDataLabels: true,
        ),
      ],
      primaryXAxis: const ChartAxisConfig(
        type: AxisType.category,
      ),
      primaryYAxis: const ChartAxisConfig(
        type: AxisType.numeric,
        minimum: 0,
        maximum: 100,
      ),
      tooltipConfig: const ChartTooltipConfig(enable: true),
    );

    final result = chartService.buildCartesianChart(config);

    return result.fold(
      (failure) => Center(child: Text('Error: ${failure.message}')),
      (chartWidget) => chartWidget,
    );
  }
}

/// Example 5: Sparkline Charts
class SparklineChartExample extends StatelessWidget {
  const SparklineChartExample({super.key});

  @override
  Widget build(BuildContext context) {
    final chartService = getIt<ChartService>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSparklineRow(
          context,
          chartService,
          'Line Sparkline:',
          SparklineType.line,
        ),
        const SizedBox(height: 16),
        _buildSparklineRow(
          context,
          chartService,
          'Area Sparkline:',
          SparklineType.area,
        ),
        const SizedBox(height: 16),
        _buildSparklineRow(
          context,
          chartService,
          'Bar Sparkline:',
          SparklineType.bar,
        ),
        const SizedBox(height: 16),
        _buildSparklineRow(
          context,
          chartService,
          'Win-Loss:',
          SparklineType.winLoss,
        ),
      ],
    );
  }

  Widget _buildSparklineRow(
    BuildContext context,
    ChartService chartService,
    String label,
    SparklineType type,
  ) {
    final result = chartService.buildSparkline(
      data: const [1, 5, -6, 0, 1, -2, 7, -7, -4, -10, 13, -6, 7, 5, 11],
      type: type,
      width: 200,
      height: 40,
      color: '#2196F3',
      showTooltip: true,
    );

    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(label),
        ),
        Expanded(
          child: result.fold(
            (failure) => Text('Error: ${failure.message}'),
            (sparkWidget) => sparkWidget,
          ),
        ),
      ],
    );
  }
}

/// Example 6: Stacked Area Chart
class StackedAreaChartExample extends StatelessWidget {
  const StackedAreaChartExample({super.key});

  @override
  Widget build(BuildContext context) {
    final chartService = getIt<ChartService>();

    final config = ChartConfig(
      title: 'Stacked Revenue Sources',
      series: [
        ChartSeries(
          name: 'Product Sales',
          type: ChartType.stackedArea,
          color: '#2196F3',
          dataPoints: const [
            ChartDataPoint(x: 'Jan', y: 20),
            ChartDataPoint(x: 'Feb', y: 25),
            ChartDataPoint(x: 'Mar', y: 22),
            ChartDataPoint(x: 'Apr', y: 28),
          ],
        ),
        ChartSeries(
          name: 'Services',
          type: ChartType.stackedArea,
          color: '#4CAF50',
          dataPoints: const [
            ChartDataPoint(x: 'Jan', y: 15),
            ChartDataPoint(x: 'Feb', y: 18),
            ChartDataPoint(x: 'Mar', y: 20),
            ChartDataPoint(x: 'Apr', y: 22),
          ],
        ),
        ChartSeries(
          name: 'Subscriptions',
          type: ChartType.stackedArea,
          color: '#FF9800',
          dataPoints: const [
            ChartDataPoint(x: 'Jan', y: 10),
            ChartDataPoint(x: 'Feb', y: 12),
            ChartDataPoint(x: 'Mar', y: 15),
            ChartDataPoint(x: 'Apr', y: 18),
          ],
        ),
      ],
      primaryXAxis: const ChartAxisConfig(
        type: AxisType.category,
      ),
      legendConfig: const ChartLegendConfig(
        isVisible: true,
        position: LegendPosition.bottom,
      ),
      tooltipConfig: const ChartTooltipConfig(enable: true),
    );

    final result = chartService.buildCartesianChart(config);

    return result.fold(
      (failure) => Center(child: Text('Error: ${failure.message}')),
      (chartWidget) => chartWidget,
    );
  }
}

/// Example: Reusable Chart Widget
class ReusableSalesChart extends StatelessWidget {
  final String title;
  final List<SalesData> data;
  final ChartType chartType;

  const ReusableSalesChart({
    super.key,
    required this.title,
    required this.data,
    this.chartType = ChartType.line,
  });

  @override
  Widget build(BuildContext context) {
    final chartService = getIt<ChartService>();

    final config = ChartConfig(
      title: title,
      series: [
        ChartSeries(
          name: 'Sales',
          type: chartType,
          dataPoints: data
              .map((d) => ChartDataPoint(x: d.month, y: d.amount))
              .toList(),
          showDataLabels: true,
        ),
      ],
      primaryXAxis: const ChartAxisConfig(
        type: AxisType.category,
      ),
      primaryYAxis: const ChartAxisConfig(
        type: AxisType.numeric,
        minimum: 0,
      ),
      legendConfig: const ChartLegendConfig(
        isVisible: true,
      ),
      tooltipConfig: const ChartTooltipConfig(
        enable: true,
      ),
    );

    final result = chartService.buildCartesianChart(config);

    return result.fold(
      (failure) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 8),
            Text(
              'Failed to load chart',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              failure.message,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      (chartWidget) => chartWidget,
    );
  }
}

/// Sales data model
class SalesData {
  final String month;
  final double amount;

  SalesData(this.month, this.amount);
}

/// Example: Chart with loading state
class ChartWithLoadingExample extends StatefulWidget {
  const ChartWithLoadingExample({super.key});

  @override
  State<ChartWithLoadingExample> createState() =>
      _ChartWithLoadingExampleState();
}

class _ChartWithLoadingExampleState extends State<ChartWithLoadingExample> {
  late Future<List<ChartDataPoint>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadChartData();
  }

  Future<List<ChartDataPoint>> _loadChartData() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    return const [
      ChartDataPoint(x: 'Jan', y: 35),
      ChartDataPoint(x: 'Feb', y: 28),
      ChartDataPoint(x: 'Mar', y: 34),
      ChartDataPoint(x: 'Apr', y: 32),
      ChartDataPoint(x: 'May', y: 40),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ChartDataPoint>>(
      future: _dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No data available'),
          );
        }

        final chartService = getIt<ChartService>();

        final config = ChartConfig(
          title: 'Loaded Data',
          series: [
            ChartSeries(
              name: 'Sales',
              type: ChartType.line,
              dataPoints: snapshot.data!,
            ),
          ],
        );

        final result = chartService.buildCartesianChart(config);

        return result.fold(
          (failure) => Center(child: Text('Error: ${failure.message}')),
          (chartWidget) => chartWidget,
        );
      },
    );
  }
}

