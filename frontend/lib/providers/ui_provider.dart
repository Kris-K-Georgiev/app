import 'package:flutter/foundation.dart';

/// Lightweight UI state holder (global overlays, blocking loaders, toasts later)
class UiProvider extends ChangeNotifier {
  bool _blocking = false; String? _message;
  bool get blocking => _blocking; String? get message => _message;
  void showBlocking([String? msg]) { _blocking = true; _message = msg; notifyListeners(); }
  void hideBlocking(){ if(_blocking){ _blocking=false; _message=null; notifyListeners(); } }

  // Simple in-memory queue for snack messages (UI layer listens and shows)
  final List<_SnackMessage> _snacks = [];
  List<_SnackMessage> get snacks => List.unmodifiable(_snacks);
  void pushSnack(String text, {SnackKind kind = SnackKind.info}){
    _snacks.add(_SnackMessage(text, kind));
    notifyListeners();
  }
  void consumeSnack(_SnackMessage m){ _snacks.remove(m); notifyListeners(); }
}

enum SnackKind { info, error, success }
class _SnackMessage {
  final String text; final SnackKind kind; _SnackMessage(this.text,this.kind);
}