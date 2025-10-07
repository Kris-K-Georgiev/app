import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/ui_provider.dart';
import '../ui/typography.dart';
import '../icons/app_icons.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});
  @override State<ProfileEditScreen> createState()=> _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen>{
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name;
  late TextEditingController _city;
  late TextEditingController _bio;
  late TextEditingController _phone;
  XFile? _avatar;
  bool _saving=false; String? _error; bool _changed=false;

  @override void initState(){
    super.initState();
    final user = context.read<AuthProvider>().user ?? {};
    _name = TextEditingController(text: user['name']??'');
    _city = TextEditingController(text: user['city']??'');
    _bio = TextEditingController(text: user['bio']??'');
    _phone = TextEditingController(text: user['phone']??'');
  }
  @override void dispose(){ _name.dispose(); _city.dispose(); _bio.dispose(); _phone.dispose(); super.dispose(); }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1024, imageQuality: 85);
    if(file!=null){ setState((){ _avatar=file; _changed=true; }); }
  }

  Future<void> _save() async {
    if(!_formKey.currentState!.validate()) return;
    final ui = context.read<UiProvider>();
    setState(()=> _saving=true); ui.showBlocking('Запазване...');
    try {
      final auth = context.read<AuthProvider>();
      await auth.updateProfile(name: _name.text.trim(), city: _city.text.trim(), bio: _bio.text.trim().isEmpty? null : _bio.text.trim(), phone: _phone.text.trim().isEmpty? null : _phone.text.trim());
      if(_avatar!=null){
        await auth.updateAvatar(_avatar!.path);
        await auth.refreshUser();
      } else {
        await auth.refreshUser();
      }
      if(mounted){ Navigator.pop(context, true); }
    } catch(e){ if(mounted) setState(()=> _error=e.toString()); }
    finally { ui.hideBlocking(); if(mounted) setState(()=> _saving=false); }
  }

  @override
  Widget build(BuildContext context){
    final scheme = Theme.of(context).colorScheme;
    final user = context.watch<AuthProvider>().user ?? {};
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редакция'),
        actions: [
          TextButton(
            onPressed: _saving? null : _save,
            child: _saving? const SizedBox(width:16,height:16,child:CircularProgressIndicator(strokeWidth:2)) : const Text('Запази'),
          )
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16,20,16,40),
            child: Form(
              key: _formKey,
              onChanged: (){ if(!_changed) setState(()=> _changed=true); },
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
                Row(crossAxisAlignment: CrossAxisAlignment.start, children:[
                  Stack(children:[
                    CircleAvatar(radius:52, backgroundImage: _avatar!=null? FileImage(File(_avatar!.path)) : (user['avatar_path']!=null? NetworkImage(user['avatar_path']) as ImageProvider : null), child: user['avatar_path']==null && _avatar==null? Text(user['name']!=null && user['name'].isNotEmpty? user['name'][0].toUpperCase():'?') : null),
                    Positioned(bottom:0,right:0, child: InkWell(onTap: _pickAvatar, child: Container(decoration: BoxDecoration(color: scheme.primary, shape: BoxShape.circle), padding: const EdgeInsets.all(6), child: AppIcons.photo(color: scheme.onPrimary, size:18))))
                  ]),
                  const SizedBox(width:20),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
                    TextFormField(
                      controller: _name,
                      decoration: const InputDecoration(labelText: 'Име'),
                      validator: (v)=> v==null || v.trim().isEmpty? 'Въведете име' : null,
                    ),
                    const SizedBox(height:12),
                    TextFormField(
                      controller: _city,
                      decoration: const InputDecoration(labelText: 'Град'),
                    ),
                    const SizedBox(height:12),
                    TextFormField(
                      controller: _phone,
                      decoration: const InputDecoration(labelText: 'Телефон'),
                      keyboardType: TextInputType.phone,
                    ),
                  ]))
                ]),
                const SizedBox(height:20),
                Text('Био', style: AppTypography.section(context)),
                const SizedBox(height:8),
                TextFormField(
                  controller: _bio,
                  decoration: const InputDecoration(hintText: 'Кратко описание'),
                  maxLines: 4,
                ),
                if(_error!=null) Padding(padding: const EdgeInsets.only(top:16), child: Text(_error!, style: TextStyle(color: scheme.error))),
                const SizedBox(height:40),
                if(!_saving) Row(children:[
                  ElevatedButton.icon(onPressed: _save, icon: AppIcons.check(size:18), label: const Text('Запази')),
                  const SizedBox(width:12),
                  TextButton(onPressed: _changed? ()=> Navigator.pop(context) : null, child: const Text('Затвори'))
                ])
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
