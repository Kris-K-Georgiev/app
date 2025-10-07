import 'package:flutter/foundation.dart';

/// Lightweight UI state holder (global overlays, blocking loaders, toasts later)
class UiProvider extends ChangeNotifier {
  bool _blocking = false; String? _message;
  bool get blocking => _blocking; String? get message => _message;
  void showBlocking([String? msg]) { _blocking = true; _message = msg; notifyListeners(); }
  void hideBlocking(){ if(_blocking){ _blocking=false; _message=null; notifyListeners(); } }
}