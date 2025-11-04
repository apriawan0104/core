import 'failures.dart';

/// Chart-related failure
///
/// Represents errors that occur during chart operations such as:
/// - Invalid chart configuration
/// - Unsupported chart type
/// - Chart rendering errors
/// - Data validation errors
class ChartFailure extends Failure {
  const ChartFailure({
    required super.message,
    super.code,
    super.details,
  });

  /// Factory for invalid configuration error
  factory ChartFailure.invalidConfiguration(String details) {
    return ChartFailure(
      message: 'Invalid chart configuration: $details',
      code: 'CHART_INVALID_CONFIG',
    );
  }

  /// Factory for unsupported chart type error
  factory ChartFailure.unsupportedChartType(String chartType) {
    return ChartFailure(
      message:
          'Chart type "$chartType" is not supported by this implementation',
      code: 'CHART_UNSUPPORTED_TYPE',
    );
  }

  /// Factory for empty data error
  factory ChartFailure.emptyData() {
    return const ChartFailure(
      message: 'Cannot build chart: data is empty',
      code: 'CHART_EMPTY_DATA',
    );
  }

  /// Factory for invalid data error
  factory ChartFailure.invalidData(String details) {
    return ChartFailure(
      message: 'Invalid chart data: $details',
      code: 'CHART_INVALID_DATA',
    );
  }

  /// Factory for rendering error
  factory ChartFailure.renderError(String details) {
    return ChartFailure(
      message: 'Failed to render chart: $details',
      code: 'CHART_RENDER_ERROR',
    );
  }
}
