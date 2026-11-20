/// How font sizes scale from the design draft to the current screen.
///
/// Used by `AppScreenUtilInit.fontSizeScale` and `.sp`. The default is
/// [width]. The enum keeps the underlying screen-util package out of the
/// public API, so consumer apps only depend on `app_core`.
enum FontSizeScale {
  /// Scale by the screen width ratio (default).
  width,

  /// Scale by the screen height ratio.
  height,

  /// Scale by the radius ratio (the smaller of width or height).
  radius,

  /// Scale by the diameter ratio.
  diameter,

  /// Scale by the diagonal ratio.
  diagonal,
}
