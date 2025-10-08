import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/ui_provider.dart';
import '../widgets/adaptive_logo.dart';
import 'home_screen.dart';
import '../onboarding/onboarding_utils.dart';
import 'onboarding_questionnaire_screen.dart';

// ===================================================================================
// Global helpers / styles
// ===================================================================================

const _kHorizontalPadding = EdgeInsets.symmetric(horizontal: 24);
const _kInputSpacing = SizedBox(height: 16);
const _kSmallSpacing = SizedBox(height: 12);
const _kLargeSpacing = SizedBox(height: 32);
const int _verificationCodeLength = 4; // Set to 6 if backend expects 6

TextStyle _titleStyle(BuildContext c) => Theme.of(c).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.w600);
TextStyle _subtitleStyle(BuildContext c) => Theme.of(c).textTheme.bodyMedium!.copyWith(color: Theme.of(c).colorScheme.onSurface.withOpacity(.6));

Widget _authScaffold({required BuildContext context, required Widget child}) {
  return Scaffold(
    backgroundColor: Theme.of(context).colorScheme.background,
    body: SafeArea(
      child: LayoutBuilder(
        builder: (_, c) => SingleChildScrollView(
          padding: const EdgeInsets.only(top: 8, bottom: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: c.maxHeight - 32),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 420),
                padding: _kHorizontalPadding,
                child: child,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _SocialButton extends StatelessWidget {
  final IconData icon; final VoidCallback? onTap; final String semantic;
  const _SocialButton({required this.icon, required this.semantic, this.onTap});
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semantic,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Icon(icon, size: 24),
        ),
      ),
    );
  }
}

// ===================================================================================
// LOGIN SCREEN
// ===================================================================================

class LoginScreen extends StatefulWidget { const LoginScreen({super.key}); @override State<LoginScreen> createState()=>_LoginScreenState(); }
class _LoginScreenState extends State<LoginScreen>{
  final _form = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true; bool _loading=false; String? _error;

  @override
  void dispose(){ _emailCtrl.dispose(); _passwordCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if(!_form.currentState!.validate()) return; setState(()=>_error=null);
    final ui = context.read<UiProvider>();
    final auth = context.read<AuthProvider>();
    setState(()=>_loading=true); ui.showBlocking('Signing in...');
    try {
      final ok = await auth.login(_emailCtrl.text.trim(), _passwordCtrl.text);
      if(ok && mounted){ Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> const HomeScreen())); }
    } catch(e){ setState(()=>_error=e.toString()); } finally { ui.hideBlocking(); if(mounted) setState(()=>_loading=false); }
  }

  @override
  Widget build(BuildContext context){
    return _authScaffold(
      context: context,
      child: Form(
        key:_form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            const AdaptiveLogo(height:100, padding: EdgeInsets.only(bottom:24)),
            Text('Welcome!', style: _titleStyle(context)),
            _kLargeSpacing,
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email Address', hintText: 'name@email.com'),
              validator: (v)=> v!=null && v.contains('@') ? null : 'Invalid email',
            ),
            _kSmallSpacing,
            TextFormField(
              controller: _passwordCtrl,
              obscureText: _obscure,
              decoration: InputDecoration(labelText:'Password', suffixIcon: IconButton(icon: Icon(_obscure? Icons.visibility_off: Icons.visibility), onPressed: ()=> setState(()=> _obscure=!_obscure))),
              validator: (v)=> v!=null && v.length>=6 ? null : 'Min 6 chars',
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: _loading? null : (){ Navigator.push(context, MaterialPageRoute(builder: (_)=> const ForgotPasswordScreen())); },
                child: const Text('Forgot password?'),
              ),
            ),
            if(_error!=null) Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: _loading? null : _submit, child: Text(_loading? '...' : 'Login')),
            ),
            _kSmallSpacing,
            Center(
              child: RichText(text: TextSpan(style: Theme.of(context).textTheme.bodyMedium, children:[
                const TextSpan(text: 'Not a member? '),
                TextSpan(text: 'Register now', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.blue), recognizer: TapGestureRecognizer()..onTap=()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> const RegisterScreen()))),
              ])),
            ),
            _kLargeSpacing,
            Row(children:[
              Expanded(child: Divider(color: Theme.of(context).dividerColor)),
              const Padding(padding: EdgeInsets.symmetric(horizontal:12), child: Text('Or continue with')),
              Expanded(child: Divider(color: Theme.of(context).dividerColor)),
            ]),
            _kSmallSpacing,
            Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
              _SocialButton(icon: Icons.g_mobiledata, semantic: 'Google'),
              SizedBox(width:16),
              _SocialButton(icon: Icons.apple, semantic: 'Apple'),
              SizedBox(width:16),
              _SocialButton(icon: Icons.facebook, semantic: 'Facebook'),
            ]),
          ],
        ),
      ),
    );
  }
}

// ===================================================================================
// REGISTER SCREEN (Sign Up)
// ===================================================================================

class RegisterScreen extends StatefulWidget { const RegisterScreen({super.key}); @override State<RegisterScreen> createState()=>_RegisterScreenState(); }
class _RegisterScreenState extends State<RegisterScreen>{
  final _form = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _pass2Ctrl = TextEditingController();
  // City removed from initial registration; collected later in onboarding flow
  bool _agree=false; bool _obscure1=true; bool _obscure2=true; bool _loading=false; String? _error; String? _info;

  @override
  void dispose(){ _nameCtrl.dispose(); _emailCtrl.dispose(); _passCtrl.dispose(); _pass2Ctrl.dispose(); super.dispose(); }

  bool get _passwordsMatch => _passCtrl.text.isNotEmpty && _passCtrl.text == _pass2Ctrl.text;

  Future<void> _submit() async {
    if(!_form.currentState!.validate()) return; if(!_agree){ setState(()=>_error='Accept terms to continue'); return; }
    final auth = context.read<AuthProvider>(); final ui = context.read<UiProvider>();
    setState(()=>{_loading=true,_error=null}); ui.showBlocking('Creating account...');
    try {
      final nameParts = _nameCtrl.text.trim().split(' ');
      final firstName = nameParts.isNotEmpty? nameParts.first : '';
      final lastName = nameParts.length>1? nameParts.sublist(1).join(' ') : '';
  await auth.startRegistration(firstName: firstName, lastName: lastName, email: _emailCtrl.text.trim(), password: _passCtrl.text, passwordConfirmation: _pass2Ctrl.text);
      if(!mounted) return; Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> const VerificationScreen()));
    } catch(e){ setState(()=>_error=e.toString()); } finally { ui.hideBlocking(); if(mounted) setState(()=>_loading=false); }
  }

  @override
  Widget build(BuildContext context){
    return _authScaffold(
      context: context,
      child: Form(
        key:_form,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
          const AdaptiveLogo(height:80, padding: EdgeInsets.only(bottom:24)),
          Text('Sign up', style: _titleStyle(context)),
            const SizedBox(height:4),
          Text('Create an account to get started', style: _subtitleStyle(context)),
          _kLargeSpacing,
          TextFormField(controller:_nameCtrl, decoration: const InputDecoration(labelText:'Name'), validator:(v)=> v!=null && v.trim().isNotEmpty? null : 'Required'),
          _kSmallSpacing,
          // City field intentionally removed; city will be required during onboarding completion.
          TextFormField(controller:_emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText:'Email Address'), validator:(v)=> v!=null && v.contains('@')? null : 'Invalid email'),
          _kSmallSpacing,
          TextFormField(controller:_passCtrl, obscureText: _obscure1, decoration: InputDecoration(labelText:'Password', suffixIcon: IconButton(icon: Icon(_obscure1? Icons.visibility_off: Icons.visibility), onPressed: ()=> setState(()=> _obscure1=!_obscure1))), validator:(v)=> v!=null && v.length>=6? null : 'Min 6 chars'),
          _kSmallSpacing,
          Stack(children:[
            TextFormField(controller:_pass2Ctrl, obscureText: _obscure2, onChanged: (_)=> setState((){}), decoration: InputDecoration(labelText:'Confirm password', suffixIcon: IconButton(icon: Icon(_obscure2? Icons.visibility_off: Icons.visibility), onPressed: ()=> setState(()=> _obscure2=!_obscure2))), validator:(v)=> v!=null && v.length>=6? null : 'Min 6 chars'),
            Positioned(right: 12, top: 16, child: AnimatedContainer(duration: const Duration(milliseconds:250), width:10, height:10, decoration: BoxDecoration(color: _passwordsMatch? Colors.green : Colors.red, shape: BoxShape.circle)))
          ]),
          _kInputSpacing,
          Row(crossAxisAlignment: CrossAxisAlignment.start, children:[
            Checkbox(value: _agree, onChanged: _loading? null : (v)=> setState(()=> _agree=v??false)),
            Expanded(child: RichText(text: TextSpan(style: Theme.of(context).textTheme.bodySmall, children:[
              const TextSpan(text: "I've read and agree with the "),
              TextSpan(text:'Terms and Conditions', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600), recognizer: TapGestureRecognizer()..onTap=(){}),
              const TextSpan(text:' and the '),
              TextSpan(text:'Privacy Policy.', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600), recognizer: TapGestureRecognizer()..onTap=(){}),
            ])))
          ]),
          if(_info!=null) Padding(padding: const EdgeInsets.only(top:8), child: Text(_info!, style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
          if(_error!=null) Padding(padding: const EdgeInsets.only(top:8), child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
          _kSmallSpacing,
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _loading? null : _submit, child: Text(_loading? '...' : 'Sign up'))),
          _kSmallSpacing,
          Center(child: TextButton(onPressed: _loading? null : ()=> Navigator.pop(context), child: const Text('Back to login')))
        ]),
      ),
    );
  }
}

// ===================================================================================
// VERIFICATION SCREEN (4-digit code UI like design – adjustable length constant)
// ===================================================================================

class VerificationScreen extends StatefulWidget { const VerificationScreen({super.key}); @override State<VerificationScreen> createState()=>_VerificationScreenState(); }
class _VerificationScreenState extends State<VerificationScreen>{
  List<FocusNode> nodes = List.generate(_verificationCodeLength, (_)=> FocusNode());
  List<TextEditingController> ctrls = List.generate(_verificationCodeLength, (_)=> TextEditingController());
  bool _loading=false; String? _msg; bool _resendWaiting=false; int _cooldown=0; Timer? _timer; int? remaining;

  String get code => ctrls.map((c)=>c.text).join();

  void _startCooldown(){
    setState(()=>{_resendWaiting=true, _cooldown=60});
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds:1), (t){
      if(!mounted) return; setState(()=> _cooldown--); if(_cooldown<=0){ t.cancel(); if(mounted) setState(()=> _resendWaiting=false); }
    });
  }

  @override
  void dispose(){ for(final f in nodes){ f.dispose(); } for(final c in ctrls){ c.dispose(); } _timer?.cancel(); super.dispose(); }

  Future<void> _submit() async {
    if(code.length!=_verificationCodeLength) return;
    final auth = context.read<AuthProvider>(); final ui = context.read<UiProvider>();
    setState(()=>_loading=true); ui.showBlocking('Verifying...');
    try {
      final ok = await auth.submitVerificationCode(code); if(!mounted) return; if(ok){
        final incomplete = isProfileIncomplete(auth.user);
        if(incomplete){
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_)=> const OnboardingQuestionnaireScreen()), (_)=> false);
        } else {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_)=> const HomeScreen()), (_)=> false);
        }
      }
    } catch(e){ final text = e.toString(); final match = RegExp(r'remaining.?\\D(\\d)').firstMatch(text); if(match!=null){ remaining = int.tryParse(match.group(1)!); } setState(()=> _msg=text); }
    finally { ui.hideBlocking(); if(mounted) setState(()=>_loading=false); }
  }

  @override
  Widget build(BuildContext context){
    final email = context.watch<AuthProvider>().pendingEmail;
    if(email==null){ return _authScaffold(context: context, child: const Center(child: Text('No active registration'))); }
    return _authScaffold(
      context: context,
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children:[
        const AdaptiveLogo(height:80, padding: EdgeInsets.only(bottom:24)),
        Text('Enter confirmation code', style: _titleStyle(context), textAlign: TextAlign.center),
        const SizedBox(height:8),
        Text('A ${_verificationCodeLength}-digit code was sent to $email', style: _subtitleStyle(context), textAlign: TextAlign.center),
        _kLargeSpacing,
        Row(mainAxisAlignment: MainAxisAlignment.center, children:[
          for(int i=0;i<_verificationCodeLength;i++) _DigitBox(
            controller: ctrls[i], focusNode: nodes[i],
            onChanged: (v){
              if(v.isNotEmpty){ if(i<_verificationCodeLength-1){ nodes[i+1].requestFocus(); } else { FocusScope.of(context).unfocus(); }
              } else { if(i>0){ nodes[i-1].requestFocus(); } }
              setState((){});
            },
          )
        ]),
        _kSmallSpacing,
        TextButton(onPressed: _resendWaiting? null : () async { try { await context.read<AuthProvider>().resendRegistrationCode(); setState(()=> _msg='New code sent'); _startCooldown(); } catch(e){ setState(()=> _msg=e.toString()); } }, child: Text(_resendWaiting? 'Resend in $_cooldown' : 'Resend code')),
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: code.length==_verificationCodeLength && !_loading? _submit : null, child: Text(_loading? '...' : 'Continue'))),
        if(_msg!=null) Padding(padding: const EdgeInsets.only(top:12), child: Text(_msg!, style: TextStyle(color: _msg!.startsWith('New')? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.error))),
        if(remaining!=null && remaining!>0) Padding(padding: const EdgeInsets.only(top:4), child: Text('Attempts left: $remaining', style: _subtitleStyle(context))),
      ]),
    );
  }
}

class _DigitBox extends StatelessWidget {
  final TextEditingController controller; final FocusNode focusNode; final ValueChanged<String> onChanged;
  const _DigitBox({required this.controller, required this.focusNode, required this.onChanged});
  @override
  Widget build(BuildContext context){
    return Container(
      width: 52,
      margin: const EdgeInsets.symmetric(horizontal:6),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        maxLength: 1,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(counterText: '', border: OutlineInputBorder()),
        onChanged: onChanged,
      ),
    );
  }
}

// ===================================================================================
// Forgot password
// ===================================================================================

class ForgotPasswordScreen extends StatefulWidget { const ForgotPasswordScreen({super.key}); @override State<ForgotPasswordScreen> createState()=> _ForgotPasswordScreenState(); }
class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>{
  final _form = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _loading=false; String? _error; String? _info;

  @override
  void dispose(){ _emailCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async { if(!_form.currentState!.validate()) return; final ui = context.read<UiProvider>(); setState(()=>{_loading=true,_error=null}); ui.showBlocking('Sending...'); try { await context.read<AuthProvider>().api.post('/auth/forgot-password', {'email':_emailCtrl.text.trim()}); if(!mounted) return; Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> ResetPasswordScreen(presetEmail: _emailCtrl.text.trim()))); } catch(e){ setState(()=>_error=e.toString()); } finally { ui.hideBlocking(); if(mounted) setState(()=>_loading=false);} }

  @override
  Widget build(BuildContext context){
    return _authScaffold(
      context: context,
      child: Form(
        key:_form,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
          Text('Forgot password', style: _titleStyle(context)),
          _kLargeSpacing,
          TextFormField(controller:_emailCtrl, decoration: const InputDecoration(labelText:'Email'), validator:(v)=> v!=null && v.contains('@')? null : 'Invalid'),
          _kInputSpacing,
          if(_info!=null) Text(_info!),
          if(_error!=null) Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _loading? null : _submit, child: Text(_loading? '...' : 'Send reset code'))),
        ]),
      ),
    );
  }
}

// ===================================================================================
// Reset password
// ===================================================================================

class ResetPasswordScreen extends StatefulWidget { final String? presetEmail; const ResetPasswordScreen({super.key, this.presetEmail}); @override State<ResetPasswordScreen> createState()=> _ResetPasswordScreenState(); }
class _ResetPasswordScreenState extends State<ResetPasswordScreen>{
  final _form = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _pass1 = TextEditingController();
  final _pass2 = TextEditingController();
  bool _loading=false; String? _error; String? _info; bool _obscure1=true; bool _obscure2=true;

  @override void initState(){ super.initState(); if(widget.presetEmail!=null){ _emailCtrl.text = widget.presetEmail!; } }
  @override void dispose(){ _emailCtrl.dispose(); _codeCtrl.dispose(); _pass1.dispose(); _pass2.dispose(); super.dispose(); }

  Future<void> _submit() async { if(!_form.currentState!.validate()) return; if(_pass1.text!=_pass2.text){ setState(()=>_error='Passwords do not match'); return; } final ui = context.read<UiProvider>(); setState(()=>{_loading=true,_error=null}); ui.showBlocking('Updating password...'); try { await context.read<AuthProvider>().api.post('/auth/reset-password', {'email':_emailCtrl.text.trim(),'code':_codeCtrl.text.trim(),'password':_pass1.text,'password_confirmation':_pass2.text}); setState(()=>_info='Password updated'); } catch(e){ setState(()=>_error=e.toString()); } finally { ui.hideBlocking(); if(mounted) setState(()=>_loading=false);} }

  @override
  Widget build(BuildContext context){
    return _authScaffold(
      context: context,
      child: Form(
        key:_form,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
          Text('Reset password', style: _titleStyle(context)),
          _kLargeSpacing,
          TextFormField(controller:_emailCtrl, decoration: const InputDecoration(labelText:'Email'), validator:(v)=> v!=null && v.contains('@') ? null : 'Invalid'),
          _kSmallSpacing,
          TextFormField(controller:_codeCtrl, decoration: const InputDecoration(labelText:'Code (6 digits)'), maxLength:6, keyboardType: TextInputType.number, validator:(v)=> v!=null && v.trim().length==6 ? null : '6 digits'),
            _kSmallSpacing,
          TextFormField(controller:_pass1, obscureText:_obscure1, decoration: InputDecoration(labelText:'New password', suffixIcon: IconButton(icon: Icon(_obscure1? Icons.visibility_off: Icons.visibility), onPressed: ()=> setState(()=> _obscure1=!_obscure1))), validator:(v)=> v!=null && v.length>=6? null : 'Min 6 chars'),
          _kSmallSpacing,
          TextFormField(controller:_pass2, obscureText:_obscure2, decoration: InputDecoration(labelText:'Confirm password', suffixIcon: IconButton(icon: Icon(_obscure2? Icons.visibility_off: Icons.visibility), onPressed: ()=> setState(()=> _obscure2=!_obscure2))), validator:(v)=> v!=null && v.length>=6? null : 'Min 6 chars'),
          _kInputSpacing,
          if(_info!=null) Text(_info!, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          if(_error!=null) Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _loading? null : _submit, child: Text(_loading? '...' : 'Update'))),
        ]),
      ),
    );
  }
}

// ===================================================================================
// Logout dialog helper (for 1:1 design of confirmation dialog)
// ===================================================================================

Future<bool?> showLogoutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Log out'),
      content: const Text("Are you sure you want to log out? You'll need to login again to use the app."),
      actions: [
        TextButton(onPressed: ()=> Navigator.pop(context,false), child: const Text('Cancel')),
        FilledButton(onPressed: ()=> Navigator.pop(context,true), child: const Text('Log out')),
      ],
    ),
  );
}
