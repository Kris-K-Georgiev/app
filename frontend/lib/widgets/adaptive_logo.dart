import 'package:flutter/material.dart';

class AdaptiveLogo extends StatelessWidget {
  final double height; final EdgeInsetsGeometry? padding; const AdaptiveLogo({super.key, this.height=80, this.padding});
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final asset = dark ? 'assets/logo/dark_logo.png' : 'assets/logo/light_logo.png';
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Image.asset(asset, height: height, fit: BoxFit.contain, errorBuilder: (_, __, ___)=> const SizedBox()),
    );
  }
}
