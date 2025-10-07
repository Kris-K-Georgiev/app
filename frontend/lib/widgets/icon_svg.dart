import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class IconSvg extends StatelessWidget {
  final String asset;
  final double size;
  final Color? color;
  const IconSvg(this.asset, {super.key, this.size = 22, this.color});
  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).iconTheme.color;
    return SvgPicture.asset(asset, width: size, height: size, colorFilter: c!=null? ColorFilter.mode(c, BlendMode.srcIn): null);
  }
}
