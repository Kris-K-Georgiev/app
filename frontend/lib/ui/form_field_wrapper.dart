import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

/// Unified form field layout: label on top, field, helper/error below.
class AppFormFieldWrapper extends StatelessWidget {
  final String? label; final Widget child; final String? helper; final String? error; final bool dense;
  const AppFormFieldWrapper({super.key, this.label, required this.child, this.helper, this.error, this.dense=false});
  @override
  Widget build(BuildContext context){
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final err = error!=null && error!.isNotEmpty;
    return Padding(
      padding: EdgeInsets.only(bottom: dense? AppTokens.space3 : AppTokens.space4),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
        if(label!=null) Padding(padding: const EdgeInsets.only(bottom:4), child: Text(label!, style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600, letterSpacing:.3))),
        child,
        if(helper!=null && !err) Padding(padding: const EdgeInsets.only(top:4), child: Text(helper!, style: textTheme.bodySmall?.copyWith(fontSize:11, color: colorScheme.onSurface.withOpacity(.55)) )),
        if(err) Padding(padding: const EdgeInsets.only(top:4), child: Text(error!, style: textTheme.bodySmall?.copyWith(fontSize:11, color: colorScheme.error))),
      ]),
    );
  }
}
