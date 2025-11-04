/// Chart-related constants
class ChartConstants {
  ChartConstants._();

  /// Default chart height when not specified
  static const double defaultChartHeight = 300.0;

  /// Default chart width when not specified
  static const double defaultChartWidth = double.infinity;

  /// Default sparkline height
  static const double defaultSparklineHeight = 50.0;

  /// Default sparkline width
  static const double defaultSparklineWidth = 150.0;

  /// Default animation duration in milliseconds
  static const int defaultAnimationDuration = 1000;

  /// Default color palette (Material Design colors in hex)
  static const List<String> defaultPalette = [
    '#2196F3', // Blue
    '#4CAF50', // Green
    '#FF9800', // Orange
    '#F44336', // Red
    '#9C27B0', // Purple
    '#00BCD4', // Cyan
    '#FFEB3B', // Yellow
    '#795548', // Brown
    '#607D8B', // Blue Grey
    '#E91E63', // Pink
  ];

  /// Default chart background color
  static const String defaultBackgroundColor = '#FFFFFF';

  /// Default text color
  static const String defaultTextColor = '#000000';

  /// Default grid line color
  static const String defaultGridLineColor = '#E0E0E0';

  /// Default line width
  static const double defaultLineWidth = 2.0;

  /// Default marker size
  static const double defaultMarkerSize = 8.0;

  /// Default opacity
  static const double defaultOpacity = 1.0;

  /// Minimum opacity
  static const double minOpacity = 0.0;

  /// Maximum opacity
  static const double maxOpacity = 1.0;

  /// Default margin
  static const double defaultMargin = 10.0;

  /// Default label font size
  static const double defaultLabelFontSize = 12.0;

  /// Default title font size
  static const double defaultTitleFontSize = 16.0;
}
