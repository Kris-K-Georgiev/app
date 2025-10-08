import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ui_provider.dart';
import '../theme/design_tokens.dart';

class GlobalOverlay extends StatelessWidget {
  final Widget child; const GlobalOverlay({super.key, required this.child});
  @override
  Widget build(BuildContext context){
    return Stack(children:[
      child,
      // Snack queue (top-right stacked)
      Positioned(
        top: 12,
        right: 12,
        left: 12,
        child: Consumer<UiProvider>(builder: (_,ui,__){
          if(ui.snacks.isEmpty) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: ui.snacks.take(3).map((m){
              final scheme = Theme.of(context).colorScheme;
              Color bg; Color fg;
              switch(m.kind){
                case SnackKind.error: bg = scheme.errorContainer; fg = scheme.onErrorContainer; break;
                case SnackKind.success: bg = scheme.primaryContainer; fg = scheme.onPrimaryContainer; break;
                default: bg = scheme.surfaceVariant; fg = scheme.onSurfaceVariant; break;
              }
              return Padding(
                key: ValueKey(m),
                padding: const EdgeInsets.only(bottom:8),
                child: Dismissible(
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal:16),
                    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
                    child: Icon(Icons.close, color: fg),
                  ),
                  onDismissed: (_){ ui.consumeSnack(m); },
                  key: ObjectKey(m),
                  child: AnimatedOpacity(
                    opacity: 1,
                    duration: AppTokens.fast,
                    child: Material(
                      color: bg,
                      elevation: 2,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        onTap: (){ ui.consumeSnack(m); },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16,12,16,14),
                          child: Text(m.text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: fg, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ),
      Consumer<UiProvider>(builder: (_, ui, __){
        if(!ui.blocking) return const SizedBox.shrink();
        return AnimatedOpacity(
          opacity: ui.blocking? 1 : 0,
          duration: AppTokens.medium,
          child: Container(
            color: Colors.black.withOpacity(.35),
            alignment: Alignment.center,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 140, maxWidth: 280),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                  border: Border.all(color: Theme.of(context).dividerColor.withOpacity(.5))
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20,20,20,22),
                  child: Column(mainAxisSize: MainAxisSize.min, children:[
                    const SizedBox(width:42,height:42, child: CircularProgressIndicator(strokeWidth: 3)),
                    if(ui.message!=null) ...[
                      const SizedBox(height:16),
                      Text(ui.message!, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                    ]
                  ]),
                ),
              ),
            ),
          ),
        );
      })
    ]);
  }
}