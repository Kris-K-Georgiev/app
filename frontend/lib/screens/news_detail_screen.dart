import 'package:flutter/material.dart';
import '../models/news.dart';
import '../utils/url_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'news_image_viewer.dart';
import '../theme/shad_theme.dart';
import 'package:flutter_html/flutter_html.dart';
import '../utils/html_sanitizer.dart';

class NewsDetailScreen extends StatelessWidget {
  final NewsItem news;
  const NewsDetailScreen({super.key, required this.news});
  @override
  Widget build(BuildContext context){
    return ShadShell(
      appBar: AppBar(title: const Text('', style: TextStyle(fontWeight: FontWeight.w700))),
      body: _NewsDetailBody(news: news),
    );
  }
}

class _NewsDetailBody extends StatefulWidget {
  final NewsItem news;
  const _NewsDetailBody({required this.news});
  @override State<_NewsDetailBody> createState()=> _NewsDetailBodyState();
}
class _NewsDetailBodyState extends State<_NewsDetailBody>{
  int index=0;
  PageController? _pc;
  @override void initState(){ super.initState(); if(widget.news.images.isNotEmpty || widget.news.image!=null){ _pc = PageController(); } }
  Future<void> _precache(List<String> all) async {
    for(final p in all){
      final url = _abs(p);
      // ignore errors
      precacheImage(CachedNetworkImageProvider(url), context).catchError((_){ });
    }
  }
  @override void dispose(){ _pc?.dispose(); super.dispose(); }
  @override Widget build(BuildContext context){
    final allImages = [if(widget.news.image!=null) widget.news.image!, ...widget.news.images];
    if(allImages.isNotEmpty){ WidgetsBinding.instance.addPostFrameCallback((_){ _precache(allImages); }); }
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
            if(allImages.isNotEmpty) _gallery(context, allImages),
            const SizedBox(height:16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal:4.0),
              child: Text(widget.news.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height:12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal:4.0),
              child: _renderContent(widget.news.content, context),
            ),
            const SizedBox(height:32),
          ]),
        )
      ],
    );
  }

  Widget _renderContent(String raw, BuildContext context){
    final looksHtml = raw.contains('<p') || raw.contains('<br') || raw.contains('<img') || raw.contains('<h') || raw.contains('<ul') || raw.contains('<li');
    if(!looksHtml){
      return Text(raw, style: Theme.of(context).textTheme.bodyMedium);
    }
    final safe = sanitizeHtml(raw);
    return Html(
      data: safe,
      // Filter out disallowed tags by replacing them pre-render (simple heuristic)
      // NOTE: For stronger sanitization integrate a proper HTML sanitizer server-side.
      // Here we strip script/style tags.
      // (flutter_html 3 beta removed old tagsList API; using style + onLinkTap only.)
      style: {
        'body': Style(margin: Margins.zero, padding: HtmlPaddings.all(0), fontSize: FontSize(16), lineHeight: const LineHeight(1.35)),
        'p': Style(margin: Margins.only(bottom: 12)),
        'h1': Style(fontSize: FontSize(26), fontWeight: FontWeight.w600),
        'h2': Style(fontSize: FontSize(22), fontWeight: FontWeight.w600),
        'ul': Style(margin: Margins.only(left: 16, bottom: 12)),
        'ol': Style(margin: Margins.only(left: 16, bottom: 12)),
        'li': Style(margin: Margins.only(bottom: 6)),
        'img': Style(margin: Margins.only(bottom: 12)),
      },
      onLinkTap: (url, _, __){ if(url!=null){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Линк: $url'))); } },
    );
  }

  Widget _gallery(BuildContext context, List<String> imgs){
    return LayoutBuilder(builder: (ctx, constraints){
      final isWide = constraints.maxWidth > 900 && imgs.length>1; // desktop style
      final main = AspectRatio(
        aspectRatio: 16/9,
        child: PageView.builder(
          controller: _pc,
          onPageChanged: (i)=> setState(()=> index=i),
          itemCount: imgs.length,
          itemBuilder: (_,i){
            final url = _abs(imgs[i]);
            return GestureDetector(
              onTap: (){
                Navigator.of(context).push(PageRouteBuilder(pageBuilder: (_,a,b)=> NewsImageViewer(
                  images: imgs.map(_abs).toList(),
                  initialIndex: i,
                  heroPrefix: 'news_img_${widget.news.id}_',
                ), transitionsBuilder: (_, anim, secondary, child){
                  return FadeTransition(opacity: anim, child: child);
                }));
              },
              child: Hero(
                tag: i==0? 'news_img_list_${widget.news.id}' : 'news_img_${widget.news.id}_$i',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.cover,
                    placeholder: (_,__)=>(Container(color: Theme.of(context).colorScheme.surfaceContainerHighest)),
                    errorWidget: (_,__,___)=> const Center(child: Icon(Icons.broken_image)),
                  ),
                ),
              ),
            );
          },
        ),
      );
      Widget indicators = const SizedBox.shrink();
      if(imgs.length>1 && !isWide){
        indicators = Padding(
          padding: const EdgeInsets.only(top:8),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(imgs.length, (i)=> AnimatedContainer(
            duration: const Duration(milliseconds:400),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(horizontal:4),
            width: i==index? 22: 8,
            height: 8,
            decoration: BoxDecoration(
              color: i==index? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary.withOpacity(.3),
              borderRadius: BorderRadius.circular(30),
            ),
          ))),
        );
      }
      if(!isWide){
        return Column(children:[main, indicators]);
      }
      // wide layout with vertical thumbnails
      final thumbBar = SizedBox(
        width: 120,
        child: ListView.builder(
          shrinkWrap: true,
            itemCount: imgs.length,
            itemBuilder: (_,i){
              final u = _abs(imgs[i]);
              final sel = i==index;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical:6),
                child: InkWell(
                  onTap: ()=> _pc?.animateToPage(i, duration: const Duration(milliseconds:300), curve: Curves.easeOut),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds:250),
                    decoration: BoxDecoration(
                      border: Border.all(color: sel? Theme.of(context).colorScheme.primary : Colors.transparent, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: AspectRatio(
                        aspectRatio: 16/9,
                        child: CachedNetworkImage(
                          imageUrl: absUrl(u)!,
                          fit: BoxFit.cover,
                          placeholder: (_,__)=>(Container(color: Theme.of(context).colorScheme.surfaceContainerHighest)),
                          errorWidget: (_,__,___)=> const Icon(Icons.image_not_supported, size: 30),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            })
      );
      return Row(crossAxisAlignment: CrossAxisAlignment.start, children:[Expanded(child: main), const SizedBox(width:16), thumbBar]);
    });
  }
}

String _abs(String path){
  return absUrl(path)!;
}
