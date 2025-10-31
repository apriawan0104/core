// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../configuration/di/locator.dart';
import '../contract/contracts.dart';

/// A wrapper widget for ScreenUtilInit that follows Dependency Inversion Principle.
///
/// This widget initializes the screen utility service through dependency injection
/// instead of directly depending on the concrete ScreenUtilInit from flutter_screenutil.
///
/// The widget uses [ScreenUtilService] from the DI container (GetIt) to initialize
/// screen adaptation, maintaining loose coupling and following clean architecture principles.
///
/// Example:
/// ```dart
/// void main() {
///   configureDependencies(); // Setup DI
///   runApp(
///     AppScreenUtilInit(
///       designSize: const Size(360, 690),
///       minTextAdapt: true,
///       splitScreenMode: true,
///       builder: (context, child) => MyApp(),
///     ),
///   );
/// }
/// ```
class AppScreenUtilInit extends StatelessWidget {
  /// Creates an [AppScreenUtilInit] widget.
  ///
  /// Parameters:
  /// - [designSize]: Size of the design draft (default: Size(360, 690))
  /// - [minTextAdapt]: Adapt text by minimum dimension (default: false)
  /// - [splitScreenMode]: Support split screen (default: false)
  /// - [fontSizeResolver]: Function to resolve font size (default: FontSizeResolvers.width)
  /// - [builder]: Builder function for the widget tree (required)
  /// - [child]: Optional child to pass through builder
  const AppScreenUtilInit({
    required this.builder,
    super.key,
    this.designSize = const Size(360, 690),
    this.minTextAdapt = false,
    this.splitScreenMode = false,
    this.fontSizeResolver = FontSizeResolvers.width,
    this.child,
  });

  /// The design size of the UI design draft.
  ///
  /// This should match the dimensions used in your design mockups (in dp).
  /// Default is Size(360, 690).
  final Size designSize;

  /// Whether to adapt text according to the minimum of width and height.
  ///
  /// If true, text will scale based on the smaller dimension ratio.
  /// Default is false.
  final bool minTextAdapt;

  /// Whether to support split screen mode.
  ///
  /// If true, the widget will recalculate dimensions when in split screen.
  /// Default is false.
  final bool splitScreenMode;

  /// Function to resolve font sizes.
  ///
  /// This determines how font sizes are calculated during adaptation.
  /// Default is FontSizeResolvers.width which scales based on width.
  /// Other options include: height, radius, diameter, diagonal.
  final FontSizeResolver fontSizeResolver;

  /// Builder function that returns the widget tree.
  ///
  // ignore: comment_references
  /// The [context] is provided after screen utility initialization.
  /// The [child] can be optionally passed through if provided.
  final Widget Function(BuildContext context, Widget? child)? builder;

  /// Optional child widget to pass through the builder.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    // Use ScreenUtilInit from flutter_screenutil but wrapped with our abstraction
    return ScreenUtilInit(
      designSize: designSize,
      minTextAdapt: minTextAdapt,
      splitScreenMode: splitScreenMode,
      fontSizeResolver: fontSizeResolver,
      builder: (context, child) {
        // Initialize our service through DI
        // This ensures our abstraction is also initialized
        getIt<ResponsiveService>().init(
          context,
          designSize: designSize,
          minTextAdapt: minTextAdapt,
          splitScreenMode: splitScreenMode,
        );

        // Call the provided builder
        return builder?.call(context, child) ?? const SizedBox.shrink();
      },
      child: child,
    );
  }
}
