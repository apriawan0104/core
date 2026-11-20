// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../contract/font_size_scale.enum.dart';

/// A wrapper widget for [ScreenUtilInit].
///
/// Example:
/// ```dart
/// void main() {
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
  /// - [fontSizeScale]: How font sizes scale (default: FontSizeScale.width)
  /// - [builder]: Builder function for the widget tree (required)
  /// - [child]: Optional child to pass through builder
  const AppScreenUtilInit({
    required this.builder,
    super.key,
    this.designSize = const Size(360, 690),
    this.minTextAdapt = false,
    this.splitScreenMode = false,
    this.useInheritedMediaQuery = false,
    this.fontSizeScale = FontSizeScale.width,
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

  /// When true, scale against the [MediaQuery] above this widget.
  ///
  /// The default reads the Flutter view, which is the full browser window on
  /// web. Pass true when an ancestor already constrains that query to a
  /// smaller frame.
  final bool useInheritedMediaQuery;

  /// How font sizes scale from the design draft to the current screen.
  ///
  /// Default is [FontSizeScale.width]. Other options: height, radius,
  /// diameter, diagonal.
  final FontSizeScale fontSizeScale;

  /// Builder function that returns the widget tree.
  ///
  // ignore: comment_references
  /// The [context] is provided after screen utility initialization.
  /// The [child] can be optionally passed through if provided.
  final Widget Function(BuildContext context, Widget? child)? builder;

  /// Optional child widget to pass through the builder.
  final Widget? child;

  FontSizeResolver get _fontSizeResolver => switch (fontSizeScale) {
    FontSizeScale.width => FontSizeResolvers.width,
    FontSizeScale.height => FontSizeResolvers.height,
    FontSizeScale.radius => FontSizeResolvers.radius,
    FontSizeScale.diameter => FontSizeResolvers.diameter,
    FontSizeScale.diagonal => FontSizeResolvers.diagonal,
  };

  @override
  Widget build(BuildContext context) {
    if (useInheritedMediaQuery) {
      ScreenUtil.configure(
        data: MediaQuery.of(context),
        designSize: designSize,
        minTextAdapt: minTextAdapt,
        splitScreenMode: splitScreenMode,
        fontSizeResolver: _fontSizeResolver,
      );
      return builder?.call(context, child) ?? child ?? const SizedBox.shrink();
    }

    return ScreenUtilInit(
      designSize: designSize,
      minTextAdapt: minTextAdapt,
      splitScreenMode: splitScreenMode,
      fontSizeResolver: _fontSizeResolver,
      builder: (context, child) {
        return builder?.call(context, child) ?? const SizedBox.shrink();
      },
      child: child,
    );
  }
}
