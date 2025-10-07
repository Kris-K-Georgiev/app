import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

/// Universal metadata chip used for tags, status, city indicators etc.
class MetaChip extends StatelessWidget {
  final String label; 
  final Color? toneColor; 
  final Color? dotColor; 
  final bool selected; 
  final VoidCallback? onTap; 
  final bool dense;
  const MetaChip({super.key, required this.label, this.toneColor, this.dotColor, this.selected=false, this.onTap, this.dense=false});
  @override
  Widget build(BuildContext context){
    final scheme = Theme.of(context).colorScheme;
    final base = toneColor ?? scheme.primary;
    final bg = selected ? base.withOpacity(.18) : base.withOpacity(.10);
    final border = base.withOpacity(selected? .50 : .30);
    final padV = dense ? (AppTokens.space1 + 1) : AppTokens.space2 - 1; // ~5 / 7
    final padH = dense ? AppTokens.space2 + 2 : AppTokens.space3;
    final child = Row(mainAxisSize: MainAxisSize.min, children:[
      if(dotColor!=null) ...[
        Container(width:8,height:8, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
        const SizedBox(width:6),
      ],
      if(label.isNotEmpty) Text(label, style: TextStyle(fontSize:12, fontWeight: FontWeight.w600, color: scheme.onSurface.withOpacity(.82))),
    ]);
    return AnimatedContainer(
      duration: const Duration(milliseconds:200),
      padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
            onTap: onTap,
            splashColor: base.withOpacity(.15),
            highlightColor: base.withOpacity(.08),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal:2),
            child: child,
          ),
        ),
      ),
    );
  }
}
