import 'package:flutter/widgets.dart';

/// Abstract service for screen utility and responsive design.
///
/// This service provides a contract for adapting screen dimensions and font sizes
/// across different device screen sizes, following the Dependency Inversion Principle.
///
/// By depending on this abstraction rather than a concrete implementation,
/// the application code remains decoupled from the specific screen utility library.
abstract class ResponsiveService {
  /// Initialize the screen utility with the design size.
  ///
  /// [designSize] - The size of the device screen in the design draft (in dp).
  /// [minTextAdapt] - Whether to adapt text according to minimum of width and height.
  /// [splitScreenMode] - Support for split screen.
  void init(
    BuildContext context, {
    Size designSize = const Size(360, 690),
    bool minTextAdapt = false,
    bool splitScreenMode = false,
  });

  /// Convert design width (dp) to adapted screen width.
  ///
  /// [width] - Width value from design draft.
  /// Returns the adapted width value for current screen.
  double setWidth(num width);

  /// Convert design height (dp) to adapted screen height.
  ///
  /// [height] - Height value from design draft.
  /// Returns the adapted height value for current screen.
  double setHeight(num height);

  /// Adapt size according to the smaller of width or height.
  ///
  /// [size] - Size value from design draft.
  /// Returns the adapted size value based on minimum of width/height ratio.
  double radius(num size);

  /// Convert design font size to adapted screen font size.
  ///
  /// [fontSize] - Font size value from design draft.
  /// Returns the adapted font size for current screen.
  double setSp(num fontSize);

  /// Get the device's pixel density.
  double get pixelRatio;

  /// Get the device's screen width (in pixels).
  double get screenWidth;

  /// Get the device's screen height (in pixels).
  double get screenHeight;

  /// Get the bottom safe area height (for navigation bars, etc.).
  double get bottomBarHeight;

  /// Get the status bar height (notch area included).
  double get statusBarHeight;

  /// Get the system font scaling factor.
  double get textScaleFactor;

  /// Get the ratio of actual width to UI design width.
  double get scaleWidth;

  /// Get the ratio of actual height to UI design height.
  double get scaleHeight;

  /// Get the current screen orientation.
  Orientation get orientation;
}
