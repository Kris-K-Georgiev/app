import 'package:flutter/material.dart';
import 'typography.dart';

/// Controls which typography scale components should use.
/// Wrap your app (above MaterialApp or below) with [TypographyScope]
/// and toggle [mode] at runtime (rebuild to propagate).
enum TypographyMode { material, app }

class TypographyScope extends InheritedWidget {
  final TypographyMode mode;
  const TypographyScope({super.key, required this.mode, required super.child});

  static TypographyMode of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<TypographyScope>();
    return scope?.mode ?? TypographyMode.app; // default to new scale
  }

  @override
  bool updateShouldNotify(TypographyScope oldWidget) => oldWidget.mode != mode;
}

/// Unified accessors so components do not directly depend on AppText vs Material.
class DsTextStyles {
  static TextStyle actionL(BuildContext c) {
    return TypographyScope.of(c) == TypographyMode.app
        ? AppText.actionL(c)
        : Theme.of(c).textTheme.labelLarge!.copyWith(fontWeight: FontWeight.w600);
  }
  static TextStyle actionM(BuildContext c) {
    return TypographyScope.of(c) == TypographyMode.app
        ? AppText.actionM(c)
        : Theme.of(c).textTheme.labelMedium!.copyWith(fontWeight: FontWeight.w600);
  }
  static TextStyle bodyS(BuildContext c) {
    return TypographyScope.of(c) == TypographyMode.app
        ? AppText.bodyS(c)
        : Theme.of(c).textTheme.bodySmall!;
  }
}
