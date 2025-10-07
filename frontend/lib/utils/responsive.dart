import 'package:flutter/material.dart';

/// Responsive breakpoints and helpers for adaptive layout / navigation.
/// Width tiers (can be tuned):
///   small < 600 (phone portrait)
///   medium 600-1024 (large phone landscape / tablet portrait)
///   large 1024-1440 (tablet landscape / small desktop)
///   xlarge >= 1440 (wide desktop)
class AppBreakpoints {
  static const double small = 600;
  static const double medium = 1024;
  static const double large = 1440;

  static bool isSmall(BuildContext context) => MediaQuery.of(context).size.width < small;
  static bool isMedium(BuildContext context) {
    final w = MediaQuery.of(context).size.width; return w >= small && w < medium;
  }
  static bool isLarge(BuildContext context) {
    final w = MediaQuery.of(context).size.width; return w >= medium && w < large;
  }
  static bool isXLarge(BuildContext context) => MediaQuery.of(context).size.width >= large;
}

/// Returns number of columns for news grid based on width.
int newsGridColumns(double width){
  if(width < AppBreakpoints.small) return 1; // phone portrait
  if(width < AppBreakpoints.medium) return 2; // large phone / small tablet
  if(width < AppBreakpoints.large) return 3; // tablet landscape / small desktop
  if(width < 1700) return 4; // standard desktop
  return 5; // very wide desktop
}

/// Generic helper to compute grid columns for events (or other) lists when switching to grid mode.
int adaptiveGridColumns(double width){
  if(width < 900) return 1;
  if(width < 1200) return 2;
  if(width < 1600) return 3;
  if(width < 2000) return 4;
  return 5;
}

/// Constrain extremely wide layouts to a comfortable reading width.
double maxContentWidth(double width){
  // Beyond 1500 logical px, center content within 1380 for readability.
  return width > 1500 ? 1380 : width;
}

/// Adaptive navigation type.
enum NavType { bottom, rail, sidebar }

NavType navTypeForWidth(double width){
  if(width < AppBreakpoints.medium) return NavType.bottom;
  if(width < AppBreakpoints.large) return NavType.rail;
  return NavType.sidebar;
}
