import 'package:flutter/material.dart';

/// Helper utility for creating responsive layouts across small budget phones,
/// standard smartphones, and tablets.
class ResponsiveLayout {
  ResponsiveLayout._();

  static const double maxContentWidth = 720.0;

  /// Wraps content with a max-width constraint on tablets/desktops to maintain
  /// readable aspect ratios and prevent awkward horizontal stretching.
  static Widget constrainedBody(BuildContext context, {required Widget child}) {
    final width = MediaQuery.sizeOf(context).width;
    if (width > maxContentWidth) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxContentWidth),
          child: child,
        ),
      );
    }
    return child;
  }

  /// Calculates dynamic horizontal padding according to screen width.
  static double horizontalPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 360) return 12.0;
    if (width > 600) return 24.0;
    return 16.0;
  }
}
