import 'chart_data.entity.dart';

/// Complete chart configuration entity
/// 
/// This entity contains all configuration needed to render a chart,
/// independent of any specific chart library.
class ChartConfig {
  /// Title of the chart
  final String? title;

  /// Subtitle of the chart
  final String? subtitle;

  /// List of series to be plotted
  final List<ChartSeries> series;

  /// Primary X-axis configuration
  final ChartAxisConfig? primaryXAxis;

  /// Primary Y-axis configuration
  final ChartAxisConfig? primaryYAxis;

  /// Legend configuration
  final ChartLegendConfig? legendConfig;

  /// Tooltip configuration
  final ChartTooltipConfig? tooltipConfig;

  /// Background color (hex string, e.g., "#FFFFFF")
  final String? backgroundColor;

  /// Whether to enable zoom and pan
  final bool enableZoomPan;

  /// Whether to enable selection
  final bool enableSelection;

  /// Palette colors for multiple series
  final List<String>? paletteColors;

  /// Margin around the chart
  final ChartMargin? margin;

  const ChartConfig({
    this.title,
    this.subtitle,
    required this.series,
    this.primaryXAxis,
    this.primaryYAxis,
    this.legendConfig,
    this.tooltipConfig,
    this.backgroundColor,
    this.enableZoomPan = false,
    this.enableSelection = false,
    this.paletteColors,
    this.margin,
  });

  @override
  String toString() {
    return 'ChartConfig(title: $title, series: ${series.length})';
  }
}

/// Chart margin configuration
class ChartMargin {
  final double top;
  final double bottom;
  final double left;
  final double right;

  const ChartMargin({
    this.top = 10,
    this.bottom = 10,
    this.left = 10,
    this.right = 10,
  });

  const ChartMargin.all(double value)
      : top = value,
        bottom = value,
        left = value,
        right = value;

  const ChartMargin.symmetric({
    double vertical = 10,
    double horizontal = 10,
  })  : top = vertical,
        bottom = vertical,
        left = horizontal,
        right = horizontal;
}

