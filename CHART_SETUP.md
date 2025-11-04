# Chart Service Setup Guide

Complete setup guide for adding chart visualization capabilities to your Flutter app using BUMA Core.

## Overview

The Chart Service provides a generic, dependency-independent interface for rendering various types of charts. It currently wraps Syncfusion Flutter Charts but can be easily switched to other chart libraries (fl_chart, charts_flutter, etc.) without changing your app code.

## Prerequisites

- Flutter SDK installed
- BUMA Core library added to your project
- Basic understanding of dependency injection (GetIt)

## Installation Steps

### 1. Add Dependencies

Add to your app's `pubspec.yaml`:

```yaml
dependencies:
  # BUMA Core
  app_core:
    path: ../core  # Adjust path to your core library location
  
  # Chart library (Syncfusion implementation)
  syncfusion_flutter_charts: ^31.2.4
  
  # Dependency injection (if not already added)
  get_it: ^7.6.0
  
  # Functional programming (included with app_core)
  dartz: ^0.10.1
```

### 2. Install Packages

Run in your terminal:

```bash
flutter pub get
```

### 3. Register Syncfusion License (Recommended)

Syncfusion is a commercial package. To remove the license watermark:

**Option A: Get Free Community License** (Recommended for qualifying projects)
1. Visit: https://www.syncfusion.com/sales/communitylicense
2. Apply for Community License (free for individuals and small businesses)
3. Register the license key in your app

**Option B: Purchase Commercial License**
- Visit: https://www.syncfusion.com/sales/products

**Register License in App:**

In your `main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_core/core.dart';
import 'package:get_it/get_it.dart';
import 'package:app_core/app_core.dart';

void main() {
  // Register Syncfusion license (prevents watermark)
  SyncfusionLicense.registerLicense('YOUR_LICENSE_KEY_HERE');
  
  // Setup dependencies
  setupDependencies();
  
  // Run app
  runApp(MyApp());
}
```

### 4. Register Chart Service in DI Container

**Important**: Chart Service is NOT auto-registered by BUMA Core. This gives your app flexibility to include it only when needed.

In your DI setup file (e.g., `lib/config/dependencies.dart` or in `main.dart`):

```dart
import 'package:get_it/get_it.dart';
import 'package:app_core/app_core.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // Register Chart Service
  getIt.registerLazySingleton<ChartService>(
    () => SyncfusionChartServiceImpl(),
  );
  
  // ... register other services
}
```

**Alternative: Using Injectable (if your project uses it)**

```dart
import 'package:injectable/injectable.dart';
import 'package:app_core/app_core.dart';

@module
abstract class ChartModule {
  @lazySingleton
  ChartService get chartService => SyncfusionChartServiceImpl();
}
```

### 5. Verify Setup

Create a test widget to verify everything works:

```dart
import 'package:flutter/material.dart';
import 'package:app_core/app_core.dart';
import 'package:get_it/get_it.dart';

class ChartTestWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final chartService = GetIt.instance<ChartService>();
    
    final config = ChartConfig(
      title: 'Test Chart',
      series: [
        ChartSeries(
          name: 'Test Data',
          type: ChartType.line,
          dataPoints: [
            ChartDataPoint(x: 'A', y: 10),
            ChartDataPoint(x: 'B', y: 20),
            ChartDataPoint(x: 'C', y: 15),
          ],
        ),
      ],
    );
    
    final result = chartService.buildCartesianChart(config);
    
    return Scaffold(
      appBar: AppBar(title: Text('Chart Test')),
      body: Center(
        child: result.fold(
          (failure) => Text('Error: ${failure.message}'),
          (chartWidget) => SizedBox(
            height: 300,
            child: chartWidget,
          ),
        ),
      ),
    );
  }
}
```

If you see a chart without errors, setup is successful! ✅

## Usage Examples

### Basic Line Chart

```dart
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
    title: 'Sales',
  ),
  legendConfig: ChartLegendConfig(isVisible: true),
  tooltipConfig: ChartTooltipConfig(enable: true),
);

final result = chartService.buildCartesianChart(config);
```

### Pie Chart

```dart
final config = ChartConfig(
  title: 'Product Distribution',
  series: [
    ChartSeries(
      name: 'Products',
      type: ChartType.pie,
      dataPoints: [
        ChartDataPoint(x: 'Product A', y: 45),
        ChartDataPoint(x: 'Product B', y: 30),
        ChartDataPoint(x: 'Product C', y: 25),
      ],
      showDataLabels: true,
    ),
  ],
);

final result = chartService.buildCircularChart(config);
```

### Sparkline (Micro Chart)

```dart
final result = chartService.buildSparkline(
  data: [1, 5, -6, 0, 1, -2, 7],
  type: SparklineType.line,
  width: 100,
  height: 30,
  color: '#2196F3',
);

// Use inline with text
Row(
  children: [
    Text('Trend: '),
    result.fold(
      (failure) => Icon(Icons.error, size: 16),
      (widget) => widget,
    ),
  ],
)
```

### Multiple Series Chart

```dart
final config = ChartConfig(
  title: 'Sales vs Target',
  series: [
    ChartSeries(
      name: 'Actual',
      type: ChartType.column,
      color: '#2196F3',
      dataPoints: [
        ChartDataPoint(x: 'Q1', y: 35),
        ChartDataPoint(x: 'Q2', y: 42),
        ChartDataPoint(x: 'Q3', y: 38),
      ],
    ),
    ChartSeries(
      name: 'Target',
      type: ChartType.line,
      color: '#4CAF50',
      lineWidth: 3,
      dataPoints: [
        ChartDataPoint(x: 'Q1', y: 40),
        ChartDataPoint(x: 'Q2', y: 40),
        ChartDataPoint(x: 'Q3', y: 40),
      ],
    ),
  ],
  enableZoomPan: true,
);
```

## Supported Chart Types

### Cartesian Charts
- Line, Spline, Step Line
- Area, Spline Area, Step Area
- Column, Bar
- Scatter, Bubble
- Range Column, Range Area
- Candle, HILO, OHLC (stock charts)
- Stacked: Column, Bar, Area, Line
- Histogram, Waterfall

### Circular Charts
- Pie
- Doughnut
- Radial Bar

### Other Charts
- Pyramid
- Funnel

### Sparkline Charts
- Line, Area, Bar, Win-Loss

## Best Practices

### 1. Create Reusable Chart Widgets

```dart
class SalesChart extends StatelessWidget {
  final List<SalesData> data;
  
  const SalesChart({required this.data});
  
  @override
  Widget build(BuildContext context) {
    final chartService = getIt<ChartService>();
    
    final config = ChartConfig(
      series: [
        ChartSeries(
          name: 'Sales',
          type: ChartType.line,
          dataPoints: data.map((d) => 
            ChartDataPoint(x: d.month, y: d.amount)
          ).toList(),
        ),
      ],
    );
    
    return chartService.buildCartesianChart(config).fold(
      (failure) => ErrorWidget(failure.message),
      (widget) => widget,
    );
  }
}
```

### 2. Always Handle Errors

```dart
final result = chartService.buildCartesianChart(config);

return result.fold(
  // Handle failure
  (failure) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error, color: Colors.red),
        Text('Failed to load chart: ${failure.message}'),
      ],
    ),
  ),
  // Use chart widget
  (chartWidget) => chartWidget,
);
```

### 3. Wrap Charts with Size Constraints

```dart
// Charts need explicit height
SizedBox(
  height: 300,
  child: chartWidget,
)

// Or use Expanded in Column/Row
Expanded(
  child: chartWidget,
)
```

### 4. Use Const for Static Data

```dart
const ChartDataPoint(x: 'Jan', y: 35)  // Const when possible
```

### 5. Load Data Asynchronously

```dart
class ChartWithData extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SalesData>>(
      future: fetchSalesData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        
        if (snapshot.hasError) {
          return Text('Error loading data');
        }
        
        // Build chart with loaded data
        final config = ChartConfig(...);
        return chartService.buildCartesianChart(config).fold(
          (failure) => Text('Error: ${failure.message}'),
          (widget) => widget,
        );
      },
    );
  }
}
```

## Troubleshooting

### Issue: "Target of URI doesn't exist" error

**Solution:**
- Run `flutter pub get`
- Check if `syncfusion_flutter_charts` is in your `pubspec.yaml`
- Clean and rebuild: `flutter clean && flutter pub get`

### Issue: Syncfusion watermark appears on charts

**Solution:**
- Register Syncfusion license key (see Step 3)
- Apply for free Community License if you qualify

### Issue: Chart doesn't show / blank screen

**Solutions:**
- Wrap chart widget in `SizedBox` with explicit height
- Check if `dataPoints` list is not empty
- Check for errors using `.fold()` error handler
- Verify DI registration is correct

### Issue: "ChartService is not registered" error

**Solution:**
- Make sure you called `setupDependencies()` before using chart
- Verify registration code:
  ```dart
  getIt.registerLazySingleton<ChartService>(
    () => SyncfusionChartServiceImpl(),
  );
  ```

### Issue: Type errors when creating chart config

**Solution:**
- Import app_core: `import 'package:app_core/app_core.dart';`
- Use correct types: `ChartType.line` not `'line'`
- Use `const` for compile-time constants

### Issue: Chart is too small / too large

**Solution:**
- Adjust height in `SizedBox`:
  ```dart
  SizedBox(
    height: 300,  // Adjust this value
    child: chartWidget,
  )
  ```
- Use `margin` parameter in `ChartConfig`:
  ```dart
  ChartConfig(
    margin: ChartMargin.all(20),
    // ...
  )
  ```

### Issue: Chart crashes on hot reload

**Solution:**
- This is a known Flutter issue with some chart libraries
- Use hot restart instead of hot reload
- Or wrap chart in a `StatefulWidget` with proper lifecycle management

## Advanced Topics

### Switching to Different Chart Library

Want to use fl_chart instead of Syncfusion? Easy!

1. Create new implementation:
   ```dart
   class FlChartServiceImpl implements ChartService {
     // Implement methods using fl_chart
   }
   ```

2. Update DI registration:
   ```dart
   getIt.registerLazySingleton<ChartService>(
     () => FlChartServiceImpl(),  // Changed this line
   );
   ```

3. Update dependencies:
   ```yaml
   # Remove syncfusion_flutter_charts
   # Add fl_chart
   ```

**All your app code stays the same!** That's the power of dependency independence. ✨

### Testing Charts

Mock the chart service in tests:

```dart
class MockChartService extends Mock implements ChartService {}

void main() {
  test('should build chart', () {
    final mockChart = MockChartService();
    when(() => mockChart.buildCartesianChart(any()))
        .thenReturn(Right(Container()));
    
    // Test your widget
  });
}
```

### Custom Chart Configurations

Create configuration presets:

```dart
class ChartPresets {
  static ChartConfig salesLineChart(List<ChartDataPoint> data) {
    return ChartConfig(
      title: 'Sales Report',
      series: [
        ChartSeries(
          name: 'Sales',
          type: ChartType.line,
          dataPoints: data,
          color: '#2196F3',
        ),
      ],
      primaryXAxis: ChartAxisConfig(type: AxisType.category),
      primaryYAxis: ChartAxisConfig(type: AxisType.numeric),
      legendConfig: ChartLegendConfig(isVisible: true),
      tooltipConfig: ChartTooltipConfig(enable: true),
    );
  }
}

// Use preset
final config = ChartPresets.salesLineChart(myData);
```

## Additional Resources

- 📖 [Full Documentation](lib/src/infrastructure/chart/doc/README.md)
- 🚀 [Quick Start Guide](lib/src/infrastructure/chart/doc/QUICK_START.md)
- 💻 [Complete Examples](example/chart_example.dart)
- 🔗 [Syncfusion Documentation](https://help.syncfusion.com/flutter/cartesian-charts/overview)
- 🆓 [Get Free Syncfusion License](https://www.syncfusion.com/sales/communitylicense)
- 📦 [pub.dev - syncfusion_flutter_charts](https://pub.dev/packages/syncfusion_flutter_charts)

## Need Help?

1. Check this setup guide
2. Read the [full documentation](lib/src/infrastructure/chart/doc/README.md)
3. Look at [examples](example/chart_example.dart)
4. Check BUMA Core [project guidelines](PROJECT_GUIDELINES.md)
5. Review BUMA Core [architecture](ARCHITECTURE.md)

---

**Ready to create beautiful charts!** 📊✨

For more information about BUMA Core architecture and principles, see:
- [ARCHITECTURE.md](ARCHITECTURE.md)
- [README.md](README.md)
- [PROJECT_GUIDELINES.md](PROJECT_GUIDELINES.md) (Dependency Independence)

