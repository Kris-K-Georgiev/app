import 'package:flutter/material.dart';

/// Centralized typography scale to align mobile & admin panels.
/// Uses semantic names instead of raw font sizes to allow global tuning.
class AppTypography {
  static TextStyle display(BuildContext c) => Theme.of(c).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.8);
  static TextStyle title(BuildContext c) => Theme.of(c).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w600);
  static TextStyle section(BuildContext c) => Theme.of(c).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600);
  static TextStyle body(BuildContext c) => Theme.of(c).textTheme.bodyMedium!.copyWith(height: 1.35);
  static TextStyle bodySm(BuildContext c) => Theme.of(c).textTheme.bodySmall!.copyWith(height: 1.3, fontSize: 12.5);
  static TextStyle label(BuildContext c) => Theme.of(c).textTheme.labelMedium!.copyWith(fontWeight: FontWeight.w500, letterSpacing: .25);
  static TextStyle metric(BuildContext c) => Theme.of(c).textTheme.displaySmall!.copyWith(fontWeight: FontWeight.w700, letterSpacing: -1.0, fontSize: 34);
  static TextStyle code(BuildContext c) => Theme.of(c).textTheme.bodySmall!.copyWith(fontFamily: 'monospace', fontSize: 12.5, backgroundColor: Theme.of(c).colorScheme.surfaceContainerHighest.withOpacity(.4));
}
