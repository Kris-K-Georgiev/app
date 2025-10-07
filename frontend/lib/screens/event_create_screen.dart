import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/ui_provider.dart';
import '../theme/design_tokens.dart';

class EventCreateScreen extends StatefulWidget {
  static const route = '/events/create';
  const EventCreateScreen({super.key});
  @override State<EventCreateScreen> createState()=> _EventCreateScreenState();
}

class _EventCreateScreenState extends State<EventCreateScreen>{
  final _form = GlobalKey<FormState>();
  String title=''; String? city; String? type; DateTime? start; DateTime? end; int? limit; bool submitting=false; String? error; String? info;

  Future<void> _pickDate({required bool startDate}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(context: context, firstDate: DateTime(now.year-1), lastDate: DateTime(now.year+2), initialDate: (startDate? start : end) ?? now);
    if(picked!=null){
      setState(()=> startDate? start = picked : end = picked);
    }
  }

  @override
  Widget build(BuildContext context){
    final auth = context.watch<AuthProvider>();
    if(!auth.canCreateEvent()){
      return Scaffold(appBar: AppBar(title: const Text('Събитие')), body: const Center(child: Text('Нямате права да създавате събития')));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Ново събитие')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppTokens.space4, AppTokens.space3, AppTokens.space4, AppTokens.space6),
          children: [
            TextFormField(decoration: const InputDecoration(labelText:'Заглавие'), onSaved:(v)=>title=v!.trim(), validator:(v)=> v!=null && v.trim().isNotEmpty? null : 'Задължително'),
            const SizedBox(height: AppTokens.space4),
            TextFormField(decoration: const InputDecoration(labelText:'Град'), onSaved:(v)=> city = (v!=null && v.trim().isNotEmpty)? v.trim(): null),
            const SizedBox(height: AppTokens.space4),
            Row(children:[
              Expanded(child: OutlinedButton(onPressed: ()=> _pickDate(startDate:true), child: Text(start==null? 'Начална дата' : '${start!.year}-${start!.month.toString().padLeft(2,'0')}-${start!.day.toString().padLeft(2,'0')}'))),
              const SizedBox(width: AppTokens.space3),
              Expanded(child: OutlinedButton(onPressed: ()=> _pickDate(startDate:false), child: Text(end==null? 'Крайна дата' : '${end!.year}-${end!.month.toString().padLeft(2,'0')}-${end!.day.toString().padLeft(2,'0')}'))),
            ]),
            const SizedBox(height: AppTokens.space4),
            TextFormField(decoration: const InputDecoration(labelText:'Лимит места'), keyboardType: TextInputType.number, onSaved:(v){ if(v!=null && v.trim().isNotEmpty){ limit = int.tryParse(v.trim()); } }),
            const SizedBox(height: AppTokens.space4),
            if(error!=null) Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            if(info!=null) Text(info!, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
            const SizedBox(height: AppTokens.space3),
            ElevatedButton(onPressed: submitting? null : () async {
              if(!_form.currentState!.validate()) return; _form.currentState!.save();
              setState(()=> submitting=true); final ui = context.read<UiProvider>(); ui.showBlocking('Създаване...');
              try {
                // TODO: integrate real backend creation endpoint
                await Future.delayed(const Duration(milliseconds: 800));
                if(!mounted) return; setState(()=> info='Създадено (локално симулирано)');
              } catch(e){ setState(()=> error=e.toString()); } finally { ui.hideBlocking(); if(mounted) setState(()=> submitting=false); }
            }, child: Text(submitting? '...' : 'Запази'))
          ],
        ),
      ),
    );
  }
}
