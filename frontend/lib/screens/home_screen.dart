import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/content_provider.dart';
// import 'settings_screen.dart'; // removed from nav
import 'news_detail_screen.dart';
import 'events_tab.dart';
import '../icons/app_icons.dart';
import 'profile_screen.dart';
import '../ui/shimmer.dart';
import '../utils/url_utils.dart';
import '../ui/adaptive_scaffold.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event.dart';
import '../models/news.dart';
import '../ui/meta_chip.dart';
import 'dart:typed_data';
import '../ui/content_media_card.dart';
import '../theme/responsive_factors.dart';
import 'community_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget { const HomeScreen({super.key}); @override State<HomeScreen> createState()=> _HomeScreenState(); }
class _HomeScreenState extends State<HomeScreen>{
  int _tab = 0; // 0 news, 1 events, 2 community, 3 profile
  bool _refreshing=false;
  final Map<int,String> _newsExcerptCache = {}; // cache excerpts
  final ScrollController scrollControllerNews = ScrollController();
  @override void initState(){
    super.initState();
    Future.microtask(() async {
  await SharedPreferences.getInstance(); // reserved for future persisted UI state (theme etc.)
      // Always start on News tab (0) – ignore previously persisted tab
      _tab = 0;
      await context.read<ContentProvider>().loadAll();
    });
  }

  Future<void> _refresh() async {
    if(_refreshing) return; setState(()=> _refreshing=true);
    try {
      await context.read<ContentProvider>().loadAll();
    } finally { if(mounted) setState(()=> _refreshing=false); }
  }

  bool _isVersionNewer(String remote,String local){
    List<int> parse(String v)=> v.split('.').map((e)=> int.tryParse(e)??0).toList();
    final r=parse(remote); final l=parse(local); final len=r.length>l.length?r.length:l.length; for(int i=0;i<len;i++){ final rv=i<r.length?r[i]:0; final lv=i<l.length?l[i]:0; if(rv>lv) return true; if(rv<lv) return false; } return false;
  }

  // All event filtering & rendering logic moved to EventsTab for modularity

  @override Widget build(BuildContext context){
    final auth = context.watch<AuthProvider>();
    final content = context.watch<ContentProvider>();
    final latest = content.latest;
    final currentVersion = '1.0.0';
    final showUpdate = latest!=null && _isVersionNewer(latest.versionName, currentVersion) && !auth.versionDismissed(latest.versionName);

    Widget buildNews(){
          // Sort news by newest first (descending by createdAt)
          final items = List<NewsItem>.from(content.news)
            ..sort((a, b) => (b.createdAt ?? DateTime(2000)).compareTo(a.createdAt ?? DateTime(2000)));
      final provider = content;
      return RefreshIndicator(
    onRefresh: _refresh,
        edgeOffset: 110,
        child: LayoutBuilder(builder: (ctx, constraints){
          final width = constraints.maxWidth;
          final contentWidth = 540.0;
          final sidePad = ((width - contentWidth)/2).clamp(0, 500).toDouble();
          final factors = context.responsive;
          final textScale = factors.textScale;
          final padding = EdgeInsets.only(top:8, bottom: MediaQuery.of(context).padding.bottom + 120);
          if((content.loading && items.isEmpty)){
            // skeleton feed
            return ListView.builder(
              padding: EdgeInsets.only(left: sidePad, right: sidePad, top: 24, bottom: MediaQuery.of(context).padding.bottom + 120),
              itemCount: 6,
              itemBuilder: (_,i)=> Center(child: SizedBox(width: contentWidth, child: ContentMediaCardSkeleton())),
            );
          }
          return NotificationListener<ScrollNotification>(
            onNotification: (n){
              if(provider.newsHasMore && !provider.newsLoadingMore && n.metrics.pixels >= n.metrics.maxScrollExtent - 320){
                provider.loadMoreNews();
              }
              return false;
            },
            child: CustomScrollView(
              controller: scrollControllerNews,
              slivers: [
                SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 24, left: 32, right: 32, bottom: 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Начало',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 28,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
                if(showUpdate) SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(16,12,16,6), child: _UpdateBanner(info: latest))),
                SliverPadding(
                  padding: EdgeInsets.only(left: sidePad, right: sidePad, bottom: MediaQuery.of(context).padding.bottom + 120),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((ctx,i){
                      final n = items[i];
                      final excerpt = _newsExcerptCache.putIfAbsent(n.id, (){ final clean = n.content.replaceAll(RegExp(r'<[^>]+>'), ''); return clean.length>160? '${clean.substring(0,160)}…' : clean; });
                      final showMeta = items.length <= 40 || i < 40;
                      Widget card = ContentMediaCard(
                        heroTag: 'news_img_list_${n.id}',
                        imageUrl: (n.cover != null && n.cover!.trim().isNotEmpty)
                          ? absUrl(n.cover)
                          : (n.image != null && n.image!.trim().isNotEmpty)
                            ? absUrl(n.image)
                            : (n.images.isNotEmpty && n.images.first.trim().isNotEmpty)
                              ? absUrl(n.images.first)
                              : null,
                        title: n.title,
                        body: excerpt,
                        metaChips: showMeta ? buildNewsMetaChips(n) : const [],
                        textScale: textScale,
                        disableHover: _isTouchPlatform(context),
                        onTap: () => Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => NewsDetailScreen(news: n),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              const begin = Offset(0.0, 1.0);
                              const end = Offset.zero;
                              const curve = Curves.ease;
                              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                              return SlideTransition(
                                position: animation.drive(tween),
                                child: child,
                              );
                            },
                          ),
                        ),
                      );
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        switchInCurve: Curves.easeIn,
                        switchOutCurve: Curves.easeOut,
                        transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                        child: Column(
                          key: ValueKey(n.id),
                          children: [
                            if (i == 0)
                              const SizedBox(height: 32),
                            Center(child: SizedBox(width: contentWidth, child: RepaintBoundary(child: card))),
                            if (i < items.length - 1)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 18.0),
                                child: Divider(thickness: 1.2, indent: 32, endIndent: 32),
                              ),
                          ],
                        ),
                      );
                    }, childCount: items.length),
                  ),
                ),
                if(provider.newsLoadingMore)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical:24),
                      child: Center(child: SizedBox(width: contentWidth, child: Shimmer(width: double.infinity, height: 220, radius: BorderRadius.all(Radius.circular(22))))),
                    ),
                  ),
                if(!provider.newsLoadingMore && !provider.newsHasMore && items.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical:24),
                      child: Center(child: Text('Няма повече новини', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(.6)))),
                    ),
                  ),
              ],
            ),
          );
        }),
      );
    }

    // Events handled by EventsTab

    final pages = <Widget>[
      Stack(children:[buildNews()]),
      const EventsTab(),
      const CommunityScreen(),
      const ProfileScreen(),
    ];

    return AdaptiveScaffold(
      index: _tab,
      onIndexChanged: (i) async { if(_tab==i) return; setState(()=> _tab=i); },
      items: [
        AdaptiveNavItem(label: 'Новини', iconBuilder: (sel,scheme)=> AppIcons.news(color: sel? scheme.primary : scheme.onSurfaceVariant)),
        AdaptiveNavItem(label: 'Събития', iconBuilder: (sel,scheme)=> AppIcons.events(color: sel? scheme.primary : scheme.onSurfaceVariant)),
        AdaptiveNavItem(label: 'Общност', iconBuilder: (sel,scheme)=> Icon(Icons.forum, color: sel? scheme.primary : scheme.onSurfaceVariant)),
        AdaptiveNavItem(label: 'Профил', iconBuilder: (sel,scheme)=> AppIcons.person(color: sel? scheme.primary : scheme.onSurfaceVariant)),
      ],
      // App bar replaced by per-tab collapsing SliverAppBars
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds:300),
        child: pages[_tab],
      ),
    );
  }
}

// Sidebar + nav tiles removed for consumer mobile-first layout
// class _SettingsEmbed extends StatelessWidget { const _SettingsEmbed(); @override Widget build(BuildContext context){ return const SettingsScreen(); }}

class _UpdateBanner extends StatelessWidget {
  final dynamic info;
  const _UpdateBanner({required this.info});
  @override
  Widget build(BuildContext context){
    final auth = context.read<AuthProvider>();
    final scheme = Theme.of(context).colorScheme;
    return Dismissible(
      key: ValueKey('update-${info.versionName}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_){ auth.dismissVersion(info.versionName); },
      background: Container(
        color: scheme.onSurface,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal:16),
        child: AppIcons.close(color: scheme.onPrimary),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: scheme.outline),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          title: const Text('Налична е нова версия'),
          subtitle: Text(info.versionName),
        ),
      ),
    );
  }
}


// _NewsCard removed – replaced by ContentMediaCard abstraction

// _EventCard removed; events now handled inside EventsTab

// removed erroneous top-level function; logic moved inside state

// Removed color persistence helpers (now handled within EventsTab if needed)


// Replaced by MetaChip

// _HeroImage removed (handled by ContentMediaCard)

// (Search UI removed)

// _SecondaryBar removed (no secondary action strip needed in monochrome minimal design)

String _eventPeriod(dynamic e){
  DateTime? sd = e.startDate as DateTime?; DateTime? ed = e.endDate as DateTime?; if(sd==null) return '—';
  String fmt(DateTime d)=> '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
  final base = fmt(sd);
  if(ed!=null && ed.isAfter(sd)) return '$base → ${fmt(ed)}';
  return base;
}

// Gradient app bar background
class _GradientAppBarBackdrop extends StatelessWidget { // flat neutral background with subtle bottom divider
  const _GradientAppBarBackdrop();
  @override Widget build(BuildContext context){
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withOpacity(.6))),
      ),
    );
  }
}

// Replaced by MetaChip

List<Widget> buildNewsMetaChips(NewsItem n){
  final chips = <Widget>[];
  final date = n.createdAt!=null? _fmtYMD(n.createdAt!) : '';
  if(date.isNotEmpty) chips.add(MetaChip(label: date, dense: true));
  // Placeholder tags (in future backend could return categories / tags array)
  if(n.title.toLowerCase().contains('важно')) chips.add(const MetaChip(label: 'Важно', dense: true));
  if((n.content).length > 400) chips.add(const MetaChip(label: 'Дълго', dense: true));
  return chips;
}

List<Widget> buildEventMetaChips(EventItem e, {Color? cityColor}){
  final chips = <Widget>[];
  final date = _eventPeriod(e);
  chips.add(MetaChip(label: date, dense: true));
  if(cityColor!=null) chips.add(MetaChip(label: '', dotColor: cityColor, dense: true));
  if(e.isPast) chips.add(const MetaChip(label: 'Минало', dense: true));
  if((e.status ?? 'active')!='active') chips.add(MetaChip(label: 'Неактивно', dense: true));
  if(e.limit!=null && e.registrationsCount!=null){
    final remaining = (e.limit!-e.registrationsCount!.clamp(0,e.limit!));
    chips.add(MetaChip(label: 'Места $remaining/${e.limit}', dense: true));
  }
  // Derived tags example
  if((e.type ?? '').toString().isNotEmpty) chips.add(MetaChip(label: (e.type ?? '').toString(), dense: true));
  if((e.audience ?? '').toString().isNotEmpty) chips.add(MetaChip(label: (e.audience ?? '').toString(), dense: true));
  return chips;
}


String _fmtYMD(DateTime d)=> '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';

// 1x1 transparent PNG bytes
final Uint8List kTransparentImage = Uint8List.fromList(const <int>[
  0x89,0x50,0x4E,0x47,0x0D,0x0A,0x1A,0x0A,0x00,0x00,0x00,0x0D,0x49,0x48,0x44,0x52,
  0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x01,0x08,0x06,0x00,0x00,0x00,0x1F,0x15,0xC4,
  0x89,0x00,0x00,0x00,0x0A,0x49,0x44,0x41,0x54,0x78,0xDA,0x63,0x60,0x00,0x00,0x00,
  0x02,0x00,0x01,0xE2,0x26,0x05,0x9B,0x00,0x00,0x00,0x00,0x49,0x45,0x4E,0x44,0xAE,
  0x42,0x60,0x82
]);

// MetaChip moved to ui/meta_chip.dart

bool _isTouchPlatform(BuildContext context){
  // Heuristic: treat web desktop (large width + mouse) as non-touch; others touch.
  final width = MediaQuery.of(context).size.width;
  // If width large assume desktop; otherwise touch
  if(width > 900) return false;
  return true;
}

