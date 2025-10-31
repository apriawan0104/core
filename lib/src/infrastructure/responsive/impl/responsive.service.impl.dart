import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:injectable/injectable.dart';

import '../contract/contracts.dart';

/// Concrete implementation of [ScreenUtilService] using flutter_screenutil library.
///
/// This implementation wraps the flutter_screenutil package, providing
/// screen adaptation functionality while maintaining loose coupling through
/// the abstract service interface.
@LazySingleton(as: ResponsiveService)
class ResponsiveServiceImpl implements ResponsiveService {
  @override
  void init(
    BuildContext context, {
    Size designSize = const Size(360, 690),
    bool minTextAdapt = false,
    bool splitScreenMode = false,
  }) {
    ScreenUtil.init(
      context,
      designSize: designSize,
      minTextAdapt: minTextAdapt,
      splitScreenMode: splitScreenMode,
    );
  }

  @override
  double setWidth(num width) => ScreenUtil().setWidth(width);

  @override
  double setHeight(num height) => ScreenUtil().setHeight(height);

  @override
  double radius(num size) => ScreenUtil().radius(size);

  @override
  double setSp(num fontSize) => ScreenUtil().setSp(fontSize);

  @override
  double get pixelRatio => ScreenUtil().pixelRatio ?? 1.0;

  @override
  double get screenWidth => ScreenUtil().screenWidth;

  @override
  double get screenHeight => ScreenUtil().screenHeight;

  @override
  double get bottomBarHeight => ScreenUtil().bottomBarHeight;

  @override
  double get statusBarHeight => ScreenUtil().statusBarHeight;

  @override
  double get textScaleFactor => ScreenUtil().textScaleFactor;

  @override
  double get scaleWidth => ScreenUtil().scaleWidth;

  @override
  double get scaleHeight => ScreenUtil().scaleHeight;

  @override
  Orientation get orientation => ScreenUtil().orientation;
}
