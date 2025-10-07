import 'package:flutter/material.dart';

/// Global header style and animation for perfect design consistency
class AppHeader extends StatelessWidget {
  final String title;
  final double height;
  final EdgeInsetsGeometry padding;
  final TextStyle? textStyle;
  final bool pinned;
  final bool floating;
  final Widget? leading;
  final List<Widget>? actions;

  const AppHeader({
    required this.title,
    this.height = 100,
  this.padding = const EdgeInsetsDirectional.only(start: 16, top: 12, bottom: 4),
    this.textStyle,
    this.pinned = true,
    this.floating = true,
    this.leading,
    this.actions,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: pinned,
      floating: floating,
      expandedHeight: height,
      backgroundColor: Colors.transparent,
      leading: leading,
      actions: actions,
      flexibleSpace: Container(
        alignment: Alignment.bottomLeft,
        padding: padding,
        child: Text(
          title,
          style: textStyle ?? const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 24,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }
}
