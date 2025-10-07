import 'package:flutter/material.dart';

/// Generic shimmer skeleton (replaces ad-hoc implementations). Wrap any box.
class Shimmer extends StatefulWidget {
  final double? width; final double? height; final BorderRadius? radius; final EdgeInsetsGeometry margin;
  const Shimmer({super.key, this.width, this.height, this.radius, this.margin = EdgeInsets.zero});
  @override State<Shimmer> createState()=> _ShimmerState();
}
class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _ac;
  @override void initState(){ super.initState(); _ac = AnimationController(vsync:this, duration: const Duration(seconds: 2))..repeat(); }
  @override void dispose(){ _ac.dispose(); super.dispose(); }
  @override Widget build(BuildContext context){
    final radius = widget.radius ?? BorderRadius.circular(10);
    return AnimatedBuilder(
      animation: _ac,
      builder: (_, __){
        final t = _ac.value;
        return Container(
          width: widget.width,
            height: widget.height,
            margin: widget.margin,
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: LinearGradient(
                colors: [
                  Colors.grey.shade300,
                  Colors.grey.shade200,
                  Colors.grey.shade300,
                ],
                stops: [0.0, (t*0.5).clamp(.2,.8), 1.0],
                begin: Alignment(-1 + t*2, -0.3),
                end: Alignment(1 - t*2, 0.3),
              ),
            ));
      },
    );
  }
}
