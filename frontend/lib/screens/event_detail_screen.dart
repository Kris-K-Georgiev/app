import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../models/event.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../utils/ics.dart';
import '../ui/shimmer.dart';
import '../icons/app_icons.dart';
import '../ui/typography.dart';
import 'package:flutter_html/flutter_html.dart';
import '../utils/html_sanitizer.dart';

class EventDetailScreen extends StatefulWidget {
  final EventItem event;
  const EventDetailScreen({super.key, required this.event});
  @override State<EventDetailScreen> createState()=> _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen>{
  bool loading=false; bool registered=false; String? error; String? regStatus; // confirmed | waitlist | removed | already
  Future<void> _toggle() async {
    if(loading) return; setState(()=> loading=true);
    try {
      final auth = context.read<AuthProvider>();
      final api = auth.api;
      final path = registered? '/events/${widget.event.id}/unregister' : '/events/${widget.event.id}/register';
      final resp = await api.post(path, {});
      if(mounted){
        regStatus = resp['status']?.toString();
        if(regStatus == 'removed'){ registered = false; regStatus = null; }
        else if(regStatus == 'confirmed' || regStatus == 'waitlist' || regStatus == 'already'){ registered = true; }
        setState((){});
      }
    } catch(e){ if(mounted) setState(()=> error=e.toString()); }
    finally { if(mounted) setState(()=> loading=false); }
  }
  @override Widget build(BuildContext context){
    final event = widget.event;
    final dfDate = DateFormat('yyyy-MM-dd');
    String dateText; 
    if(event.startDate!=null && event.endDate!=null){
      // If same day, show only once
      if(dfDate.format(event.startDate!) == dfDate.format(event.endDate!)){
        dateText = dfDate.format(event.startDate!);
      } else {
        dateText = '${dfDate.format(event.startDate!)} – ${dfDate.format(event.endDate!)}';
      }
    } else if(event.startDate!=null){
      dateText = dfDate.format(event.startDate!);
    } else {
      dateText = dfDate.format(event.primaryDate);
    }
    // Days count (fallback compute if backend omitted it)
    int? days = event.days;
    if(days == null && event.startDate!=null){
      if(event.endDate!=null){
        days = event.endDate!.difference(event.startDate!).inDays + 1;
      } else {
        days = 1;
      }
    }
    if(days!=null){
      dateText += days == 1 ? ' (1 ден)' : ' ($days дни)';
    }
    final isPast = (event.endDate ?? event.startDate ?? event.primaryDate).isBefore(DateTime.now());
  final neutral = Theme.of(context).colorScheme.onSurface;
  final statusIcon = regStatus=='waitlist'? AppIcons.statusWaitlist(color: neutral.withOpacity(.7)) : (regStatus=='confirmed'||regStatus=='already'? AppIcons.statusConfirmed(color: neutral) : null);
    return Scaffold(
      appBar: AppBar(title: const Text('Събитие', style: TextStyle(fontWeight: FontWeight.w700,
                        fontSize: 28,
                        letterSpacing: -0.5,))),
      bottomNavigationBar: _buildBottomCta(context, isPast),
      body: ListView(padding: const EdgeInsets.only(bottom:120, left:16, right:16, top:16), children:[
        // Secondary action bar
        Row(children:[
          IconButton(tooltip:'Сподели', onPressed: ()=> _shareEvent(event), icon: AppIcons.share()),
          IconButton(tooltip:'Календар', onPressed: ()=> _addToCalendar(event), icon: AppIcons.calendarAdd()),
          if(statusIcon!=null) Padding(padding: const EdgeInsets.only(left:4), child: statusIcon),
        ]),
        const SizedBox(height:16),
        Row(children:[
          Expanded(child: Text(dateText, style: AppTypography.section(context))),
          if(isPast) Container(padding: const EdgeInsets.symmetric(horizontal:10, vertical:4), decoration: BoxDecoration(color: Theme.of(context).dividerColor.withOpacity(.15), borderRadius: BorderRadius.circular(20)), child: Row(children:[AppIcons.history(size:14, color: neutral.withOpacity(.75)), const SizedBox(width:4), Text('Минало', style: AppTypography.bodySm(context).copyWith(color: neutral.withOpacity(.75)))]))
        ]),
        if(event.startTime!=null)
          Padding(
            padding: const EdgeInsets.only(top:4.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children:[
                AppIcons.schedule(size:16, color: neutral.withOpacity(.8)),
                const SizedBox(width:4),
                Text(event.startTime!, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        const SizedBox(height:8),
        Wrap(spacing:12, runSpacing:6, children: [
          if(event.location!=null) _chip(icon: AppIcons.location(color: neutral.withOpacity(.8), size:14), label: event.location!),
          if(event.city!=null) _chip(icon: AppIcons.city(color: neutral.withOpacity(.8), size:14), label: event.city!),
          if(event.audience!=null) _chip(icon: AppIcons.audience(color: neutral.withOpacity(.8), size:14), label: _audLabel(event.audience!)),
          if(event.limit!=null) _chip(icon: AppIcons.people(color: neutral.withOpacity(.8), size:14), label: 'Лимит: ${event.limit}'),
          if(regStatus=='waitlist') _chip(icon: AppIcons.hourglass(color: neutral.withOpacity(.8), size:14), label: 'В лист на изчакване'),
          if(event.limit!=null && event.registrationsCount!=null)
            _spotsChip(limit: event.limit!, used: event.registrationsCount!),
        ]),
        if(event.images.isNotEmpty || event.cover!=null) ...[
          const SizedBox(height:24),
          Text('Снимки', style: AppTypography.section(context)),
          const SizedBox(height:12),
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _gallerySources(event).length,
              separatorBuilder: (_, __) => const SizedBox(width:12),
              itemBuilder: (_, i){
                final src = _gallerySources(event)[i];
                final tag = i==0? 'event_img_list_${event.id}' : 'ev-img-${event.id}-$i-${src.hashCode}';
                return GestureDetector(
                  onTap: ()=> _openGallery(event, i),
                  child: Hero(
                    tag: tag,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio: 4/3,
                        child: _GalleryImage(src: src),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
    const Divider(height:32),
    _renderDescription(event.description),
        const SizedBox(height:32),
        // Informational section only (CTA fixed below)
        Consumer<AuthProvider>(builder: (ctx, auth, _) {
          if(!auth.isAuthenticated){
            return Padding(
              padding: const EdgeInsets.only(top:8),
              child: Text('Моля влезте, за да се регистрирате.', style: Theme.of(context).textTheme.bodySmall),
            );
          }
          if(error!=null) return Text(error!, style: AppTypography.bodySm(context).copyWith(color: Theme.of(context).colorScheme.error));
          return const SizedBox.shrink();
        }),
        if(regStatus!=null) Padding(
          padding: const EdgeInsets.only(top:12),
          child: Text(
            regStatus=='waitlist' ? 'Статус: в лист на изчакване' : (regStatus=='confirmed' || regStatus=='already' ? 'Статус: записан' : ''),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ]),
    );
  }

  Widget _chip({required Widget icon, required String label}){
    return Container(
      padding: const EdgeInsets.symmetric(horizontal:10, vertical:6),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children:[ icon, const SizedBox(width:4), Text(label, style: AppTypography.bodySm(context)) ]),
    );
  }

  String _audLabel(String raw){
    switch(raw){
      case 'open': return 'Отворено';
      case 'city': return 'По град';
      case 'limited': return 'Ограничено';
      default: return raw;
    }
  }

  Widget _buildBottomCta(BuildContext context, bool isPast){
    return Consumer<AuthProvider>(builder: (ctx, auth, _){
      final disabled = isPast || !auth.isAuthenticated || loading;
      String label;
      if(isPast) {
        label = 'Изтекло';
      } else if(!registered) label = 'Запиши се';
      else if(regStatus == 'waitlist') label = 'В лист (отпиши)';
      else label = 'Отпиши се';
      Widget? capacityBar;
      if(widget.event.limit!=null && widget.event.registrationsCount!=null){
        final limit = widget.event.limit!; final used = widget.event.registrationsCount!.clamp(0, limit); final pct = limit==0?0.0: used/limit;
        Color barColor;
        if(pct>=1) {
          barColor = Theme.of(context).colorScheme.error;
        } else if(pct>.75) barColor = Theme.of(context).colorScheme.primary.withOpacity(.9);
        else barColor = Theme.of(context).colorScheme.primary.withOpacity(.6);
        capacityBar = Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              minHeight: 6,
              value: pct.clamp(0,1),
              color: barColor,
              backgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(.08),
            ),
          ),
          const SizedBox(height:6),
          Text(used>=limit? 'Няма свободни места' : 'Свободни: ${limit-used} / $limit', style: Theme.of(context).textTheme.labelSmall)
        ]);
      }
      return SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16,12,16,12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(top: BorderSide(color: Theme.of(context).dividerColor.withOpacity(.4)))
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children:[
              if(capacityBar!=null) capacityBar,
              if(capacityBar!=null) const SizedBox(height:10),
              ElevatedButton.icon(
                onPressed: disabled? null : _toggle,
                icon: loading? const SizedBox(width:16,height:16, child: CircularProgressIndicator(strokeWidth:2)) : (registered? AppIcons.closeIcon(size:20) : AppIcons.check(size:20)),
                label: Text(label),
              )
            ],
          ),
        ),
      );
    });
  }

  void _openGallery(EventItem event, int index){
    Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black.withOpacity(0.9),
      pageBuilder: (_, anim, __){
        return FadeTransition(
          opacity: anim,
          child: _GalleryViewer(event: event, initial: index),
        );
      },
      transitionDuration: const Duration(milliseconds:250),
      reverseTransitionDuration: const Duration(milliseconds:220),
    ));
  }

  List<String> _gallerySources(EventItem e){
    final set = <String>{};
    if(e.cover!=null && e.cover!.isNotEmpty) set.add(e.cover!);
    for(final img in e.images){ if(img.isNotEmpty) set.add(img); }
    return set.toList();
  }

  void _shareEvent(EventItem e) async {
    final url = 'https://bhss.app/events/${e.id}';
    final text = 'Събитие: ${e.title} $url';
    try {
      await Share.share(text, subject: e.title);
    } catch(_) {
      await Clipboard.setData(ClipboardData(text: text));
      if(mounted){ ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Линкът е копиран'))); }
    }
  }

  void _addToCalendar(EventItem e) async {
    final start = (e.startDate ?? e.primaryDate);
    final end = (e.endDate ?? e.startDate ?? e.primaryDate);
    final ics = buildEventIcs(id: e.id, title: e.title, description: e.description, start: start, end: end);
    try {
      final file = await writeIcsTemp(ics, filename: 'event_${e.id}.ics');
      await Share.shareXFiles([XFile(file.path, mimeType: 'text/calendar', name: 'event_${e.id}.ics')], text: 'Добави в календар: ${e.title}');
    } catch(err){
      await Clipboard.setData(ClipboardData(text: ics));
      if(mounted){ ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('iCal копирано (постави ръчно)'))); }
    }
  }
  Widget _spotsChip({required int limit, required int used}){
    final remaining = (limit - used).clamp(0, limit);
    final pct = limit==0? 0.0 : (used/limit).clamp(0,1);
    final base = Theme.of(context).colorScheme.onSurface;
    final color = pct >= 1 ? base.withOpacity(.85) : (pct > .7 ? base.withOpacity(.55) : base.withOpacity(.35));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal:10, vertical:6),
      decoration: BoxDecoration(color: color.withOpacity(.12), borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children:[
        AppIcons.seat(size:14, color: color), const SizedBox(width:4),
        Text(remaining>0? 'Места: $remaining' : 'Няма места', style: AppTypography.bodySm(context).copyWith(color: color))
      ]),
    );
  }

  Widget _renderDescription(String? raw){
    if(raw==null || raw.trim().isEmpty) return Text('Няма описание', style: AppTypography.body(context));
    final looksHtml = raw.contains('<p') || raw.contains('<br') || raw.contains('<h') || raw.contains('<img') || raw.contains('<ul') || raw.contains('<li');
    if(!looksHtml){
      return Text(raw, style: AppTypography.body(context));
    }
    final safe = sanitizeHtml(raw);
    return Html(
      data: safe,
      style: {
        'body': Style(margin: Margins.zero, padding: HtmlPaddings.all(0), lineHeight: const LineHeight(1.35)),
        'p': Style(margin: Margins.only(bottom: 12)),
      },
    );
  }
}

class _GalleryImage extends StatefulWidget {
  final String src; const _GalleryImage({required this.src});
  @override State<_GalleryImage> createState()=> _GalleryImageState();
}
class _GalleryImageState extends State<_GalleryImage>{
  bool _loaded=false; bool _error=false; ImageStream? _stream;
  @override void initState(){ super.initState(); _resolve(); }
  void _resolve(){ final img = Image.network(widget.src); _stream = img.image.resolve(const ImageConfiguration()); _stream!.addListener(ImageStreamListener((info, _){ if(mounted) setState(()=> _loaded=true); }, onError: (_, __){ if(mounted) setState(()=> _error=true); })); }
  @override void didUpdateWidget(covariant _GalleryImage old){ super.didUpdateWidget(old); if(old.src!=widget.src){ _loaded=false; _error=false; _resolve(); } }
  @override void dispose(){ _stream?.removeListener(ImageStreamListener((_,__){ })); super.dispose(); }
  @override Widget build(BuildContext context){
  if(_error) return Container(color: Colors.grey.shade300, child: AppIcons.brokenImage(color: Colors.grey.shade600));
    if(!_loaded) return const Shimmer(width: double.infinity, height: double.infinity, radius: BorderRadius.zero);
    return Image.network(widget.src, fit: BoxFit.cover);
  }
}

class _GalleryViewer extends StatefulWidget {
  final EventItem event; final int initial;
  const _GalleryViewer({required this.event, required this.initial});
  @override State<_GalleryViewer> createState()=> _GalleryViewerState();
}
class _GalleryViewerState extends State<_GalleryViewer>{
  late final PageController _pc; late int idx;
  List<String> get _sources => _gallerySources(widget.event);
  @override void initState(){ super.initState(); idx = widget.initial; _pc = PageController(initialPage: idx); }
  @override void dispose(){ _pc.dispose(); super.dispose(); }
  double _dragOffset = 0.0; bool _closing=false;
  @override Widget build(BuildContext context){
    final opacity = (_closing? (1 - (_dragOffset.abs()/300).clamp(0,1)) : 1.0);
    return GestureDetector(
      onVerticalDragUpdate: (d){
        setState(()=> _dragOffset += d.delta.dy);
      },
      onVerticalDragEnd: (d){
        if(_dragOffset>140){ _closing=true; Navigator.pop(context); } else { setState(()=> _dragOffset=0); }
      },
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(opacity.toDouble()),
        body: Transform.translate(
          offset: Offset(0,_dragOffset),
          child: Stack(children:[
            PageView.builder(
              controller: _pc,
              onPageChanged: (i)=> setState(()=> idx=i),
              itemCount: _sources.length,
              itemBuilder: (_, i){
                final src = _sources[i];
                final tag = i==0? 'event_img_list_${widget.event.id}' : 'ev-img-${widget.event.id}-$i-${src.hashCode}';
                return Center(
                  child: Hero(
                    tag: tag,
                    child: InteractiveViewer(
                      minScale: .8,
                      maxScale: 4,
                      child: Image.network(src, fit: BoxFit.contain, errorBuilder: (_,__,___)=> AppIcons.brokenImage(color: Colors.white70, size:64)),
                    ),
                  ),
                );
              },
            ),
            Positioned(top: 40, left: 16, right: 16, child: Row(children:[
              IconButton(onPressed: ()=> Navigator.pop(context), icon: AppIcons.closeIcon(color: Colors.white)),
              const Spacer(),
              Container(padding: const EdgeInsets.symmetric(horizontal:12, vertical:6), decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(24)), child: Text('${idx+1}/${_sources.length}', style: const TextStyle(color: Colors.white)))
            ]))
          ]),
        ),
      ),
    );
  }
  List<String> _gallerySources(EventItem e){
    final set = <String>{};
    if(e.cover!=null && e.cover!.isNotEmpty) set.add(e.cover!);
    for(final img in e.images){ if(img.isNotEmpty) set.add(img); }
    return set.toList();
  }
}

