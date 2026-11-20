import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Default test surface is 800 x 600 logical pixels.
  const designSize = Size(360, 690);
  const screenWidth = 800.0;
  const screenHeight = 600.0;

  Future<double> resolveSp(WidgetTester tester, FontSizeScale scale) async {
    double? resolved;
    await tester.pumpWidget(
      AppScreenUtilInit(
        designSize: designSize,
        fontSizeScale: scale,
        builder: (context, _) {
          resolved = 12.sp;
          return const SizedBox();
        },
      ),
    );
    return resolved!;
  }

  testWidgets('width scale is the default', (tester) async {
    final value = await resolveSp(tester, FontSizeScale.width);
    expect(value, closeTo(12 * screenWidth / designSize.width, 0.01));
  });

  testWidgets('height scale uses the height ratio', (tester) async {
    final value = await resolveSp(tester, FontSizeScale.height);
    expect(value, closeTo(12 * screenHeight / designSize.height, 0.01));
  });
}
