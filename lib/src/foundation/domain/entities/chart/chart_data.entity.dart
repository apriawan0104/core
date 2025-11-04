/// Chart data point entity
/// 
/// Represents a single data point in a chart series.
/// This is a generic, provider-independent representation.
class ChartDataPoint {
  /// The x-axis value
  final dynamic x;

  /// The y-axis value
  final dynamic y;

  /// Optional: Size for bubble charts
  final double? size;

  /// Optional: High value for range/stock charts
  final double? high;

  /// Optional: Low value for range/stock charts
  final double? low;

  /// Optional: Open value for stock charts
  final double? open;

  /// Optional: Close value for stock charts
  final double? close;

  /// Optional: Color for this specific data point
  final String? color;

  /// Optional: Label for this data point
  final String? label;

  const ChartDataPoint({
    required this.x,
    required this.y,
    this.size,
    this.high,
    this.low,
    this.open,
    this.close,
    this.color,
    this.label,
  });

  @override
  String toString() {
    return 'ChartDataPoint(x: $x, y: $y, size: $size, high: $high, low: $low, open: $open, close: $close, color: $color, label: $label)';
  }
}

/// Chart series entity
/// 
/// Represents a series of data points to be plotted on a chart.
class ChartSeries {
  /// Name of the series (shown in legend)
  final String name;

  /// List of data points
  final List<ChartDataPoint> dataPoints;

  /// Type of chart for this series
  final ChartType type;

  /// Color for this series
  final String? color;

  /// Whether to show data labels
  final bool showDataLabels;

  /// Whether to enable tooltip
  final bool enableTooltip;

  /// Line width (for line/spline charts)
  final double? lineWidth;

  /// Opacity of the series (0.0 to 1.0)
  final double opacity;

  const ChartSeries({
    required this.name,
    required this.dataPoints,
    required this.type,
    this.color,
    this.showDataLabels = false,
    this.enableTooltip = true,
    this.lineWidth,
    this.opacity = 1.0,
  });

  @override
  String toString() {
    return 'ChartSeries(name: $name, type: $type, dataPoints: ${dataPoints.length} points)';
  }
}

/// Chart type enumeration
enum ChartType {
  // Cartesian Charts
  line,
  spline,
  area,
  splineArea,
  column,
  bar,
  stepLine,
  stepArea,
  scatter,
  bubble,
  
  // Range Charts
  rangeColumn,
  rangeArea,
  splineRangeArea,
  
  // Stock Charts
  candle,
  hilo,
  ohlc,
  
  // Stacked Charts
  stackedColumn,
  stackedBar,
  stackedArea,
  stackedLine,
  stackedColumn100,
  stackedBar100,
  stackedArea100,
  stackedLine100,
  
  // Other Cartesian
  histogram,
  waterfall,
  
  // Circular Charts
  pie,
  doughnut,
  radialBar,
  
  // Pyramids & Funnels
  pyramid,
  funnel,
}

/// Chart axis configuration
class ChartAxisConfig {
  /// Title of the axis
  final String? title;

  /// Axis type
  final AxisType type;

  /// Minimum value (for numeric axis)
  final double? minimum;

  /// Maximum value (for numeric axis)
  final double? maximum;

  /// Interval between axis labels
  final double? interval;

  /// Whether to show grid lines
  final bool showGridLines;

  /// Whether to show axis line
  final bool showAxisLine;

  /// Number format for labels
  final String? labelFormat;

  /// Whether axis is visible
  final bool isVisible;

  const ChartAxisConfig({
    this.title,
    this.type = AxisType.numeric,
    this.minimum,
    this.maximum,
    this.interval,
    this.showGridLines = true,
    this.showAxisLine = true,
    this.labelFormat,
    this.isVisible = true,
  });
}

/// Axis type enumeration
enum AxisType {
  numeric,
  category,
  dateTime,
  dateTimeCategory,
  logarithmic,
}

/// Chart legend configuration
class ChartLegendConfig {
  /// Whether legend is visible
  final bool isVisible;

  /// Position of the legend
  final LegendPosition position;

  /// Whether legend items can toggle series visibility
  final bool toggleSeriesVisibility;

  /// Alignment of legend items
  final LegendAlignment alignment;

  const ChartLegendConfig({
    this.isVisible = true,
    this.position = LegendPosition.bottom,
    this.toggleSeriesVisibility = true,
    this.alignment = LegendAlignment.center,
  });
}

/// Legend position enumeration
enum LegendPosition {
  top,
  bottom,
  left,
  right,
}

/// Legend alignment enumeration
enum LegendAlignment {
  start,
  center,
  end,
}

/// Chart tooltip configuration
class ChartTooltipConfig {
  /// Whether tooltip is enabled
  final bool enable;

  /// Activation mode (tap, longPress, etc.)
  final TooltipActivationMode activationMode;

  /// Custom format for tooltip text
  final String? format;

  /// Whether to show marker in tooltip
  final bool showMarker;

  const ChartTooltipConfig({
    this.enable = true,
    this.activationMode = TooltipActivationMode.tap,
    this.format,
    this.showMarker = true,
  });
}

/// Tooltip activation mode enumeration
enum TooltipActivationMode {
  tap,
  longPress,
  doubleTap,
  none,
}

