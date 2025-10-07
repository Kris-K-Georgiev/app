import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../icons/app_icons.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});
  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen>{
  final _formKey = GlobalKey<FormState>();
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  bool _saving=false; String? _error; String? _success;

  @override
  void dispose(){ _new.dispose(); _confirm.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if(!_formKey.currentState!.validate()) return;
    setState(()=> _saving=true); _error=null; _success=null;
    try {
      final auth = context.read<AuthProvider>();
      final ok = await auth.updateProfile(password: _new.text.trim());
      if(ok){ setState(()=> _success='Паролата е променена'); }
    } catch(e){ setState(()=> _error=e.toString()); }
    finally { setState(()=> _saving=false); }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text('Смяна на парола')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20,24,20,40),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
            TextFormField(
              controller: _new,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Нова парола'),
              validator: (v)=> v==null || v.length<6? 'Мин. 6 символа' : null,
            ),
            const SizedBox(height:16),
            TextFormField(
              controller: _confirm,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Потвърди парола'),
              validator: (v)=> v!=_new.text? 'Паролите не съвпадат' : null,
            ),
            const SizedBox(height:24),
            if(_error!=null) Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            if(_success!=null) Row(children:[AppIcons.check(color: Colors.green), const SizedBox(width:6), Text(_success!, style: const TextStyle(color: Colors.green))]),
            const SizedBox(height:24),
            ElevatedButton.icon(onPressed: _saving? null : _submit, icon: _saving? const SizedBox(width:16,height:16,child:CircularProgressIndicator(strokeWidth:2)) : AppIcons.check(), label: const Text('Запази'))
          ]),
        ),
      ),
    );
  }
}

class _NotificationsToggle extends StatefulWidget {
  const _NotificationsToggle();
  @override
  State<_NotificationsToggle> createState()=> _NotificationsToggleState();
}
class _NotificationsToggleState extends State<_NotificationsToggle>{
  bool _enabled=false; bool _loaded=false;
  @override
  void initState(){ super.initState(); _load(); }
  Future<void> _load() async {
    // Local persistence only for now (placeholder) using SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    setState((){ _enabled = prefs.getBool('notify_enabled') ?? true; _loaded=true; });
  }
  Future<void> _set(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notify_enabled', v);
    setState(()=> _enabled = v);
  }
  @override
  Widget build(BuildContext context){
    if(!_loaded) return const ListTile(title: Text('Известия'), subtitle: Text('Зареждане...'));
    return SwitchListTile(
      value: _enabled,
      title: const Text('Извести ме за нови събития'),
      subtitle: const Text('Локална настройка (placeholder)'),
      onChanged: (v)=> _set(v),
    );
  }
}
