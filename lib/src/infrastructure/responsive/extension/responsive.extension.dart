import 'package:flutter/widgets.dart';
import '../../../configuration/di/locator.dart';
import '../contract/contracts.dart';

/// Extension methods for convenient screen adaptation using numbers.
///
/// These extensions provide a more intuitive way to work with screen-adapted
/// dimensions, similar to the flutter_screenutil package's extension methods,
/// but using the abstracted ScreenUtilService through dependency injection.
///
/// Example usage:
/// ```dart
/// Container(
///   width: 100.w,    // Adapted width
///   height: 200.h,   // Adapted height
///   margin: EdgeInsets.all(16.r),  // Adapted radius
///   child: Text(
///     'Hello',
///     style: TextStyle(fontSize: 14.sp),  // Adapted font size
///   ),
/// )
/// ```
extension ScreenUtilExtension on num {
  /// Adapt width based on design size.
  ///
  /// Example: `100.w` returns width adapted for current screen.
  double get w => getIt<ResponsiveService>().setWidth(this);

  /// Adapt height based on design size.
  ///
  /// Example: `200.h` returns height adapted for current screen.
  double get h => getIt<ResponsiveService>().setHeight(this);

  /// Adapt size based on the smaller of width or height ratio.
  ///
  /// Useful for creating square elements or consistent border radius.
  /// Example: `50.r` returns size adapted based on minimum ratio.
  double get r => getIt<ResponsiveService>().radius(this);

  /// Adapt font size based on design size.
  ///
  /// Example: `14.sp` returns font size adapted for current screen.
  double get sp => getIt<ResponsiveService>().setSp(this);

  /// Returns the minimum of the number's sp value and the number itself.
  ///
  /// Useful for setting a maximum font size limit.
  /// Example: `14.sm` ensures font size won't exceed 14.
  double get sm {
    final spValue = sp;
    return spValue < this ? spValue : toDouble();
  }
}

/// Extension methods for screen percentage calculations.
extension ScreenPercentageExtension on num {
  /// Returns multiple of screen width.
  ///
  /// Example: `0.5.sw` returns 50% of screen width (0.5 * screenWidth).
  /// Example: `1.sw` returns full screen width.
  double get sw => this * getIt<ResponsiveService>().screenWidth;

  /// Returns multiple of screen height.
  ///
  /// Example: `0.5.sh` returns 50% of screen height (0.5 * screenHeight).
  /// Example: `1.sh` returns full screen height.
  double get sh => this * getIt<ResponsiveService>().screenHeight;
}

/// Extension methods for creating spacing widgets.
extension ScreenSpacingExtension on num {
  /// Creates a vertical spacing (SizedBox with height).
  ///
  /// Example: `20.verticalSpace` creates SizedBox(height: 20.h).
  Widget get verticalSpace => SizedBox(height: h);

  /// Creates a vertical spacing (SizedBox with height) - alias for verticalSpace.
  ///
  /// Example: `20.setVerticalSpacing` creates SizedBox(height: 20.h).
  Widget get setVerticalSpacing => SizedBox(height: h);

  /// Creates a horizontal spacing (SizedBox with width).
  ///
  /// Example: `10.horizontalSpace` creates SizedBox(width: 10.w).
  Widget get horizontalSpace => SizedBox(width: w);

  /// Creates a horizontal spacing (SizedBox with width) - alias for horizontalSpace.
  ///
  /// Example: `10.setHorizontalSpacing` creates SizedBox(width: 10.w).
  Widget get setHorizontalSpacing => SizedBox(width: w);
}

/// Extension methods for adapting EdgeInsets.
extension EdgeInsetsExtension on EdgeInsets {
  /// Adapts all EdgeInsets values using width ratio.
  ///
  /// Example: `EdgeInsets.all(16).w` adapts all edges using width ratio.
  EdgeInsets get w {
    final service = getIt<ResponsiveService>();
    return EdgeInsets.only(
      left: service.setWidth(left),
      top: service.setWidth(top),
      right: service.setWidth(right),
      bottom: service.setWidth(bottom),
    );
  }

  /// Adapts all EdgeInsets values using height ratio.
  ///
  /// Example: `EdgeInsets.symmetric(vertical: 20).h` adapts using height ratio.
  EdgeInsets get h {
    final service = getIt<ResponsiveService>();
    return EdgeInsets.only(
      left: service.setHeight(left),
      top: service.setHeight(top),
      right: service.setHeight(right),
      bottom: service.setHeight(bottom),
    );
  }

  /// Adapts all EdgeInsets values using radius (minimum ratio).
  ///
  /// Example: `EdgeInsets.all(12).r` adapts all edges using radius ratio.
  EdgeInsets get r {
    final service = getIt<ResponsiveService>();
    return EdgeInsets.only(
      left: service.radius(left),
      top: service.radius(top),
      right: service.radius(right),
      bottom: service.radius(bottom),
    );
  }
}

/// Extension methods for adapting BorderRadius.
extension BorderRadiusExtension on BorderRadius {
  /// Adapts all BorderRadius values using width ratio.
  ///
  /// Example: `BorderRadius.circular(8).w`.
  BorderRadius get w {
    final service = getIt<ResponsiveService>();
    return BorderRadius.only(
      topLeft: Radius.circular(service.setWidth(topLeft.x)),
      topRight: Radius.circular(service.setWidth(topRight.x)),
      bottomLeft: Radius.circular(service.setWidth(bottomLeft.x)),
      bottomRight: Radius.circular(service.setWidth(bottomRight.x)),
    );
  }

  /// Adapts all BorderRadius values using height ratio.
  ///
  /// Example: `BorderRadius.circular(8).h`.
  BorderRadius get h {
    final service = getIt<ResponsiveService>();
    return BorderRadius.only(
      topLeft: Radius.circular(service.setHeight(topLeft.x)),
      topRight: Radius.circular(service.setHeight(topRight.x)),
      bottomLeft: Radius.circular(service.setHeight(bottomLeft.x)),
      bottomRight: Radius.circular(service.setHeight(bottomRight.x)),
    );
  }

  /// Adapts all BorderRadius values using radius (minimum ratio).
  ///
  /// Example: `BorderRadius.circular(8).r`.
  BorderRadius get r {
    final service = getIt<ResponsiveService>();
    return BorderRadius.only(
      topLeft: Radius.circular(service.radius(topLeft.x)),
      topRight: Radius.circular(service.radius(topRight.x)),
      bottomLeft: Radius.circular(service.radius(bottomLeft.x)),
      bottomRight: Radius.circular(service.radius(bottomRight.x)),
    );
  }
}

/// Extension methods for adapting Radius.
extension RadiusExtension on Radius {
  /// Adapts Radius value using width ratio.
  ///
  /// Example: `Radius.circular(16).w`.
  Radius get w => Radius.circular(getIt<ResponsiveService>().setWidth(x));

  /// Adapts Radius value using height ratio.
  ///
  /// Example: `Radius.circular(16).h`.
  Radius get h => Radius.circular(getIt<ResponsiveService>().setHeight(x));

  /// Adapts Radius value using radius (minimum ratio).
  ///
  /// Example: `Radius.circular(16).r`.
  Radius get r => Radius.circular(getIt<ResponsiveService>().radius(x));
}

/// Extension methods for adapting BoxConstraints.
extension BoxConstraintsExtension on BoxConstraints {
  /// Adapts all BoxConstraints values using width ratio.
  ///
  /// Example: `BoxConstraints(maxWidth: 200, minHeight: 100).w`.
  BoxConstraints get w {
    final service = getIt<ResponsiveService>();
    return BoxConstraints(
      minWidth: service.setWidth(minWidth),
      maxWidth: service.setWidth(maxWidth),
      minHeight: service.setWidth(minHeight),
      maxHeight: service.setWidth(maxHeight),
    );
  }

  /// Adapts all BoxConstraints values using height ratio.
  ///
  /// Example: `BoxConstraints(maxWidth: 200, minHeight: 100).h`.
  BoxConstraints get h {
    final service = getIt<ResponsiveService>();
    return BoxConstraints(
      minWidth: service.setHeight(minWidth),
      maxWidth: service.setHeight(maxWidth),
      minHeight: service.setHeight(minHeight),
      maxHeight: service.setHeight(maxHeight),
    );
  }

  /// Adapts all BoxConstraints values using radius (minimum ratio).
  ///
  /// Example: `BoxConstraints(maxWidth: 200, minHeight: 100).r`.
  BoxConstraints get r {
    final service = getIt<ResponsiveService>();
    return BoxConstraints(
      minWidth: service.radius(minWidth),
      maxWidth: service.radius(maxWidth),
      minHeight: service.radius(minHeight),
      maxHeight: service.radius(maxHeight),
    );
  }
}

/// Responsive EdgeInsets with const constructor support.
///
/// Similar to flutter_screenutil's REdgeInsets, but uses our DIP service.
/// Use this class when you need compile-time const EdgeInsets that will be
/// adapted at runtime.
///
/// Example:
/// ```dart
/// const Padding(
///   padding: REdgeInsets.all(8),
///   child: Text('Hello'),
/// )
/// ```
class REdgeInsets extends EdgeInsets {
  /// Creates responsive EdgeInsets with all sides equal.
  const REdgeInsets.all(double value)
      : super.fromLTRB(value, value, value, value);

  /// Creates responsive EdgeInsets with symmetric values.
  const REdgeInsets.symmetric({
    double vertical = 0.0,
    double horizontal = 0.0,
  }) : super.fromLTRB(horizontal, vertical, horizontal, vertical);

  /// Creates responsive EdgeInsets with only specific sides.
  const REdgeInsets.only({
    double left = 0.0,
    double top = 0.0,
    double right = 0.0,
    double bottom = 0.0,
  }) : super.fromLTRB(left, top, right, bottom);

  /// Creates responsive EdgeInsets from LTRB values.
  const REdgeInsets.fromLTRB(
    super.left,
    super.top,
    super.right,
    super.bottom,
  ) : super.fromLTRB();

  /// Adapts all values using radius ratio.
  EdgeInsets get r {
    final service = getIt<ResponsiveService>();
    return EdgeInsets.fromLTRB(
      service.radius(left),
      service.radius(top),
      service.radius(right),
      service.radius(bottom),
    );
  }

  /// Adapts all values using width ratio.
  EdgeInsets get w {
    final service = getIt<ResponsiveService>();
    return EdgeInsets.fromLTRB(
      service.setWidth(left),
      service.setWidth(top),
      service.setWidth(right),
      service.setWidth(bottom),
    );
  }

  /// Adapts all values using height ratio.
  EdgeInsets get h {
    final service = getIt<ResponsiveService>();
    return EdgeInsets.fromLTRB(
      service.setHeight(left),
      service.setHeight(top),
      service.setHeight(right),
      service.setHeight(bottom),
    );
  }
}

/// Responsive Padding widget with const constructor support.
///
/// Similar to flutter_screenutil's RPadding, but uses our DIP service.
/// This allows using const keyword for better performance.
///
/// Example:
/// ```dart
/// const RPadding.all(8, child: Text('Hello'))
/// ```
class RPadding extends Padding {
  /// Creates responsive Padding with all sides equal.
  RPadding.all(
    double value, {
    required super.child,
    super.key,
  }) : super(padding: REdgeInsets.all(value).r);

  /// Creates responsive Padding with symmetric values.
  RPadding.symmetric({
    required super.child,
    super.key,
    double vertical = 0.0,
    double horizontal = 0.0,
  }) : super(
          padding: REdgeInsets.symmetric(
            vertical: vertical,
            horizontal: horizontal,
          ).r,
        );

  /// Creates responsive Padding with only specific sides.
  RPadding.only({
    required super.child,
    super.key,
    double left = 0.0,
    double top = 0.0,
    double right = 0.0,
    double bottom = 0.0,
  }) : super(
          padding: REdgeInsets.only(
            left: left,
            top: top,
            right: right,
            bottom: bottom,
          ).r,
        );

  /// Creates responsive Padding from LTRB values.
  RPadding.fromLTRB(
    double left,
    double top,
    double right,
    double bottom, {
    required super.child,
    super.key,
  }) : super(
          padding: REdgeInsets.fromLTRB(left, top, right, bottom).r,
        );
}
