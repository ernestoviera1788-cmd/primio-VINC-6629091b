import 'package:flutter/material.dart';

class ResponsiveLayout {
  static const EdgeInsets _mobilePadding = EdgeInsets.all(12.0);
  static const EdgeInsets _tabletPadding = EdgeInsets.all(18.0);
  static const EdgeInsets _desktopPadding = EdgeInsets.all(24.0);

  static bool isMobileLayout(BuildContext context) => MediaQuery.sizeOf(context).width < 600;

  static bool isTabletLayout(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= 600 && width < 1200;
  }

  static bool isDesktopLayout(BuildContext context) => MediaQuery.sizeOf(context).width >= 1200;

  static double getSpacing(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 600) return 12.0;
    if (width < 1200) return 16.0;
    return 20.0;
  }

  static EdgeInsets getPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 600) return _mobilePadding;
    if (width < 1200) return _tabletPadding;
    return _desktopPadding;
  }

  static double getIconSize(BuildContext context, {required double base}) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 600) return base;
    if (width < 1200) return base * 1.2;
    return base * 1.4;
  }

  static const double maxContentWidth = 840.0;

  static Widget constrain(Widget child, {double maxWidth = maxContentWidth}) =>
      Center(child: ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth), child: child));
}
