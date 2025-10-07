import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/content_provider.dart';
import '../providers/auth_provider.dart';
import '../models/news.dart';
import '../ui/content_media_card.dart';
import '../utils/url_utils.dart';
import '../ui/meta_chip.dart';
import '../theme/design_tokens.dart';
import '../icons/app_icons.dart';
import '../utils/responsive.dart';
import 'news_detail_screen.dart';
import 'package:share_plus/share_plus.dart';

/// Modern responsive News tab (parity with Events design philosophy).
/// Features:
/// - List & Grid modes with AnimatedSwitcher transitions
/// - Progressive growth (cap) for fast initial paint
/// - Infinite scroll via ScrollNotification (observer style) + debounce
/// - Prefetch trigger in grid mode
/// - Skeleton placeholders & reserved body space to reduce layout shift
/// - Persisted user layout preference
class NewsTab extends StatefulWidget { const NewsTab({super.key}); @override State<NewsTab> createState()=> _NewsTabState(); }

enum _NewsLayout { list, grid }

class _NewsTabState extends State<NewsTab>{
	_NewsLayout _layout = _NewsLayout.list;
	int _cap = 48; Timer? _grow; int? _firstMs; bool _firstLogged=false; bool _prefetching=false;
	DateTime _lastLoadReq = DateTime.fromMillisecondsSinceEpoch(0);
	Timer? _debounce; // for settings persistence throttle

	@override void initState(){ super.initState(); _restore(); }
	Future<void> _restore() async { final p = await SharedPreferences.getInstance(); final m=p.getString('news_layout'); if(m!=null){ setState(()=> _layout = _NewsLayout.values.firstWhere((e)=> e.name==m, orElse: ()=> _NewsLayout.list)); } }
	Future<void> _persist() async { final p=await SharedPreferences.getInstance(); p.setString('news_layout', _layout.name); }

	void _progressive(int total){ if(total<=_cap || _grow!=null) return; _grow = Timer.periodic(const Duration(milliseconds:120),(t){ if(!mounted){t.cancel();return;} if(_cap>=total){t.cancel(); _grow=null; return;} setState(()=> _cap = math.min(_cap+40,total)); }); }
	void _loadMoreDebounced(){ final now=DateTime.now(); if(now.difference(_lastLoadReq).inMilliseconds < 320) return; _lastLoadReq=now; context.read<ContentProvider>().loadMoreNews(); }
	void _queuePersist(){ _debounce?.cancel(); _debounce = Timer(const Duration(milliseconds:260), _persist); }

	@override Widget build(BuildContext context){
		final cp = context.watch<ContentProvider>();
		final auth = context.watch<AuthProvider>();
		final scheme = Theme.of(context).colorScheme;
		final news = cp.news;
		_firstMs ??= DateTime.now().millisecondsSinceEpoch;
		if(!_firstLogged && news.isNotEmpty){ WidgetsBinding.instance.addPostFrameCallback((_){ if(!_firstLogged){ final d=DateTime.now().millisecondsSinceEpoch-(_firstMs!); // ignore: avoid_print
			print('[perf][news-first] ${d}ms count=${news.length}'); _firstLogged=true; }}); }
		_progressive(news.length);

		return RefreshIndicator(
			onRefresh: () async { await cp.reloadNews(); setState(()=> _cap=48); },
			edgeOffset: 90,
			child: LayoutBuilder(builder:(ctx,constraints){
				final w = constraints.maxWidth; final contentW = maxContentWidth(w); final sidePad = ((w-contentW)/2).clamp(0,600).toDouble(); final wide=w>=1300;
				final gridCols = (){ if(_layout!=_NewsLayout.grid) return 1; final base=(contentW/280).floor(); return base.clamp(2,7); }();

				// META / EXCERPT helpers ------------------------------------------
				List<Widget> meta(NewsItem n){
					final created = n.createdAt;
						final chips=<Widget>[];
						if(created!=null){
							String fmt(DateTime d)=> '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
							chips.add(MetaChip(label: fmt(created), dense:true));
							final age = DateTime.now().difference(created).inHours;
							if(age < 48) chips.add(MetaChip(label: 'Ново', dense:true));
						}
						if(auth.isAuthenticated && n.userId!=null){ chips.add(MetaChip(label: 'Автор #${n.userId}', dense:true)); }
						return chips;
				}
				String excerpt(String raw){ final c = raw.replaceAll(RegExp(r'<[^>]+>'), ''); return c.length>180? '${c.substring(0,180)}…' : c; }

				// Unified list/grid strategy -------------------------------------
					Widget buildCard(NewsItem n, {required bool compact}){
						final card = ContentMediaCard(
						heroTag: compact? null : 'news_img_${n.id}',
						imageUrl: absUrl(n.cover ?? n.image),
						title: n.title,
						body: compact? null : excerpt(n.content),
						metaChips: meta(n),
						memCacheOverride: compact? 420 : null,
						onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> NewsDetailScreen(news: n))),
						heroPrecache: !compact,
						heroEnableFade: !compact,
						onShare: (){
						  final link = absUrl('/news/${n.id}');
						  Share.share('${n.title}${link!=null? '\n$link':''}', subject: n.title);
						},
						onLike: null, // TODO: wire like endpoint
						onComment: null, // TODO: open comments sheet
						likesCount: n.likesCount,
						commentsCount: n.commentsCount,
						);
						return card;
				}
				SliverMultiBoxAdaptorWidget sliverStrategy(){
					if(_layout==_NewsLayout.grid){
						final effectiveCount = math.min(math.max(news.length, news.length+gridCols), _cap + gridCols*2);
						return SliverGrid(
							gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: gridCols, crossAxisSpacing:18, mainAxisSpacing:18, childAspectRatio: w>1700? 16/8.5 : 16/10),
							delegate: SliverChildBuilderDelegate((ctx,i){
								if(i>=effectiveCount) return const SizedBox.shrink();
								if(i>=news.length) return const ContentMediaCardSkeleton();
								if(i>=_cap) return const ContentMediaCardSkeleton();
								final n = news[i];
								try{ return buildCard(n, compact:true); } catch(err,st){ // ignore: avoid_print
									print('[news][grid-card-error] $err\n$st'); return const Card(child: Padding(padding: EdgeInsets.all(12), child: Text('Грешка'))); }
							}, childCount: effectiveCount, addAutomaticKeepAlives:false, addRepaintBoundaries:true, addSemanticIndexes:false),
						);
					}
					return SliverList(delegate: SliverChildBuilderDelegate((ctx,i){
						if(i>=news.length) return const SizedBox.shrink();
						if(i>=_cap) return const Padding(padding: EdgeInsets.only(bottom: AppTokens.space4), child: ContentMediaCardSkeleton(showImage:true, bodyLines:0, showMeta:false));
						final n=news[i];
						try{ return Padding(padding: EdgeInsets.fromLTRB(16+sidePad,0,16+sidePad,AppTokens.space4), child: buildCard(n, compact:false)); }catch(err,st){ // ignore: avoid_print
							print('[news][card-error] $err\n$st'); return Padding(padding: EdgeInsets.fromLTRB(16+sidePad,0,16+sidePad,AppTokens.space4), child: ListTile(title: Text(n.title), subtitle: const Text('Грешка при визуализация'))); }
					}, childCount: math.min(news.length, _cap+6), addRepaintBoundaries:true, addAutomaticKeepAlives:false, addSemanticIndexes:false));
				}

				// EMPTY -----------------------------------------------------------
				Widget emptyState(){
					return Padding(padding: EdgeInsets.fromLTRB(24+sidePad, 60, 24+sidePad, 160), child: Column(children:[
						AppIcons.news(color: scheme.onSurface.withOpacity(.35), size: 58), const SizedBox(height:16),
						Text('Няма публикации', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
						const SizedBox(height:8),
						Text('Все още няма новини. Опитайте отново по-късно.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurface.withOpacity(.6))),
					]));
				}

				// FILTERS / MODE BAR (only mode for now) -------------------------
				   Widget modeBar(){
					   final isDark = Theme.of(context).brightness == Brightness.dark;
					   final iconColor = isDark ? Colors.white : Colors.black;
					   return Wrap(spacing:8, runSpacing:8, children:[
						   SegmentedButton<_NewsLayout>(
							   segments: [
								   ButtonSegment(
									   value: _NewsLayout.list,
									   icon: Icon(Icons.view_list, color: iconColor),
									   label: const Text('Списък'),
								   ),
								   // Removed grid option
							   ],
							   selected: <_NewsLayout>{_layout},
							   onSelectionChanged: (s){ setState(()=> _layout=s.first); _queuePersist(); },
							   style: ButtonStyle(visualDensity: VisualDensity.compact),
						   ),
					   ]);
				   }

																	final slivers = <Widget>[
																		SliverToBoxAdapter(
																			child: Container(
																				margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 0),
																				constraints: const BoxConstraints(maxWidth: 600),
																				padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
																				decoration: BoxDecoration(
																					color: Theme.of(context).colorScheme.surface,
																					borderRadius: BorderRadius.circular(28),
																					boxShadow: [BoxShadow(color: Colors.black.withOpacity(.07), blurRadius: 14, offset: const Offset(0,6))],
																				),
																				child: Text(
																					'Новини',
																					style: Theme.of(context).textTheme.headlineMedium?.copyWith(
																						fontWeight: FontWeight.w700,
																						fontSize: 28,
																						letterSpacing: -0.5,
																					),
																				),
																			),
																		),
																				SliverToBoxAdapter(
																					child: Center(
																						child: Container(
																							margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
																							constraints: const BoxConstraints(maxWidth: 600),
																							child: Column(
																								children: [
																									...news.map((n) => Container(
																										margin: const EdgeInsets.only(bottom: 32),
																										padding: const EdgeInsets.all(24),
																										decoration: BoxDecoration(
																											color: Theme.of(context).colorScheme.surface,
																											borderRadius: BorderRadius.circular(28),
																											boxShadow: [BoxShadow(color: Colors.black.withOpacity(.07), blurRadius: 14, offset: const Offset(0,6))],
																										),
																										child: Column(
																											crossAxisAlignment: CrossAxisAlignment.start,
																											children: [
																												if (n.image != null) ...[
																													Center(
																														child: Image.network(n.image!, height: 180, fit: BoxFit.contain),
																													),
																													const SizedBox(height: 18),
																												],
																												Text(n.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
																												// Премахнат subtitle/content
																												const SizedBox(height: 12),
																												Container(
																													padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
																													decoration: BoxDecoration(
																														color: Theme.of(context).colorScheme.surfaceVariant,
																														borderRadius: BorderRadius.circular(18),
																													),
																													child: Text(
																														n.createdAt != null
																																? '${n.createdAt!.year}-${n.createdAt!.month.toString().padLeft(2,'0')}-${n.createdAt!.day.toString().padLeft(2,'0')}'
																																: '',
																														style: Theme.of(context).textTheme.bodySmall,
																													),
																												),
																											],
																										),
																									)),
																								],
																							),
																						),
																					),
																				),
																];

				if(news.isEmpty && (cp.loading)){
					slivers.add(SliverPadding(padding: EdgeInsets.fromLTRB(16+sidePad,16,16+sidePad,120), sliver: SliverList(delegate: SliverChildBuilderDelegate((_,i)=> const Padding(padding: EdgeInsets.only(bottom:AppTokens.space4), child: ContentMediaCardSkeleton()), childCount: 6))));
				} else {
					   if(!wide){ slivers.add(SliverToBoxAdapter(child: Padding(padding: EdgeInsets.fromLTRB(16+sidePad,8,16+sidePad,8), child: modeBar()))); }
					   if(news.isEmpty){ slivers.add(SliverToBoxAdapter(child: emptyState())); }
					   else { final strat = sliverStrategy(); slivers.add(strat); }
					   if(cp.newsLoadingMore){ slivers.add(const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.symmetric(vertical:26), child: Center(child: SizedBox(width:30,height:30, child: CircularProgressIndicator(strokeWidth:2.2)))))); }
					   if(!cp.newsLoadingMore && !cp.newsHasMore && news.isNotEmpty){ slivers.add(SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.symmetric(vertical:30), child: Center(child: Text('Няма повече новини', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurface.withOpacity(.6))))))); }
					   slivers.add(SliverToBoxAdapter(child: SizedBox(height: MediaQuery.of(context).padding.bottom + 110)));
				}

				Widget scrollContent = NotificationListener<ScrollNotification>(
					onNotification: (n){
						if(n.metrics.maxScrollExtent<=0) return false;
						final ratio = (n.metrics.pixels / n.metrics.maxScrollExtent).clamp(0,1);
						if(ratio>=.70){ _loadMoreDebounced(); }
						else if(ratio>=.55 && _layout==_NewsLayout.grid && !_prefetching){
							if(cp.newsHasMore && !cp.newsLoadingMore){ _prefetching=true; cp.loadMoreNews().whenComplete(()=> _prefetching=false); }
						}
						return false;
					},
					child: CustomScrollView(slivers: slivers, physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics())),
				);
								Widget scroll = AnimatedSwitcher(
									duration: const Duration(milliseconds: 400),
									switchInCurve: Curves.easeIn,
									switchOutCurve: Curves.easeOut,
									transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
									child: KeyedSubtree(key: ValueKey(_layout), child: scrollContent),
								);
				if(!wide) return scroll;
				return Row(crossAxisAlignment: CrossAxisAlignment.start, children:[
					SizedBox(width: 240, child: SingleChildScrollView(padding: EdgeInsets.fromLTRB(16+sidePad,140,12,180), child: modeBar())),
					Expanded(child: scroll),
				]);
			}),
		);
	}

	@override void dispose(){ _grow?.cancel(); _debounce?.cancel(); super.dispose(); }
}
