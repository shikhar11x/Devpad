import 'package:flutter/widgets.dart';

enum ScreenSize {
  mobile,
  tablet,
  desktop;

  static const double tabletBreakpoint = 700;
  static const double desktopBreakpoint = 1100;

  static ScreenSize fromWidth(double width) {
    if (width >= desktopBreakpoint) return desktop;
    if (width >= tabletBreakpoint) return tablet;
    return mobile;
  }

  bool get isMobile => this == mobile;
  bool get isTablet => this == tablet;
  bool get isDesktop => this == desktop;
}

extension ResponsiveContext on BuildContext {
  ScreenSize get screenSize =>
      ScreenSize.fromWidth(MediaQuery.sizeOf(this).width);
}