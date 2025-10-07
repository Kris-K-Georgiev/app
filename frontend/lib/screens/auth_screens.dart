import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/auth_provider.dart';
import '../providers/ui_provider.dart';
import 'home_screen.dart';
import '../widgets/city_dropdown.dart';
import '../widgets/adaptive_logo.dart';

class LoginScreen extends StatefulWidget { const LoginScreen({super.key}); @override State<LoginScreen> createState()=>_LoginScreenState(); }
class _LoginScreenState extends State<LoginScreen>{
  final _form = GlobalKey<FormState>();
  String email=''; String password=''; bool submitting=false; String? error;
  @override
  Widget build(BuildContext context){
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth:400),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key:_form,
              child: Column(mainAxisSize: MainAxisSize.min,children:[
                const AdaptiveLogo(height:90, padding: EdgeInsets.only(bottom:24)),
                TextFormField(decoration: const InputDecoration(labelText:'Имейл'), onSaved:(v)=>email=v!.trim(), validator:(v)=>v!.contains('@')?null:'Невалиден имейл'),
                TextFormField(decoration: const InputDecoration(labelText:'Парола'), obscureText:true, onSaved:(v)=>password=v!, validator:(v)=>v!.length>=6?null:'Минимум 6 символа'),
                Align(alignment: Alignment.centerRight, child: TextButton(onPressed: (){ Navigator.push(context, MaterialPageRoute(builder: (_)=> const ForgotPasswordScreen())); }, child: const Text('Забравена парола?'))),
                const SizedBox(height:16),
                if(error!=null) Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ElevatedButton(onPressed: submitting?null:() async {
                  if(!_form.currentState!.validate()) return; _form.currentState!.save();
                  final ui = context.read<UiProvider>();
                  setState(()=>submitting=true); ui.showBlocking('Влизане...');
                  try {
                    final ok = await auth.login(email,password); if(ok && mounted){ Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> const HomeScreen())); }
                  } catch(e){ setState(()=> error=e.toString()); } finally { ui.hideBlocking(); if(mounted) setState(()=>submitting=false);} }, child: Text(submitting?'...':'Вход')),
                const SizedBox(height:12),
                TextButton(onPressed: (){ Navigator.push(context, MaterialPageRoute(builder: (_)=> const RegisterScreen())); }, child: const Text('Създай профил')),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget { const RegisterScreen({super.key}); @override State<RegisterScreen> createState()=>_RegisterScreenState(); }
class _RegisterScreenState extends State<RegisterScreen>{
  final _form = GlobalKey<FormState>();
  String email=''; String password=''; String password2=''; String firstName=''; String lastName=''; String? city; bool submitting=false; String? info; String? error;
  @override
  Widget build(BuildContext context){
    final auth = context.read<AuthProvider>();
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: Center(
        child: ConstrainedBox(constraints: const BoxConstraints(maxWidth:420), child: Padding(padding: const EdgeInsets.all(16), child: Form(key:_form, child: ListView(shrinkWrap:true, children:[
          const AdaptiveLogo(height:90, padding: EdgeInsets.only(bottom:24)),
          Row(children:[
            Expanded(child: TextFormField(decoration: const InputDecoration(labelText:'Име'), onSaved:(v)=>firstName=v!.trim(), validator:(v)=>v!.isNotEmpty?null:'Задължително')),
            const SizedBox(width:12),
            Expanded(child: TextFormField(decoration: const InputDecoration(labelText:'Фамилия'), onSaved:(v)=>lastName=v!.trim(), validator:(v)=>v!.isNotEmpty?null:'Задължително')),
          ]),
          const SizedBox(height:12),
          CityDropdown(value: city, onChanged:(v)=> setState(()=>city=v), validator:(v)=> (v==null||v.isEmpty)?'Избери град':null),
          const SizedBox(height:12),
          TextFormField(decoration: const InputDecoration(labelText:'Имейл'), onSaved:(v)=>email=v!.trim(), validator:(v)=>v!.contains('@')?null:'Невалиден имейл'),
          TextFormField(decoration: const InputDecoration(labelText:'Парола'), obscureText:true,onSaved:(v)=>password=v!, validator:(v)=>v!.length>=6?null:'Минимум 6 символа'),
          TextFormField(decoration: const InputDecoration(labelText:'Потвърди парола'), obscureText:true,onSaved:(v)=>password2=v!, validator:(v)=>v!.length>=6?null:'Минимум 6 символа'),
          const SizedBox(height:16),
         if(info!=null) Text(info!, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          if(error!=null) Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ElevatedButton(onPressed: submitting?null:() async { if(!_form.currentState!.validate()) return; _form.currentState!.save(); if(password!=password2){ setState(()=>error='Паролите не съвпадат'); return; } if(city==null){ setState(()=>error='Моля избери град'); return; } final ui = context.read<UiProvider>(); setState(()=>submitting=true); ui.showBlocking('Създаване...'); try { await auth.startRegistration(firstName: firstName, lastName: lastName, city: city!, email: email, password: password, passwordConfirmation: password2); if(!mounted) return; Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> const VerificationScreen())); } catch(e){ setState(()=>error=e.toString()); } finally { ui.hideBlocking(); setState(()=>submitting=false);} }, child: Text(submitting?'...':'Регистрация')),
          TextButton(onPressed: submitting? null : (){ Navigator.pop(context); }, child: const Text('Назад към вход'))
        ]))),),
      ),
    );
  }
}

class VerificationScreen extends StatefulWidget { const VerificationScreen({super.key}); @override State<VerificationScreen> createState()=>_VerificationScreenState(); }
class _VerificationScreenState extends State<VerificationScreen>{
  final _codeController = TextEditingController();
  bool submitting=false; String? message; int? remaining; bool resendWaiting=false; int cooldown=0; Timer? _timer;
  @override void initState(){ super.initState(); final storage = PageStorage.of(context); final stored = storage.readState(context,identifier:'code'); if(stored is String){ _codeController.text=stored; } _codeController.addListener(()=> storage.writeState(context,_codeController.text,identifier:'code')); }
  void startCooldown(){ cooldown=60; resendWaiting=true; _timer?.cancel(); _timer = Timer.periodic(const Duration(seconds:1), (t){ if(!mounted) return; setState((){ cooldown--; if(cooldown<=0){ resendWaiting=false; t.cancel(); } }); }); }
  @override
  Widget build(BuildContext context){
    final auth = context.watch<AuthProvider>();
    final email = auth.pendingEmail;
    if(email==null){ return const Scaffold(body: Center(child: Text('Няма активна регистрация'))); }
    return Scaffold(
      appBar: AppBar(leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: ()=> Navigator.pop(context)), title: const Text('Потвърждение')), 
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth:420),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(mainAxisSize: MainAxisSize.min, children:[
              const AdaptiveLogo(height:80, padding: EdgeInsets.only(bottom:24)),
              Text('Изпратихме 6-цифрен код на: $email', textAlign: TextAlign.center),
              const SizedBox(height:12),
              TextField(controller: _codeController, maxLength: 6, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText:'Код')),              
              if(message!=null) Padding(padding: const EdgeInsets.only(top:8), child: Text(message!, style: TextStyle(color: message!.startsWith('Успешно')? Theme.of(context).colorScheme.onSurface: Theme.of(context).colorScheme.error))),
              ElevatedButton(onPressed: submitting?null:() async { final ui = context.read<UiProvider>(); setState(()=>submitting=true); ui.showBlocking('Потвърждение...'); try { await auth.submitVerificationCode(_codeController.text.trim()); if(!mounted) return; setState(()=>message='Успешно потвърдено'); Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_)=> const HomeScreen()), (_)=>false); } catch(e){ final text = e.toString(); final match = RegExp(r'remaining.?\\D(\\d)').firstMatch(text); if(match!=null){ remaining = int.tryParse(match.group(1)!); } setState(()=>message=text); } finally { ui.hideBlocking(); if(mounted) setState(()=>submitting=false);} }, child: Text(submitting?'...':'Потвърди')),
              if(remaining!=null && remaining!>0) Text('Оставащи опити: $remaining', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(.7))),
              TextButton(onPressed: resendWaiting? null : () async { try { await auth.resendRegistrationCode(); setState(()=>message='Изпратихме нов код'); startCooldown(); } catch(e){ setState(()=>message=e.toString()); } }, child: Text(resendWaiting? 'Изчакайте ($cooldown)' : 'Изпрати нов код')),
            ]),
          ),
        ),
      ),
    );
  }
}

class ForgotPasswordScreen extends StatefulWidget { const ForgotPasswordScreen({super.key}); @override State<ForgotPasswordScreen> createState()=> _ForgotPasswordScreenState(); }
class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>{
  final _form = GlobalKey<FormState>(); String email=''; bool submitting=false; String? info; String? error;
  @override Widget build(BuildContext context){
    return Scaffold(
  appBar: AppBar(title: const Text('Забравена парола')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth:420),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key:_form,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children:[
                  TextFormField(decoration: const InputDecoration(labelText:'Имейл'), onSaved:(v)=>email=v!.trim(), validator:(v)=> v!.contains('@')? null : 'Невалиден имейл'),
                  const SizedBox(height:16),
                  if(info!=null) Text(info!, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                  if(error!=null) Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ElevatedButton(onPressed: submitting? null : () async { if(!_form.currentState!.validate()) return; _form.currentState!.save(); final ui = context.read<UiProvider>(); setState(()=>submitting=true); ui.showBlocking('Изпращане...'); try { await context.read<AuthProvider>().api.post('/auth/forgot-password', {'email':email}); if(!mounted) return; Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> ResetPasswordScreen(presetEmail: email))); } catch(e){ setState(()=>error=e.toString()); } finally { ui.hideBlocking(); setState(()=>submitting=false);} }, child: Text(submitting?'...':'Изпрати')),
                ]
              )
            )
          )
        )
      )
    );
  }
}

class ResetPasswordScreen extends StatefulWidget { final String? presetEmail; const ResetPasswordScreen({super.key, this.presetEmail}); @override State<ResetPasswordScreen> createState()=> _ResetPasswordScreenState(); }
class _ResetPasswordScreenState extends State<ResetPasswordScreen>{
  final _form = GlobalKey<FormState>(); String email=''; String code=''; String password=''; String password2=''; bool submitting=false; String? info; String? error;
  @override void initState(){ super.initState(); if(widget.presetEmail!=null) email = widget.presetEmail!; }
  @override Widget build(BuildContext context){
    return Scaffold(
  appBar: AppBar(title: const Text('Нова парола')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth:420),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key:_form,
              child: ListView(
                shrinkWrap:true,
                children:[
                  TextFormField(initialValue: email.isNotEmpty? email : null, decoration: const InputDecoration(labelText:'Имейл'), onSaved:(v)=>email=v!.trim(), validator:(v)=> v!.contains('@')? null : 'Невалиден имейл'),
                  TextFormField(decoration: const InputDecoration(labelText:'Код (6 цифри)'), maxLength:6, keyboardType: TextInputType.number, onSaved:(v)=>code=v!.trim(), validator:(v)=> v!=null && v.trim().length==6? null : '6 цифри'),
                  TextFormField(decoration: const InputDecoration(labelText:'Нова парола'), obscureText:true, onSaved:(v)=>password=v!, validator:(v)=> v!.length>=6? null : 'Минимум 6 символа'),
                  TextFormField(decoration: const InputDecoration(labelText:'Потвърди парола'), obscureText:true, onSaved:(v)=>password2=v!, validator:(v)=> v!.length>=6? null : 'Минимум 6 символа'),
                  const SizedBox(height:16),
                  if(info!=null) Text(info!, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                  if(error!=null) Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ElevatedButton(onPressed: submitting? null : () async { if(!_form.currentState!.validate()) return; _form.currentState!.save(); if(password!=password2){ setState(()=>error='Паролите не съвпадат'); return; } final ui = context.read<UiProvider>(); setState(()=>submitting=true); ui.showBlocking('Обновяване...'); try { await context.read<AuthProvider>().api.post('/auth/reset-password', {'email':email,'code':code,'password':password,'password_confirmation':password2}); setState(()=>info='Паролата е обновена.'); } catch(e){ setState(()=>error=e.toString()); } finally { ui.hideBlocking(); setState(()=>submitting=false);} }, child: Text(submitting?'...':'Обнови')),
                ]
              )
            )
          )
        )
      )
    );
  }
}
