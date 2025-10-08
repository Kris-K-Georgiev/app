import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/community_provider.dart';
import '../models/post.dart';
import '../models/prayer.dart';
import '../services/community_service.dart';
import '../services/api_client.dart';
import 'other_user_profile_screen.dart';
import '../providers/auth_provider.dart';
import 'profile_screen.dart';
import '../utils/url_utils.dart';
import '../l10n/l10n.dart';
import '../services/api_client.dart';

class CommunityScreen extends StatefulWidget {
  static const routeName = '/community';
  const CommunityScreen({super.key});
  @override State<CommunityScreen> createState()=> _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  bool _init = false;

  @override
  void initState(){
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    // lazy init in post frame (provider might not exist yet)
    WidgetsBinding.instance.addPostFrameCallback((_){
      final cp = context.read<CommunityProvider>();
      if(!_init){ _init=true; cp.loadInitial(); }
    });
  }

  @override
  void dispose(){ _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).t('community')),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v){
              if(v=='about'){
                showAboutDialog(context: context, applicationName: 'App', applicationVersion: '1.0.0');
              } else if(v=='feedback'){
                _openFeedback(context);
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(value:'about', child: Text(AppLocalizations.of(context).t('about_org'))),
              PopupMenuItem(value:'feedback', child: Text(AppLocalizations.of(context).t('feedback'))),
            ],
          )
        ],
        bottom: TabBar(controller: _tab, tabs: [
          Tab(text: AppLocalizations.of(context).t('posts_tab')),
          Tab(text: AppLocalizations.of(context).t('prayers_tab')),
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){ _showComposer(context, _tab.index); },
        child: const Icon(Icons.add),
      ),
      body: TabBarView(
        controller: _tab,
        children: const [
          _PostsTab(),
          _PrayersTab(),
        ],
      ),
    );
  }

  void _showComposer(BuildContext context, int tab){
    if(tab==0){
      showModalBottomSheet(context: context, isScrollControlled: true, builder: (ctx)=> _PostComposer());
    } else {
      showModalBottomSheet(context: context, isScrollControlled: true, builder: (ctx)=> _PrayerComposer());
    }
  }

  void _openFeedback(BuildContext context){
    showModalBottomSheet(context: context, isScrollControlled: true, builder: (ctx)=> const _FeedbackSheet());
  }
}

class _PostsTab extends StatelessWidget {
  const _PostsTab();
  @override
  Widget build(BuildContext context){
    final p = context.watch<CommunityProvider>();
    final items = p.posts;
    if(p.postsLoading && items.isEmpty){
      return const Center(child: CircularProgressIndicator());
    }
    return NotificationListener<ScrollNotification>(
      onNotification: (n){
        if(n.metrics.pixels >= n.metrics.maxScrollExtent - 200){
          p.loadMorePosts();
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () async { await p.reloadPosts(); },
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 88),
          itemCount: items.length + (p.postsLoadingMore?1:0),
          itemBuilder: (ctx,i){
            if(i>=items.length){
              return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
            }
            final post = items[i];
            return _PostCard(post: post);
          },
        ),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final PostItem post; const _PostCard({required this.post});
  @override
  Widget build(BuildContext context){
    final provider = context.read<CommunityProvider>();
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
          // Header row: author + new tag
          if(post.author!=null || post.isNew) ...[
            Row(children:[
              if(post.author!=null) Expanded(
                child: GestureDetector(
                  onTap: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (_)=> OtherUserProfileScreen(userId: post.author!.id)));
                  },
                  child: Text(post.author!.name, style: Theme.of(context).textTheme.titleSmall?.copyWith(decoration: TextDecoration.underline)),
                ),
              ) else const Spacer(),
              if(post.isNew) Container(
                padding: const EdgeInsets.symmetric(horizontal:10, vertical:4),
                decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(20)),
                child: Text(AppLocalizations.of(context).t('new_tag'), style: Theme.of(context).textTheme.labelSmall?.copyWith(color: scheme.onPrimaryContainer)),
              ),
            ]),
            const SizedBox(height:8),
          ],
          if(post.image!=null && post.image!.isNotEmpty)...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Hero(
                tag: 'post_image_${post.id}',
                child: CachedNetworkImage(
                  imageUrl: absUrl(post.image),
                  fit: BoxFit.cover,
                  height: 220,
                  width: double.infinity,
                  errorWidget: (_,__,___)=> Container(height:220, alignment: Alignment.center, color: scheme.surfaceVariant, child: const Icon(Icons.broken_image)),
                  placeholder: (_,__)=> Container(height:220, color: scheme.surfaceVariant.withOpacity(.4)),
                ),
              ),
            const SizedBox(height:12),
          ],
          Text(post.content, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height:12),
          Row(children:[
            IconButton(onPressed: () async {
              try { await provider.togglePostLike(post); }
              catch(e){ if(context.mounted){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).t('error_generic')))); }}
            }, icon: Icon(post.liked? Icons.favorite : Icons.favorite_border, color: post.liked? scheme.primary : null)),
            Text('${post.likesCount}'),
            const SizedBox(width:24),
            IconButton(onPressed: (){ _openComments(context); }, icon: const Icon(Icons.comment_outlined)),
            if(post.canEdit) IconButton(onPressed: (){ _editPost(context, post); }, icon: const Icon(Icons.edit)),
          ])
        ]),
      ),
    );
  }

  void _editPost(BuildContext context, PostItem post){
    showModalBottomSheet(context: context, isScrollControlled: true, builder: (ctx)=> _PostComposer(existing: post));
  }

  void _openComments(BuildContext context){
    showModalBottomSheet(context: context, isScrollControlled: true, builder: (ctx)=> _CommentsSheet(post: post));
  }
}

class _CommentsSheet extends StatefulWidget {
  final PostItem post;
  const _CommentsSheet({required this.post});
  @override State<_CommentsSheet> createState()=> _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet>{
  final _controller = TextEditingController();
  final List<Map<String,dynamic>> _comments = [];
  bool _loading = false; bool _sending=false; bool _initialLoaded=false; bool _loadingMore=false; bool _hasMore=true; int _page=1;

  @override void initState(){ super.initState(); _load(); }
  @override void dispose(){ _controller.dispose(); super.dispose(); }

  Future<void> _load() async {
    if(_loading) return; setState(()=> _loading=true);
    try {
      final api = context.read<AuthProvider>().api; // raw use for now
      final res = await api.get('/posts/${widget.post.id}/comments?page=$_page&per_page=20');
      if(res is Map<String,dynamic>){
        final data = (res['data'] is List) ? List.from(res['data']) : const [];
        for(final c in data.whereType<Map>()){ _comments.add(Map<String,dynamic>.from(c)); }
        final current = res['current_page'] is int ? res['current_page'] : _page;
        final last = res['last_page'] is int ? res['last_page'] : current;
        _hasMore = current < last;
        if(_hasMore){ _page = current + 1; }
      }
    } catch(_){ /* ignore */ }
    finally { if(mounted){ setState(()=> {_loading=false,_initialLoaded=true}); } }
  }

  Future<void> _loadMore() async {
    if(!_hasMore || _loadingMore || _loading) return;
    setState(()=> _loadingMore=true);
    try { await _load(); } finally { if(mounted) setState(()=> _loadingMore=false); }
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if(text.isEmpty) return;
    setState(()=> _sending=true);
    try {
      final api = context.read<AuthProvider>().api;
      final res = await api.post('/posts/${widget.post.id}/comment', {'content': text});
      if(res is Map && res['comment'] is Map){
        _comments.insert(0, Map<String,dynamic>.from(res['comment']));
      }
      _controller.clear();
    } catch(e){
      if(context.mounted){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).t('error_generic')))); }
    } finally { if(mounted) setState(()=> _sending=false); }
  }

  @override
  Widget build(BuildContext context){
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(height:4, width:46, margin: const EdgeInsets.only(top:12,bottom:8), decoration: BoxDecoration(color: Theme.of(context).dividerColor, borderRadius: BorderRadius.circular(4))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal:16, vertical: 8),
              child: Row(children:[
                Expanded(child: Text(AppLocalizations.of(context).t('comments', params: {'count': _comments.length.toString()}), style: Theme.of(context).textTheme.titleMedium)),
                IconButton(onPressed: ()=> Navigator.pop(context), icon: const Icon(Icons.close))
              ]),
            ),
            if(_loading && !_initialLoaded) const Padding(padding: EdgeInsets.all(28), child: CircularProgressIndicator()),
            if(!_loading) Expanded(
              child: _comments.isEmpty
                ? Center(child: Text(AppLocalizations.of(context).t('no_comments')))
                : NotificationListener<ScrollNotification>(
                    onNotification: (n){
                      if(n.metrics.pixels >= n.metrics.maxScrollExtent - 60){ _loadMore(); }
                      return false;
                    },
                    child: ListView.builder(
                      reverse: false,
                      itemCount: _comments.length + (_loadingMore?1:0),
                      itemBuilder: (_,i){
                        if(i>=_comments.length){ return const Padding(padding: EdgeInsets.all(12), child: Center(child: SizedBox(width:20,height:20, child: CircularProgressIndicator(strokeWidth:2)))); }
                        final c = _comments[i];
                        final user = c['user'];
                        final name = (user is Map && user['name']!=null)? user['name'].toString() : (c['user_name']?.toString() ?? '—');
                        return ListTile(
                          leading: const CircleAvatar(radius:16, child: Icon(Icons.person, size:18)),
                          title: Text(name, style: Theme.of(context).textTheme.labelMedium),
                          subtitle: Text(c['content']?.toString() ?? ''),
                        );
                      },
                    ),
                  ),
            ),
            const Divider(height:1),
            Padding(
              padding: const EdgeInsets.fromLTRB(12,8,12,12),
              child: Row(children:[
                Expanded(child: TextField(
                  controller: _controller,
                  minLines: 1,
                  maxLines: 4,
                  decoration: InputDecoration(hintText: AppLocalizations.of(context).t('add_comment_hint')),
                )),
                const SizedBox(width:8),
                IconButton(onPressed: _sending? null : _send, icon: _sending? const SizedBox(width:20,height:20, child: CircularProgressIndicator(strokeWidth:2)) : const Icon(Icons.send))
              ]),
            )
          ],
        ),
      ),
    );
  }
}

class _PrayersTab extends StatelessWidget {
  const _PrayersTab();
  @override
  Widget build(BuildContext context){
    final p = context.watch<CommunityProvider>();
    final items = p.prayers;
    if(p.prayersLoading && items.isEmpty){ return const Center(child: CircularProgressIndicator()); }
    return NotificationListener<ScrollNotification>(
      onNotification: (n){ if(n.metrics.pixels >= n.metrics.maxScrollExtent - 200){ p.loadMorePrayers(); } return false; },
      child: RefreshIndicator(
        onRefresh: () async { await p.reloadPrayers(); },
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 88),
          itemCount: items.length + (p.prayersLoadingMore?1:0),
          itemBuilder: (ctx,i){
            if(i>=items.length){ return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator(strokeWidth:2))); }
            final pr = items[i];
            return _PrayerCard(prayer: pr);
          },
        ),
      ),
    );
  }
}

class _PrayerCard extends StatelessWidget {
  final PrayerItem prayer; const _PrayerCard({required this.prayer});
  @override
  Widget build(BuildContext context){
    final provider = context.read<CommunityProvider>();
    final scheme = Theme.of(context).colorScheme;
    final answeredColor = prayer.answered? scheme.tertiaryContainer : scheme.surfaceVariant;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
          Row(children:[
            Expanded(
              child: GestureDetector(
                onTap: (){
                  if(!prayer.isAnonymous && prayer.userName!=null){
                    // Navigate to user profile (for now reuse ProfileScreen if it's current user)
                    // If backend adds /users/{id} details, create OtherUserProfileScreen.
                    Navigator.of(context).push(MaterialPageRoute(builder: (_)=> const ProfileScreen()));
                  }
                },
                child: Text(prayer.isAnonymous? 'Анонимно' : (prayer.userName ?? '—'), style: Theme.of(context).textTheme.titleSmall?.copyWith(decoration: prayer.isAnonymous? null : TextDecoration.underline)),
              ),
            ),
            if(prayer.answered) Container(padding: const EdgeInsets.symmetric(horizontal:10, vertical:4), decoration: BoxDecoration(color: answeredColor, borderRadius: BorderRadius.circular(20)), child: Text('Отговорена', style: Theme.of(context).textTheme.labelSmall)),
          ]),
          const SizedBox(height:8),
          Text(prayer.content),
          const SizedBox(height:12),
          Row(children:[
            IconButton(onPressed: () async {
              try { await provider.togglePrayerLike(prayer); }
              catch(e){ if(context.mounted){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).t('error_generic')))); }}
            }, icon: Icon(prayer.liked? Icons.pan_tool : Icons.pan_tool_outlined, color: prayer.liked? scheme.primary : null)),
            Text('${prayer.likesCount}'),
            const SizedBox(width:24),
            if(prayer.canEdit) IconButton(onPressed: (){ _editPrayer(context, prayer); }, icon: const Icon(Icons.edit)),
          ])
        ]),
      ),
    );
  }

  void _editPrayer(BuildContext context, PrayerItem pr){
    showModalBottomSheet(context: context, isScrollControlled: true, builder: (ctx)=> _PrayerComposer(existing: pr));
  }
}

class _PostComposer extends StatefulWidget {
  final PostItem? existing;
  const _PostComposer({this.existing});
  @override State<_PostComposer> createState()=> _PostComposerState();
}

class _PostComposerState extends State<_PostComposer>{
  final _form = GlobalKey<FormState>();
  final _controller = TextEditingController();
  File? _image;
  bool _saving=false;
  @override void initState(){ super.initState(); if(widget.existing!=null){ _controller.text = widget.existing!.content; }}

  @override void dispose(){ _controller.dispose(); super.dispose(); }

  Future<void> _pick() async {
    try {
      final picker = ImagePicker();
      final XFile? picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 2400, imageQuality: 90);
      if(picked!=null){
        setState(()=> _image = File(picked.path));
      }
    } catch(_){ /* ignore */ }
  }

  Future<void> _submit() async {
    if(!_form.currentState!.validate()) return;
    setState(()=> _saving=true);
    final provider = context.read<CommunityProvider>();
    try {
      if(widget.existing==null){
        await provider.addPost(content: _controller.text.trim(), imagePath: _image?.path);
      } else {
        await provider.editPost(widget.existing!, content: _controller.text.trim(), imagePath: _image?.path);
      }
      if(mounted) Navigator.pop(context);
    } finally { if(mounted) setState(()=> _saving=false); }
  }

  @override
  Widget build(BuildContext context){
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20,20,20,30),
        child: Form(
          key: _form,
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children:[
            Text(AppLocalizations.of(context).t(widget.existing==null? 'new_post':'edit'), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height:12),
            TextFormField(
              controller: _controller,
              maxLines: 6,
              minLines: 3,
              maxLength: 5000,
              decoration: InputDecoration(labelText: AppLocalizations.of(context).t('content_label'), counterText: _counterText(context)),
              validator: (v)=> (v==null || v.trim().isEmpty)? AppLocalizations.of(context).t('content_required') : null,
            ),
            const SizedBox(height:12),
            Row(children:[
              OutlinedButton.icon(onPressed: _pick, icon: const Icon(Icons.image), label: Text(_image==null? AppLocalizations.of(context).t('image') : AppLocalizations.of(context).t('change_image'))),
              if(_image!=null) Padding(padding: const EdgeInsets.only(left:12), child: Text(AppLocalizations.of(context).t('selected'))),
            ]),
            const SizedBox(height:20),
            SizedBox(width: double.infinity, child: FilledButton(onPressed: _saving? null : _submit, child: Text(_saving? '...' : AppLocalizations.of(context).t('save')))),
          ]),
        ),
      ),
    );
  }

  String _counterText(BuildContext context){
    final remaining = 5000 - _controller.text.length;
    return AppLocalizations.of(context).t('characters_left', params: {'count': remaining.toString()});
  }
}

class _PrayerComposer extends StatefulWidget {
  final PrayerItem? existing;
  const _PrayerComposer({this.existing});
  @override State<_PrayerComposer> createState()=> _PrayerComposerState();
}

class _PrayerComposerState extends State<_PrayerComposer>{
  final _form = GlobalKey<FormState>();
  final _controller = TextEditingController();
  bool _anonymous = false;
  bool _answered = false;
  bool _saving=false;
  @override void initState(){ super.initState(); if(widget.existing!=null){ _controller.text=widget.existing!.content; _anonymous=widget.existing!.isAnonymous; _answered=widget.existing!.answered; }}
  @override void dispose(){ _controller.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if(!_form.currentState!.validate()) return;
    setState(()=> _saving=true);
    final provider = context.read<CommunityProvider>();
    try {
      if(widget.existing==null){
        await provider.addPrayer(content: _controller.text.trim(), isAnonymous: _anonymous);
      } else {
        await provider.editPrayer(widget.existing!, content: _controller.text.trim(), isAnonymous: _anonymous, answered: _answered);
      }
      if(mounted) Navigator.pop(context);
    } finally { if(mounted) setState(()=> _saving=false); }
  }

  @override
  Widget build(BuildContext context){
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20,20,20,30),
        child: Form(
          key: _form,
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children:[
            Text(AppLocalizations.of(context).t(widget.existing==null? 'new_prayer':'edit'), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height:12),
            TextFormField(
              controller: _controller,
              maxLines: 6,
              minLines: 3,
              maxLength: 5000,
              decoration: InputDecoration(labelText: AppLocalizations.of(context).t('content_label'), counterText: _counterText(context)),
              validator: (v)=> (v==null || v.trim().isEmpty)? AppLocalizations.of(context).t('content_required') : null,
            ),
            const SizedBox(height:12),
            SwitchListTile(value: _anonymous, onChanged: (v)=> setState(()=> _anonymous=v), title: Text(AppLocalizations.of(context).t('anonymous'))),
            if(widget.existing!=null) SwitchListTile(value: _answered, onChanged: (v)=> setState(()=> _answered=v), title: Text(AppLocalizations.of(context).t('answered'))),
            const SizedBox(height:20),
            SizedBox(width: double.infinity, child: FilledButton(onPressed: _saving? null : _submit, child: Text(_saving? '...' : AppLocalizations.of(context).t('save')))),
          ]),
        ),
      ),
    );
  }

  String _counterText(BuildContext context){
    final remaining = 5000 - _controller.text.length;
    return AppLocalizations.of(context).t('characters_left', params: {'count': remaining.toString()});
  }
}

class _FeedbackSheet extends StatefulWidget {
  const _FeedbackSheet();
  @override State<_FeedbackSheet> createState()=> _FeedbackSheetState();
}

class _FeedbackSheetState extends State<_FeedbackSheet> {
  final _form = GlobalKey<FormState>();
  final _msg = TextEditingController();
  final _contact = TextEditingController();
  bool _sending=false; bool _sent=false;
  @override void dispose(){ _msg.dispose(); _contact.dispose(); super.dispose(); }
  Future<void> _submit() async {
    if(!_form.currentState!.validate()) return;
    setState(()=> _sending=true);
    try {
      final cp = context.read<CommunityProvider>();
      await cp.service.submitFeedback(
        message: _msg.text.trim(),
        contact: _contact.text.trim().isEmpty? null : _contact.text.trim(),
      );
      if(mounted){ setState(()=> _sent=true); }
    } catch(_){ /* could show error */ }
    finally { if(mounted) setState(()=> _sending=false); }
  }
  @override Widget build(BuildContext context){
    final t = AppLocalizations.of(context).t;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20,20,20,32),
          child: _sent ? Column(mainAxisSize: MainAxisSize.min, children:[
            Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary, size: 48),
            const SizedBox(height:12),
            Text(t('feedback_thanks'), textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height:20),
            FilledButton(onPressed: ()=> Navigator.pop(context), child: const Text('OK'))
          ]) : Form(
            key: _form,
            child: Column(mainAxisSize: MainAxisSize.min, children:[
              Text(t('feedback'), style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height:16),
              TextFormField(
                controller: _msg,
                maxLines: 6,
                minLines: 3,
                maxLength: 2000,
                validator: (v)=> (v==null || v.trim().length<5)? t('min_chars', params:{'count':'5'}) : null,
                decoration: InputDecoration(labelText: t('feedback'), hintText: t('feedback_hint')),
              ),
              const SizedBox(height:12),
              TextFormField(
                controller: _contact,
                decoration: InputDecoration(labelText: t('contact_optional')),
              ),
              const SizedBox(height:20),
              SizedBox(width: double.infinity, child: FilledButton(onPressed: _sending? null : _submit, child: _sending? const SizedBox(height:18,width:18, child: CircularProgressIndicator(strokeWidth:2)) : Text(t('send'))))
            ])
          ),
        ),
      ),
    );
  }
}
