import 'dart:ui';
import 'package:flutter/material.dart';

/// A reusable frosted glass / soft card container with:
///  - gradient hairline top
///  - subtle border & shadow
///  - adaptive surface (light/dark)
///  - configurable padding / radius
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadiusGeometry radius;
  final bool showTopAccent; // now renders a subtle hairline instead of gradient
  final Color? backgroundOverride;
  final GestureTapCallback? onTap;
  const GlassCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.radius = const BorderRadius.all(Radius.circular(22)), this.showTopAccent = true, this.backgroundOverride, this.onTap});

  @override
  Widget build(BuildContext context){
    final scheme = Theme.of(context).colorScheme;
    final surface = backgroundOverride ?? scheme.surface;
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final card = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: dark ? surface.withOpacity(.72) : surface.withOpacity(.82),
            border: Border.all(color: scheme.outline.withOpacity(dark? .18 : .25)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(dark? .35 : .07), blurRadius: 18, offset: const Offset(0,10), spreadRadius: -4),
            ],
          ),
          child: Stack(children:[
            if(showTopAccent)
              Positioned(top:0,left:0,right:0,child: Container(height:1.2, color: scheme.outline.withOpacity(dark? .35 : .25))),
            Padding(padding: padding, child: child),
          ]),
        ),
      ),
    );
    if(onTap!=null){
      return GestureDetector(onTap:onTap, child: card);
    }
    return card;
  }
}