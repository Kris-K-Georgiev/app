import 'package:flutter/material.dart';
import 'design_tokens.dart';

/// ThemeExtension carrying responsive scaling factors so nested widgets
/// can read consistent values without recalculating width logic.
class ResponsiveFactors extends ThemeExtension<ResponsiveFactors> {
  final double textScale; // applied multiplicatively to base text sizes
  final double spacingScale; // multiplicative spacing for horizontal paddings if needed

  const ResponsiveFactors({required this.textScale, required this.spacingScale});

  factory ResponsiveFactors.fromWidth(double width) => ResponsiveFactors(
    textScale: AppTokens.textScale(width),
    spacingScale: AppTokens.spacingScale(width),
  );

  @override
  ResponsiveFactors copyWith({double? textScale, double? spacingScale}) =>
      ResponsiveFactors(textScale: textScale ?? this.textScale, spacingScale: spacingScale ?? this.spacingScale);

  @override
  ThemeExtension<ResponsiveFactors> lerp(ThemeExtension<ResponsiveFactors>? other, double t) {
    if (other is! ResponsiveFactors) return this;
    return ResponsiveFactors(
      textScale: textScale + (other.textScale - textScale) * t,
      spacingScale: spacingScale + (other.spacingScale - spacingScale) * t,
    );
  }
}

extension ResponsiveFactorsContext on BuildContext {
  ResponsiveFactors get responsive => Theme.of(this).extension<ResponsiveFactors>() ??
      ResponsiveFactors(textScale: 1, spacingScale: 1);
}