# Chart Service - Quick Start Guide

Get started with charts in your Flutter app in 5 minutes.

## 📦 Step 1: Install Dependencies

Add to your app's `pubspec.yaml`:

```yaml
dependencies:
  app_core:
    path: ../core  # Path to BUMA Core library
  
  # Required for Syncfusion implementation
  syncfusion_flutter_charts: ^31.2.4
```

Run:
```bash
flutter pub get
```

## 🔧 Step 2: Register Syncfusion License (Optional but Recommended)

Get a free Community License: https://www.syncfusion.com/sales/communitylicense

In your `main.dart`:

```dart
import 'package:syncfusion_flutter_core/core.dart';

void main() {
  // Register Syncfusion license (prevents watermark)
  SyncfusionLicense.registerLicense('YOUR_LICENSE_KEY_HERE');
  
  runApp(MyApp());
}
```

## 🎯 Step 3: Register Chart Service

In your DI setup (e.g., `main.dart`):

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

void main() {
  setupDependencies();
  runApp(MyApp());
}
```

## 📊 Step 4: Use Chart Service

### Example 1: Simple Line Chart

```dart
import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';

class MyChartWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final chartService = getIt<ChartService>();
    
    // Create chart configuration
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
        ),
      ],
      legendConfig: ChartLegendConfig(isVisible: true),
      tooltipConfig: ChartTooltipConfig(enable: true),
    );
    
    // Build chart
    final result = chartService.buildCartesianChart(config);
    
    // Handle result
    return result.fold(
      (failure) => Text('Error: ${failure.message}'),
      (chartWidget) => SizedBox(
        height: 300,
        child: chartWidget,
      ),
    );
  }
}
```

### Example 2: Pie Chart

```dart
final config = ChartConfig(
  title: 'Market Share',
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

### Example 3: Sparkline (Micro Chart)

```dart
final result = chartService.buildSparkline(
  data: [1, 5, -6, 0, 1, -2, 7, -7, -4],
  type: SparklineType.line,
  width: 100,
  height: 30,
  color: '#2196F3',
);
```

## 🎨 Step 5: Customize Your Charts

### Add Colors

```dart
ChartSeries(
  name: 'Sales',
  type: ChartType.column,
  color: '#4CAF50',  // Custom color
  dataPoints: [...],
)
```

### Enable Interactions

```dart
ChartConfig(
  series: [...],
  enableZoomPan: true,     // Enable zoom and pan
  tooltipConfig: ChartTooltipConfig(
    enable: true,
    activationMode: TooltipActivationMode.tap,
  ),
)
```

### Multiple Series

```dart
ChartConfig(
  title: 'Sales vs Revenue',
  series: [
    ChartSeries(
      name: 'Sales',
      type: ChartType.column,
      color: '#2196F3',
      dataPoints: [...],
    ),
    ChartSeries(
      name: 'Revenue',
      type: ChartType.line,
      color: '#4CAF50',
      dataPoints: [...],
    ),
  ],
)
```

## ✅ You're Done!

Your app now has powerful charting capabilities. 

### Next Steps:

- 📖 Read full [documentation](README.md)
- 👀 Check [examples](../../../../example/chart_example.dart)
- 🎨 Explore different [chart types](README.md#supported-chart-types)
- 🔄 Learn about [switching chart libraries](README.md#switching-chart-libraries)

## 🆘 Need Help?

**Common Issues:**

1. **"Target of URI doesn't exist" error**
   - Make sure you ran `flutter pub get`
   - Check if `syncfusion_flutter_charts` is in your `pubspec.yaml`

2. **Syncfusion watermark appears**
   - Register your Syncfusion license key (see Step 2)

3. **Chart doesn't show**
   - Wrap chart widget in `SizedBox` with explicit height
   - Check if data is not empty

4. **Type error when using chart**
   - Make sure you imported `app_core` package
   - Use `const` for data points if possible

## 🔗 Useful Links

- [Full Documentation](README.md)
- [Syncfusion Charts Documentation](https://help.syncfusion.com/flutter/cartesian-charts/overview)
- [Get Free License](https://www.syncfusion.com/sales/communitylicense)
- [BUMA Core README](../../../../README.md)

