import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';

/// Compact statistic/info card that adapts to available width.
/// Used on profile for counts (posts, events, participation) but generic enough
/// for dashboard-like surfaces elsewhere.
class AdaptiveListCard extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? value;
  final String? subtitle;
  final VoidCallback? onTap;
  final EdgeInsets? padding;

  const AdaptiveListCard({
    super.key,
    this.leading,
    required this.title,
    this.value,
    this.subtitle,
    this.onTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final card = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTokens.radius),
      child: Padding(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: AppTokens.space3, vertical: AppTokens.space3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (leading != null) ...[
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: scheme.primary.withOpacity(.08),
                    borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                  ),
                  alignment: Alignment.center,
                  child: IconTheme(
                    data: IconThemeData(color: scheme.primary, size: 18),
                    child: leading!,
                  ),
                ),
                const SizedBox(width: AppTokens.space3),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: text.labelMedium?.copyWith(fontWeight: FontWeight.w600, letterSpacing: .2)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle!, style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                    ],
                  ],
                ),
              ),
              if (value != null)
                Text(value!, style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            ]),
          ],
        ),
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppTokens.radius),
        border: Border.all(color: scheme.outline.withOpacity(.25)),
      ),
      child: card,
    );
  }
}
