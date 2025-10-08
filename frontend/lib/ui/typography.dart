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

/// New design text scale (from provided spec image)
/// Uses existing font family; if Inter is added later, swap globally in Theme.
class AppText {
  // Heading (Extra bold or Bold approximated with w800 / w700)
  static TextStyle h1(BuildContext c) => _f(c, 24, FontWeight.w800);
  static TextStyle h2(BuildContext c) => _f(c, 18, FontWeight.w800);
  static TextStyle h3(BuildContext c) => _f(c, 16, FontWeight.w800);
  static TextStyle h4(BuildContext c) => _f(c, 14, FontWeight.w700);
  static TextStyle h5(BuildContext c) => _f(c, 12, FontWeight.w700);

  // Body (Regular / Medium for XS)
  static TextStyle bodyXL(BuildContext c) => _f(c, 18, FontWeight.w400, height:1.35);
  static TextStyle bodyL(BuildContext c)  => _f(c, 16, FontWeight.w400, height:1.35);
  static TextStyle bodyM(BuildContext c)  => _f(c, 14, FontWeight.w400, height:1.35);
  static TextStyle bodyS(BuildContext c)  => _f(c, 12, FontWeight.w400, height:1.30);
  static TextStyle bodyXS(BuildContext c) => _f(c, 10, FontWeight.w500, height:1.25); // Medium per spec

  // Action (SemiBold → w600)
  static TextStyle actionL(BuildContext c) => _f(c, 14, FontWeight.w600, letterSpacing:.15);
  static TextStyle actionM(BuildContext c) => _f(c, 12, FontWeight.w600, letterSpacing:.15);
  static TextStyle actionS(BuildContext c) => _f(c, 10, FontWeight.w600, letterSpacing:.15);

  // Caption (SemiBold 10)
  static TextStyle captionM(BuildContext c) => _f(c, 10, FontWeight.w600, height:1.20, letterSpacing:.2);

  static TextStyle _f(BuildContext c, double size, FontWeight w,{double? height,double? letterSpacing}){
    return Theme.of(c).textTheme.bodyMedium!.copyWith(
      fontSize: size,
      fontWeight: w,
      height: height ?? 1.0,
      letterSpacing: letterSpacing,
      color: Theme.of(c).colorScheme.onSurface,
    );
  }
}
