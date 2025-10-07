import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/update_service.dart';

class UpdateScreen extends StatefulWidget {
  final String url; final String version; final String? notes;
  const UpdateScreen({super.key, required this.url, required this.version, this.notes});
  @override State<UpdateScreen> createState()=> _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen>{
  double progress=0; bool done=false; File? file; String? error; bool launching=false;
  @override void initState(){ super.initState(); _start(); }
  Future<void> _start() async {
    final service = UpdateService();
    final res = await service.download(widget.url, onProgress: (p){ if(mounted) setState(()=> progress=p); });
    if(!mounted) return;
  if(res.ok){ setState((){ done=true; file=res.file; }); } else { setState(()=> error=res.error); }
  }
  Future<void> _install() async {
    if(file==null) return; setState(()=> launching=true);
    final uri = Uri.file(file!.path);
    await launchUrl(uri);
    if(mounted) setState(()=> launching=false);
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text('Update ${widget.version}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
          if(widget.notes!=null) Text(widget.notes!),
          const SizedBox(height:16),
          LinearProgressIndicator(value: done?1: (progress>0?progress:null)),
          const SizedBox(height:8),
          Text(done? 'Downloaded ${(file?.lengthSync()??0)/1024~/1} KB' : error!=null? 'Error: $error' : '${(progress*100).toStringAsFixed(1)}%'),
          const SizedBox(height:24),
          if(done) ElevatedButton(onPressed: launching? null : _install, child: Text(launching? 'Opening...' : 'Install')),
          if(error!=null) ElevatedButton(onPressed: _start, child: const Text('Retry')),
          if(!done && error==null) const Text('Please keep the app open during download.')
        ]),
      ),
    );
  }
}