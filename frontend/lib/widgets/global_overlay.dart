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