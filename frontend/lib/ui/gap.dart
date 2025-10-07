import 'package:flutter/widgets.dart';

/// Quick spacing helpers: Gap.x(8) or predefined constants.
class Gap extends SizedBox {
  const Gap._(double s): super(width: s, height: s);
  factory Gap.x(double size) => Gap._(size);
  static const Gap xs = Gap._(4);
  static const Gap sm = Gap._(8);
  static const Gap md = Gap._(16);
  static const Gap lg = Gap._(24);
  static const Gap xl = Gap._(32);
}

extension GapExt on num {
  Widget get gap => SizedBox(height: toDouble(), width: toDouble());
}
