import 'package:flutter/material.dart';
import '../services/biometric_helper.dart';

/// Reusable dialog flow for biometric authentication.
/// Returns true if user successfully authenticated or skipped, false if user opted to logout/fallback.
Future<bool> showBiometricDialog(BuildContext context, BiometricHelper helper) async {
  bool proceed = false; bool abort=false;
  while(!proceed && !abort && context.mounted){
    final locked = helper.isLocked; final remaining = helper.remainingLock;
    final action = await showDialog<String>(context: context, barrierDismissible: false, builder: (ctx){
      final scheme = Theme.of(ctx).colorScheme;
      return AlertDialog(
        title: const Text('Биометрично влизане'),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children:[
          if(locked && remaining!=null) Text('Опитите са блокирани за ${remaining.inSeconds}s', style: TextStyle(color: scheme.error)),
          if(!locked) const Text('Потвърдете самоличността си чрез биометрия.'),
        ]),
        actions: [
          TextButton(onPressed: (){ Navigator.pop(ctx,'abort'); }, child: const Text('Изход')),
          TextButton(onPressed: locked? null : (){ Navigator.pop(ctx,'try'); }, child: const Text('Опитай')),
          TextButton(onPressed: (){ Navigator.pop(ctx,'skip'); }, child: const Text('Пропусни')),
        ],
      );
    });
    if(action=='abort'){ abort=true; }
    else if(action=='skip'){ proceed=true; }
    else if(action=='try'){
      final ok = await helper.authenticate();
      if(ok) {
        proceed=true;
      } else {
        if(helper.isLocked && context.mounted){
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Блокирано. Опитайте по-късно')));
        }
      }
    } else { proceed=true; }
  }
  return proceed && !abort;
}
