# Chart Service Documentation

## Overview

The Chart service provides a generic, dependency-independent interface for rendering various types of charts in Flutter applications. It wraps third-party chart libraries (currently Syncfusion) to allow easy switching between implementations without changing consumer code.

## Architecture

Following **Dependency Independence** principle:

- **Contract**: Generic `ChartService` interface with no dependencies on specific chart libraries
- **Entities**: Pure Dart domain entities (`ChartConfig`, `ChartSeries`, `ChartDataPoint`) 
- **Implementation**: `SyncfusionChartServiceImpl` wraps Syncfusion Flutter Charts
- **Consumer Code**: Depends only on contracts, never on implementations

This architecture allows you to:
- ✅ Switch from Syncfusion to fl_chart, charts_flutter, or any other library with minimal effort
- ✅ Test with mock implementations
- ✅ Use different chart libraries in different apps
- ✅ Upgrade/change chart libraries without touching business logic

## Supported Chart Types

### Cartesian Charts
- Line, Spline
- Area, Spline Area, Step Area
- Column, Bar
- Scatter, Bubble
- Step Line
- Range Column, Range Area, Spline Range Area
- Candle, HILO, OHLC (for stock data)
- Stacked: Column, Bar, Area, Line (including 100% stacked)
- Histogram, Waterfall

### Circular Charts
- Pie
- Doughnut
- Radial Bar

### Other Charts
- Pyramid
- Funnel

### Sparkline Charts (Micro Charts)
- Line
- Area
- Bar
- Win-Loss

## Installation

### 1. Add Dependencies

Add to your app's `pubspec.yaml`:

```yaml
dependencies:
  # BUMA Core (already included)
  app_core:
    path: ../core  # or your path to core
  
  # Required for Syncfusion implementation
  syncfusion_flutter_charts: ^31.2.4
```

**Note**: Syncfusion is a commercial package. You need either:
- Syncfusion Commercial License (paid)
- Free Syncfusion Community License (free for qualifying projects)

See: https://www.syncfusion.com/sales/communitylicense

### 2. Register Service in DI

In your app's DI setup (usually `main.dart` or separate DI file):

```dart
import 'package:app_core/app_core.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // Register Chart Service
  getIt.registerLazySingleton<ChartService>(
    () => SyncfusionChartServiceImpl(),
  );
}
```

## Basic Usage

### 1. Simple Line Chart

```dart
import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';

class SalesChartWidget extends StatelessWidget {
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
            ChartDataPoint(x: 'Jan', y: 35),
            ChartDataPoint(x: 'Feb', y: 28),
            ChartDataPoint(x: 'Mar', y: 34),
            ChartDataPoint(x: 'Apr', y: 32),
            ChartDataPoint(x: 'May', y: 40),
          ],
          showDataLabels: true,
        ),
      ],
      primaryXAxis: ChartAxisConfig(
        type: AxisType.category,
        title: 'Month',
      ),
      primaryYAxis: ChartAxisConfig(
        type: AxisType.numeric,
        title: 'Sales (in thousands)',
      ),
      legendConfig: ChartLegendConfig(
        isVisible: true,
        position: LegendPosition.bottom,
      ),
      tooltipConfig: ChartTooltipConfig(
        enable: true,
        activationMode: TooltipActivationMode.tap,
      ),
    );
    
    final result = chartService.buildCartesianChart(config);
    
    return result.fold(
      (failure) => Center(child: Text('Error: ${failure.message}')),
      (chartWidget) => SizedBox(
        height: 300,
        child: chartWidget,
      ),
    );
  }
}
```

### 2. Multiple Series

```dart
final config = ChartConfig(
  title: 'Sales vs Revenue',
  series: [
    ChartSeries(
      name: 'Sales',
      type: ChartType.column,
      color: '#2196F3',
      dataPoints: [
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
      dataPoints: [
        ChartDataPoint(x: 'Q1', y: 40),
        ChartDataPoint(x: 'Q2', y: 35),
        ChartDataPoint(x: 'Q3', y: 38),
        ChartDataPoint(x: 'Q4', y: 42),
      ],
    ),
  ],
  legendConfig: ChartLegendConfig(isVisible: true),
);

final result = chartService.buildCartesianChart(config);
```

### 3. Pie Chart

```dart
final config = ChartConfig(
  title: 'Market Share',
  series: [
    ChartSeries(
      name: 'Share',
      type: ChartType.pie,
      dataPoints: [
        ChartDataPoint(x: 'Product A', y: 45),
        ChartDataPoint(x: 'Product B', y: 30),
        ChartDataPoint(x: 'Product C', y: 15),
        ChartDataPoint(x: 'Product D', y: 10),
      ],
      showDataLabels: true,
    ),
  ],
  legendConfig: ChartLegendConfig(
    isVisible: true,
    position: LegendPosition.right,
  ),
);

final result = chartService.buildCircularChart(config);
```

### 4. Sparkline Chart (Inline)

```dart
// Small chart for dashboards or inline with text
final result = chartService.buildSparkline(
  data: [1, 5, -6, 0, 1, -2, 7, -7, -4, -10, 13, -6, 7, 5, 11],
  type: SparklineType.line,
  width: 100,
  height: 30,
  color: '#2196F3',
  showTooltip: true,
);

// Use in Row with text
Row(
  children: [
    Text('Sales Trend: '),
    result.fold(
      (failure) => Icon(Icons.error, size: 16),
      (sparkWidget) => sparkWidget,
    ),
  ],
);
```

### 5. Stock Chart (Candle)

```dart
final config = ChartConfig(
  title: 'Stock Price',
  series: [
    ChartSeries(
      name: 'AAPL',
      type: ChartType.candle,
      dataPoints: [
        ChartDataPoint(
          x: DateTime(2024, 1, 1),
          open: 150,
          high: 155,
          low: 148,
          close: 153,
        ),
        ChartDataPoint(
          x: DateTime(2024, 1, 2),
          open: 153,
          high: 158,
          low: 151,
          close: 156,
        ),
        // ... more data
      ],
    ),
  ],
  primaryXAxis: ChartAxisConfig(
    type: AxisType.dateTime,
    title: 'Date',
  ),
  enableZoomPan: true,
);

final result = chartService.buildCartesianChart(config);
```

## Advanced Features

### Custom Colors

```dart
// Single series color
ChartSeries(
  name: 'Sales',
  type: ChartType.column,
  color: '#FF5722',  // Custom color
  dataPoints: [...],
)

// Per-data-point color
ChartDataPoint(
  x: 'Jan',
  y: 35,
  color: '#4CAF50',  // Green for positive
)

// Palette for multiple series
ChartConfig(
  series: [...],
  paletteColors: [
    '#2196F3',
    '#4CAF50',
    '#FF9800',
    '#F44336',
  ],
)
```

### Interactive Features

```dart
ChartConfig(
  series: [...],
  enableZoomPan: true,  // Enable zoom and pan
  enableSelection: true,  // Enable data point selection
  tooltipConfig: ChartTooltipConfig(
    enable: true,
    activationMode: TooltipActivationMode.tap,
    format: 'point.x : point.y',  // Custom tooltip format
  ),
)
```

### Axis Customization

```dart
ChartAxisConfig(
  type: AxisType.numeric,
  title: 'Revenue ($)',
  minimum: 0,
  maximum: 100,
  interval: 20,
  showGridLines: true,
  showAxisLine: true,
  labelFormat: '\${value}K',  // Format labels
)
```

### Legend Customization

```dart
ChartLegendConfig(
  isVisible: true,
  position: LegendPosition.bottom,  // top, bottom, left, right
  alignment: LegendAlignment.center,  // start, center, end
  toggleSeriesVisibility: true,  // Click legend to hide/show series
)
```

### Styling

```dart
ChartConfig(
  title: 'My Chart',
  backgroundColor: '#F5F5F5',
  margin: ChartMargin.all(20),
  // or
  margin: ChartMargin.symmetric(
    vertical: 10,
    horizontal: 20,
  ),
  series: [
    ChartSeries(
      name: 'Data',
      type: ChartType.line,
      lineWidth: 3,
      opacity: 0.8,
      dataPoints: [...],
    ),
  ],
)
```

## Error Handling

Always handle errors using Either pattern:

```dart
final result = chartService.buildCartesianChart(config);

result.fold(
  // Left: Handle failure
  (failure) {
    if (failure is ChartFailure) {
      print('Chart error: ${failure.message}');
      // Show error UI
      return ErrorWidget('Failed to load chart');
    }
    return ErrorWidget('Unknown error');
  },
  // Right: Use the widget
  (chartWidget) {
    return chartWidget;
  },
);
```

## Checking Support

Before building a chart, you can check if a type is supported:

```dart
final chartService = getIt<ChartService>();

if (chartService.supportsChartType(ChartType.waterfall)) {
  // Build waterfall chart
} else {
  // Use alternative chart type or show message
}

if (chartService.supportsSparklineType(SparklineType.winLoss)) {
  // Build win-loss sparkline
}
```

## Best Practices

### 1. Reusable Chart Widgets

Create reusable chart widgets for common patterns:

```dart
class SalesLineChart extends StatelessWidget {
  final List<SalesData> data;
  final String title;
  
  const SalesLineChart({
    required this.data,
    required this.title,
  });
  
  @override
  Widget build(BuildContext context) {
    final chartService = getIt<ChartService>();
    
    final config = ChartConfig(
      title: title,
      series: [
        ChartSeries(
          name: 'Sales',
          type: ChartType.line,
          dataPoints: data.map((d) => ChartDataPoint(
            x: d.month,
            y: d.amount,
          )).toList(),
        ),
      ],
      // ... other config
    );
    
    return chartService.buildCartesianChart(config).fold(
      (failure) => ErrorWidget(failure.message),
      (widget) => widget,
    );
  }
}
```

### 2. Responsive Charts

Use ResponsiveService to adjust chart for different screen sizes:

```dart
class ResponsiveChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final responsive = getIt<ResponsiveService>();
    
    return SizedBox(
      height: responsive.isMobile ? 200 : 300,
      child: // ... chart widget
    );
  }
}
```

### 3. Loading States

Handle loading states properly:

```dart
class ChartWithLoading extends StatelessWidget {
  final Future<List<ChartDataPoint>> dataFuture;
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        
        if (snapshot.hasError) {
          return Text('Error loading data');
        }
        
        final config = ChartConfig(
          series: [
            ChartSeries(
              name: 'Data',
              type: ChartType.line,
              dataPoints: snapshot.data!,
            ),
          ],
        );
        
        return getIt<ChartService>().buildCartesianChart(config).fold(
          (failure) => Text('Error: ${failure.message}'),
          (widget) => widget,
        );
      },
    );
  }
}
```

### 4. Theme Integration

Integrate with app theme:

```dart
Widget build(BuildContext context) {
  final theme = Theme.of(context);
  
  final config = ChartConfig(
    title: 'Sales',
    backgroundColor: theme.scaffoldBackgroundColor.toHex(),
    series: [
      ChartSeries(
        name: 'Data',
        type: ChartType.line,
        color: theme.primaryColor.toHex(),
        dataPoints: [...],
      ),
    ],
  );
  
  // ... build chart
}
```

## Switching Chart Libraries

To switch from Syncfusion to another library (e.g., fl_chart):

### 1. Create New Implementation

```dart
class FlChartServiceImpl implements ChartService {
  @override
  Either<Failure, Widget> buildCartesianChart(ChartConfig config) {
    // Convert ChartConfig to fl_chart widgets
    // Implementation using fl_chart package
  }
  
  // ... implement other methods
}
```

### 2. Update DI Registration

```dart
// Old:
// getIt.registerLazySingleton<ChartService>(
//   () => SyncfusionChartServiceImpl(),
// );

// New:
getIt.registerLazySingleton<ChartService>(
  () => FlChartServiceImpl(),
);
```

### 3. Update Dependencies

```yaml
dependencies:
  # Remove:
  # syncfusion_flutter_charts: ^31.2.4
  
  # Add:
  fl_chart: ^0.66.0
```

**That's it!** No changes needed in your app's business logic or UI code. ✅

## Testing

### Mock Implementation

```dart
class MockChartService extends Mock implements ChartService {}

void main() {
  late MockChartService mockChartService;
  
  setUp(() {
    mockChartService = MockChartService();
  });
  
  test('should build chart successfully', () {
    // Arrange
    final config = ChartConfig(/* ... */);
    when(() => mockChartService.buildCartesianChart(config))
        .thenReturn(Right(Container()));
    
    // Act
    final result = mockChartService.buildCartesianChart(config);
    
    // Assert
    expect(result.isRight(), true);
  });
}
```

## Troubleshooting

### "Chart type not supported"

Check if your implementation supports the chart type:

```dart
if (!chartService.supportsChartType(ChartType.waterfall)) {
  // Use alternative chart type
}
```

### "Empty data" error

Ensure your series has at least one data point:

```dart
if (dataPoints.isEmpty) {
  return Text('No data available');
}

final config = ChartConfig(
  series: [
    ChartSeries(
      name: 'Data',
      type: ChartType.line,
      dataPoints: dataPoints,  // Must not be empty
    ),
  ],
);
```

### Performance Issues

- Use appropriate chart types (e.g., `line` for many points instead of `scatter`)
- Limit data points for sparklines (recommended < 50 points)
- For real-time data, use `StreamBuilder` with debouncing

### Syncfusion License Error

If you see Syncfusion license warnings:

1. Get free Community License: https://www.syncfusion.com/sales/communitylicense
2. Register in your app startup:
   ```dart
   import 'package:syncfusion_flutter_core/core.dart';
   
   void main() {
     SyncfusionLicense.registerLicense('YOUR_LICENSE_KEY');
     runApp(MyApp());
   }
   ```

## Examples

See complete examples in: `/example/chart_example.dart`

## API Reference

For complete API documentation, see:
- `ChartService` - Main service interface
- `ChartConfig` - Chart configuration entity
- `ChartSeries` - Series configuration entity
- `ChartDataPoint` - Data point entity
- `ChartType` - Available chart types enum

## Support

For issues or questions:
- Check this documentation
- See examples in `/example` folder
- Check core library README
- Refer to Syncfusion documentation: https://help.syncfusion.com/flutter/cartesian-charts/overview

