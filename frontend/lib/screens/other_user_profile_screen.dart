import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../l10n/l10n.dart';

class OtherUserProfileScreen extends StatefulWidget {
  final int userId;
  const OtherUserProfileScreen({super.key, required this.userId});
  @override State<OtherUserProfileScreen> createState()=> _OtherUserProfileScreenState();
}

class _OtherUserProfileScreenState extends State<OtherUserProfileScreen> {
  Map<String,dynamic>? data; bool loading=true; bool error=false;

  @override void initState(){ super.initState(); _load(); }

  Future<void> _load() async {
    setState(()=> {loading=true,error=false});
    try {
      final api = context.read<AuthProvider>().api; // expects authenticated api client
      final res = await api.get('/users/${widget.userId}');
      if(res is Map<String,dynamic>){ data = res; }
    } catch(_){ error=true; }
    if(mounted) setState(()=> loading=false);
  }

  @override
  Widget build(BuildContext context){
    final t = AppLocalizations.of(context).t;
    return Scaffold(
      appBar: AppBar(title: Text(data?['name']?.toString() ?? t('community'))),
      body: loading ? const Center(child: CircularProgressIndicator())
        : error ? Center(child: Column(mainAxisSize: MainAxisSize.min, children:[
            const Icon(Icons.error_outline), const SizedBox(height:8),
            Text(t('error_generic')),
            const SizedBox(height:12),
            FilledButton(onPressed: _load, child: Text(t('retry')))
          ]))
        : _content(context),
    );
  }

  Widget _content(BuildContext context){
    final name = data?['name']?.toString() ?? '';
    final avatar = data?['avatar_path']?.toString();
    final city = data?['city']?.toString();
    final stats = data?['stats'];
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(children:[
          CircleAvatar(radius:36, backgroundImage: avatar!=null && avatar.isNotEmpty ? NetworkImage(avatar) : null, child: avatar==null? const Icon(Icons.person, size:36): null),
          const SizedBox(width:16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
            Text(name, style: Theme.of(context).textTheme.titleLarge),
            if(city!=null && city.isNotEmpty) Text(city, style: Theme.of(context).textTheme.bodySmall),
          ]))
        ]),
        const SizedBox(height:28),
        if(stats is Map) Wrap(spacing:12, runSpacing:12, children:[
          _statCard(context, 'Posts', stats['posts']),
          _statCard(context, 'Prayers', stats['prayers']),
          _statCard(context, 'Likes', stats['likes_received']),
        ]),
      ],
    );
  }

  Widget _statCard(BuildContext ctx, String label, dynamic value){
    final v = (value is int) ? value : int.tryParse(value?.toString()??'') ?? 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal:16, vertical:12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(ctx).colorScheme.surfaceVariant,
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children:[
        Text(v.toString(), style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height:4),
        Text(label, style: Theme.of(ctx).textTheme.labelSmall),
      ]),
    );
  }
}
