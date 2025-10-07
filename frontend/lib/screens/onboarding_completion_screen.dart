import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/city_dropdown.dart';

class OnboardingCompletionScreen extends StatefulWidget {
  static const routeName = '/complete-profile';
  const OnboardingCompletionScreen({super.key});

  @override
  State<OnboardingCompletionScreen> createState() => _OnboardingCompletionScreenState();
}

class _OnboardingCompletionScreenState extends State<OnboardingCompletionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  String? _city;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
  final user = context.read<AuthProvider>().user;
  _nameCtrl.text = (user?['name'] as String?) ?? '';
  _city = (user?['city'] as String?);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if(!_formKey.currentState!.validate()) return;
    setState(()=>_submitting=true);
    try {
      await context.read<AuthProvider>().updateProfile(name: _nameCtrl.text.trim(), city: _city);
      if(mounted) Navigator.of(context).pushReplacementNamed('/');
    } catch(e){
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Грешка при запис: $e')));
      }
    } finally { if(mounted) setState(()=>_submitting=false); }
  }

  bool _incompleteProfile(AuthProvider auth){
  final u = auth.user; if(u==null) return true; final nameVal = u['name'] as String?; final cityVal = u['city'] as String?; return (nameVal==null || nameVal.trim().isEmpty || cityVal==null || cityVal.isEmpty); }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Попълване на профил')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Моля попълнете задължителните полета, за да продължите.', style: TextStyle(fontSize:16)),
            const SizedBox(height:16),
            if(!_incompleteProfile(auth))
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)), child: const Text('Профилът е пълен. Може да запазите промени или да се върнете.')),
            Form(
              key: _formKey,
              child: Column(children: [
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Име *'),
                  validator: (v)=> (v==null || v.trim().isEmpty)? 'Въведете име' : null,
                ),
                const SizedBox(height:12),
                CityDropdown(
                  value: _city,
                  onChanged: (val)=> setState(()=>_city=val),
                  validator: (v)=> (v==null || v.isEmpty)? 'Изберете град' : null,
                ),
                const SizedBox(height:24),
                SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: _submitting? null : _submit, icon: const Icon(Icons.check), label: _submitting? const SizedBox(height:18, width:18, child: CircularProgressIndicator(strokeWidth:2)) : const Text('Запази и продължи'))),
              ]),
            )
          ],
        ),
      ),
    );
  }
}
