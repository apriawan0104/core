import 'package:flutter/widgets.dart';

import '../../../errors/failures.dart';
import '../../../foundation/domain/entities/chart/entities.dart';
import 'package:dartz/dartz.dart';

/// Chart Service Contract
///
/// Generic interface for rendering charts, independent of any specific
/// chart library implementation (Syncfusion, fl_chart, charts_flutter, etc.)
///
/// This follows the Dependency Independence principle - consumers should
/// depend on this interface, not on concrete implementations.
///
/// Example usage:
/// ```dart
/// final chartService = getIt<ChartService>();
/// final widget = chartService.buildCartesianChart(config);
/// ```
abstract class ChartService {
  /// Build a cartesian chart widget from configuration
  ///
  /// Cartesian charts include: line, column, bar, area, scatter, etc.
  ///
  /// Returns:
  /// - Right(Widget): Successfully built chart widget
  /// - Left(ChartFailure): Failed to build chart (invalid config, etc.)
  ///
  /// Example:
  /// ```dart
  /// final config = ChartConfig(
  ///   title: 'Sales Data',
  ///   series: [
  ///     ChartSeries(
  ///       name: 'Sales',
  ///       type: ChartType.line,
  ///       dataPoints: [
  ///         ChartDataPoint(x: 'Jan', y: 35),
  ///         ChartDataPoint(x: 'Feb', y: 28),
  ///       ],
  ///     ),
  ///   ],
  /// );
  ///
  /// final result = chartService.buildCartesianChart(config);
  /// result.fold(
  ///   (failure) => Text('Error: ${failure.message}'),
  ///   (widget) => widget,
  /// );
  /// ```
  Either<Failure, Widget> buildCartesianChart(ChartConfig config);

  /// Build a circular chart widget from configuration
  ///
  /// Circular charts include: pie, doughnut, radial bar
  ///
  /// Returns:
  /// - Right(Widget): Successfully built chart widget
  /// - Left(ChartFailure): Failed to build chart
  ///
  /// Example:
  /// ```dart
  /// final config = ChartConfig(
  ///   title: 'Market Share',
  ///   series: [
  ///     ChartSeries(
  ///       name: 'Share',
  ///       type: ChartType.pie,
  ///       dataPoints: [
  ///         ChartDataPoint(x: 'Product A', y: 45),
  ///         ChartDataPoint(x: 'Product B', y: 30),
  ///         ChartDataPoint(x: 'Product C', y: 25),
  ///       ],
  ///     ),
  ///   ],
  /// );
  ///
  /// final result = chartService.buildCircularChart(config);
  /// ```
  Either<Failure, Widget> buildCircularChart(ChartConfig config);

  /// Build a pyramid chart widget from configuration
  ///
  /// Returns:
  /// - Right(Widget): Successfully built chart widget
  /// - Left(ChartFailure): Failed to build chart
  Either<Failure, Widget> buildPyramidChart(ChartConfig config);

  /// Build a funnel chart widget from configuration
  ///
  /// Returns:
  /// - Right(Widget): Successfully built chart widget
  /// - Left(ChartFailure): Failed to build chart
  Either<Failure, Widget> buildFunnelChart(ChartConfig config);

  /// Build a sparkline chart widget (micro chart)
  ///
  /// Sparkline charts are small, simple charts typically used inline with text
  ///
  /// Parameters:
  /// - data: List of numeric values to plot
  /// - type: Type of spark chart (line, area, bar, winLoss)
  /// - width: Optional width constraint
  /// - height: Optional height constraint
  /// - color: Optional color (hex string)
  /// - showTooltip: Whether to show tooltip on interaction
  ///
  /// Returns:
  /// - Right(Widget): Successfully built sparkline widget
  /// - Left(ChartFailure): Failed to build sparkline
  ///
  /// Example:
  /// ```dart
  /// final sparkline = chartService.buildSparkline(
  ///   data: [1, 5, -6, 0, 1, -2, 7, -7, -4, -10, 13],
  ///   type: SparklineType.line,
  ///   width: 100,
  ///   height: 30,
  /// );
  /// ```
  Either<Failure, Widget> buildSparkline({
    required List<double> data,
    required SparklineType type,
    double? width,
    double? height,
    String? color,
    bool showTooltip = true,
  });

  /// Check if a specific chart type is supported by this implementation
  ///
  /// Different chart library implementations may support different chart types.
  /// Use this to check before attempting to build a chart.
  ///
  /// Returns true if the chart type is supported, false otherwise.
  bool supportsChartType(ChartType type);

  /// Check if a specific sparkline type is supported
  bool supportsSparklineType(SparklineType type);
}

/// Sparkline chart type enumeration
enum SparklineType {
  line,
  area,
  bar,
  winLoss,
}
