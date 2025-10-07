import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

/// Unified flat selectable chip (replaces FilterChip / ChoiceChip stylistic mix)
/// Keeps visual language consistent: subtle surface, hairline border, strong focus outline on selection.
class SelectableChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? leading;
  final bool dense;

  const SelectableChip({super.key, required this.label, required this.selected, required this.onTap, this.leading, this.dense=false});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = selected ? scheme.primary.withOpacity(.14) : scheme.surface;
    final border = selected ? scheme.primary.withOpacity(.55) : scheme.outline.withOpacity(.35);
    final fg = selected ? scheme.primary : scheme.onSurface.withOpacity(.78);
    final padH = dense ? AppTokens.space3 : AppTokens.space3 + 2;
    final padV = dense ? AppTokens.space1 + 2 : AppTokens.space2 - 1;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppTokens.fast,
          padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: border),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (leading != null) ...[
              Icon(leading, size: 16, color: fg),
              const SizedBox(width: 6),
            ],
            Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600, color: fg, letterSpacing: .2)),
          ]),
        ),
      ),
    );
  }
}
