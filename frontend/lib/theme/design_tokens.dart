import 'package:flutter/material.dart';

/// Central design tokens to align mobile app with (assumed) admin panel styling.
/// If admin design changes, adjust ONLY here and in ThemeExtension below.
class AppTokens {
  // Spacing scale (4pt base) – can be tuned to match admin panel
  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space5 = 20;
  static const double space6 = 24;
  static const double space8 = 32;

  // Corner radii
  static const double radiusSm = 6;
  static const double radius = 12; // primary
  static const double radiusLg = 18;
  static const double radiusPill = 999;

  // Durations / animation (common micro‑interactions)
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration medium = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 320);

  // Elevation (admin assumed flat → keep minimal)
  static const double elevationNone = 0;
  static const double elevationCard = .5; // applied via subtle shadow + border

  // -------- Responsive helpers --------
  // Multiplicative spacing scale based on width
  static double spacingScale(double width){
    if(width >= 1440) return 1.25;
    if(width >= 1024) return 1.15;
    if(width >= 600) return 1.10;
    return 1.0;
  }
  // Conservative text scale for large viewports
  static double textScale(double width){
    if(width >= 1700) return 1.22;
    if(width >= 1440) return 1.16;
    if(width >= 1200) return 1.10;
    if(width >= 900) return 1.05;
    return 1.0;
  }
  // Denser vertical gap for big grids
  static double denseGap(double width, double base){
    if(width >= 1700) return base * .78;
    if(width >= 1440) return base * .82;
    if(width >= 1200) return base * .88;
    return base;
  }
}

/// Semantic color buckets (map Material colorScheme to admin palette semantics)
class SemanticColors extends ThemeExtension<SemanticColors>{
  final Color info;
  final Color success;
  final Color warning;
  final Color danger;
  final Color borderSubtle;
  final Color borderStrong;
  final Color badgeBg;

  const SemanticColors({
    required this.info,
    required this.success,
    required this.warning,
    required this.danger,
    required this.borderSubtle,
    required this.borderStrong,
    required this.badgeBg,
  });

  @override
  SemanticColors copyWith({Color? info, Color? success, Color? warning, Color? danger, Color? borderSubtle, Color? borderStrong, Color? badgeBg}) =>
    SemanticColors(
      info: info ?? this.info,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderStrong: borderStrong ?? this.borderStrong,
      badgeBg: badgeBg ?? this.badgeBg,
    );

  @override
  ThemeExtension<SemanticColors> lerp(ThemeExtension<SemanticColors>? other, double t) {
    if(other is! SemanticColors) return this;
    return SemanticColors(
      info: Color.lerp(info, other.info, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      badgeBg: Color.lerp(badgeBg, other.badgeBg, t)!,
    );
  }
}

/// Badge widget used across lists (events status, waitlist, past, role etc.)
class AppBadge extends StatelessWidget {
  final String label; final Color? color; final IconData? icon; final EdgeInsets padding; final TextStyle? textStyle;
  const AppBadge({super.key, required this.label, this.color, this.icon, this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4), this.textStyle});
  @override
  Widget build(BuildContext context){
    final scheme = Theme.of(context).colorScheme;
    final sem = Theme.of(context).extension<SemanticColors>();
    final bg = color ?? sem?.badgeBg ?? scheme.secondaryContainer;
    final fg = (color!=null && ThemeData.estimateBrightnessForColor(color!)==Brightness.dark) ? Colors.white : scheme.onSecondaryContainer;
    final style = textStyle ?? Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600, letterSpacing: .2, color: fg);
    return Container(
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppTokens.radiusPill), border: Border.all(color: (sem?.borderSubtle ?? scheme.outline).withOpacity(.6))),
      padding: padding,
      child: Row(mainAxisSize: MainAxisSize.min, children:[
        if(icon!=null) ...[Icon(icon, size: 12, color: style?.color), const SizedBox(width:4)],
        Text(label, style: style),
      ]),
    );
  }
}

/// Accessibility-oriented tokens (focus rings, high-contrast affordances, etc.)
class AccessibilityColors extends ThemeExtension<AccessibilityColors> {
  final Color focusRing;
  const AccessibilityColors({required this.focusRing});

  @override
  AccessibilityColors copyWith({Color? focusRing}) => AccessibilityColors(focusRing: focusRing ?? this.focusRing);

  @override
  ThemeExtension<AccessibilityColors> lerp(ThemeExtension<AccessibilityColors>? other, double t) {
    if(other is! AccessibilityColors) return this;
    return AccessibilityColors(focusRing: Color.lerp(focusRing, other.focusRing, t)!);
  }
}

/// Theme overrides for toast styling / behavior so different themes can tune
/// spacing, radii or animation without changing global ToastConfig statics.
class ToastTheme extends ThemeExtension<ToastTheme> {
  final double radius;
  final double borderWidth;
  final double verticalSpacing; // overrides ToastConfig.verticalSpacing if set
  final Duration entranceDuration;
  final Duration exitDuration;
  final Duration reflowDuration;
  final Curve reflowCurve;

  const ToastTheme({
    this.radius = 20,
    this.borderWidth = 1,
    this.verticalSpacing = 72,
    this.entranceDuration = const Duration(milliseconds:300),
    this.exitDuration = const Duration(milliseconds:220),
    this.reflowDuration = const Duration(milliseconds:300),
    this.reflowCurve = Curves.easeOutCubic,
  });

  @override
  ToastTheme copyWith({
    double? radius,
    double? borderWidth,
    double? verticalSpacing,
    Duration? entranceDuration,
    Duration? exitDuration,
    Duration? reflowDuration,
    Curve? reflowCurve,
  }) => ToastTheme(
    radius: radius ?? this.radius,
    borderWidth: borderWidth ?? this.borderWidth,
    verticalSpacing: verticalSpacing ?? this.verticalSpacing,
    entranceDuration: entranceDuration ?? this.entranceDuration,
    exitDuration: exitDuration ?? this.exitDuration,
    reflowDuration: reflowDuration ?? this.reflowDuration,
    reflowCurve: reflowCurve ?? this.reflowCurve,
  );

  @override
  ThemeExtension<ToastTheme> lerp(ThemeExtension<ToastTheme>? other, double t) {
    if(other is! ToastTheme) return this;
    return ToastTheme(
      radius: lerpDouble(radius, other.radius, t)!,
      borderWidth: lerpDouble(borderWidth, other.borderWidth, t)!,
      verticalSpacing: lerpDouble(verticalSpacing, other.verticalSpacing, t)!,
      entranceDuration: _lerpDuration(entranceDuration, other.entranceDuration, t),
      exitDuration: _lerpDuration(exitDuration, other.exitDuration, t),
      reflowDuration: _lerpDuration(reflowDuration, other.reflowDuration, t),
      reflowCurve: t < .5 ? reflowCurve : other.reflowCurve,
    );
  }

  static Duration _lerpDuration(Duration a, Duration b, double t) => Duration(milliseconds: (a.inMilliseconds + (b.inMilliseconds - a.inMilliseconds)*t).round());
}
