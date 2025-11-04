/// Chart infrastructure barrel file
/// 
/// Provides chart rendering services with support for multiple chart types
/// including cartesian, circular, pyramid, funnel, and sparkline charts.
/// 
/// This module follows Dependency Independence principle - all third-party
/// chart libraries are wrapped with generic interfaces, making it easy to
/// switch implementations without changing consumer code.
/// 
/// ## Quick Start
/// 
/// ```dart
/// // 1. Register service in DI
/// getIt.registerLazySingleton<ChartService>(
///   () => SyncfusionChartServiceImpl(),
/// );
/// 
/// // 2. Use in your app
/// final chartService = getIt<ChartService>();
/// 
/// final config = ChartConfig(
///   title: 'Sales Report',
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
/// 
/// ## Supported Chart Types
/// 
/// - **Cartesian**: line, spline, area, column, bar, scatter, bubble, etc.
/// - **Circular**: pie, doughnut, radial bar
/// - **Pyramid & Funnel**: pyramid, funnel
/// - **Sparkline**: line, area, bar, win-loss (micro charts)
/// 
/// See documentation in `/doc` folder for more details.
library chart;

export 'constants/constants.dart';
export 'contract/contracts.dart';
export 'impl/impl.dart';

