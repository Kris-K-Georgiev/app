import 'package:flutter/material.dart';

/// Public reusable SliverPersistentHeaderDelegate for a simple container with optional shadow
class FilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double min;
  final double max;
  final Widget child;
  final bool showShadowOnOverlap;
  const FilterHeaderDelegate({
    required double minExtent,
    required double maxExtent,
    required this.child,
    this.showShadowOnOverlap = true,
  }) : min = minExtent, max = maxExtent;

  @override
  double get minExtent => min;

  @override
  double get maxExtent => max;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: showShadowOnOverlap && overlapsContent
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ]
            : [],
      ),
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant FilterHeaderDelegate oldDelegate) {
    return oldDelegate.min != min ||
        oldDelegate.max != max ||
        oldDelegate.child != child ||
        oldDelegate.showShadowOnOverlap != showShadowOnOverlap;
  }
}
