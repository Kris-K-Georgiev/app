import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'lazy_image.dart';
import 'dart:math' as math;
import '../theme/design_tokens.dart';
import '../ui/meta_chip.dart';
import '../ui/shimmer.dart';

/// Unified media/content card used for News & Events lists.
/// Handles optional hero image, gradient overlay (adaptive to brightness),
/// title, body/excerpt, meta line (chips), and optional trailing badge.
class ContentMediaCard extends StatefulWidget {
  final String? heroTag;
  final String? imageUrl;
  final Widget? image;
  final String title;
  final String? body;
  final List<Widget> metaChips; // displayed below body
  final Widget? trailingBadge; // e.g. event type
  final VoidCallback? onTap;
  // Optional social actions (if any provided, an actions row will be shown)
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final int? likesCount;
  final int? commentsCount;
  final EdgeInsets padding;
  final double aspectRatio;
  final bool denseMeta;
  final bool enableOverlay;
  final bool reserveBodySpace; // pre-allocate body height to reduce layout shift
  final bool heroEnableFade;
  final int bodyMaxLines;
  final bool heroPrecache; // precache image before hero flight
  final double? textScale; // external override (else computed internally)
  final bool disableHover; // for touch platforms
  final int? memCacheOverride; // externally force a smaller cached width (e.g. grid thumbnails)

  const ContentMediaCard({
    super.key,
    this.heroTag,
    this.imageUrl,
    this.image,
    required this.title,
    this.body,
    this.metaChips = const [],
    this.trailingBadge,
    this.onTap,
    this.onLike,
    this.onComment,
    this.onShare,
    this.likesCount,
    this.commentsCount,
    this.padding = const EdgeInsets.fromLTRB(AppTokens.space4, AppTokens.space4, AppTokens.space4, AppTokens.space4),
    this.aspectRatio = 16/10,
    this.denseMeta = true,
    this.enableOverlay = true,
    this.reserveBodySpace = true,
    this.heroEnableFade = true,
    this.bodyMaxLines = 3,
    this.heroPrecache = true,
    this.textScale,
    this.disableHover = false,
    this.memCacheOverride,
  });
  @override
  State<ContentMediaCard> createState() => _ContentMediaCardState();
}

class _ContentMediaCardState extends State<ContentMediaCard> {
  ImageProvider? _provider;
  bool _precached = false;
  final ValueNotifier<bool> _hoverNotifier = ValueNotifier(false);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if(!_precached && widget.heroPrecache && widget.imageUrl!=null){
      _provider = CachedNetworkImageProvider(widget.imageUrl!);
      precacheImage(_provider!, context).then((_) { if(mounted) setState(()=> _precached = true); });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final media = MediaQuery.of(context);
    final width = media.size.width;
  final scale = widget.textScale ?? AppTokens.textScale(width);
    final textTheme = Theme.of(context).textTheme.apply(
      bodyColor: null,
      displayColor: null,
    );
    final hasImageBase = (widget.imageUrl != null) || (widget.image != null);
    // If the card will be rendered very narrow (e.g., adaptive side pane), drop image to reduce vertical waste.
    // We can't know exact card width here unless we measure; wrap children in LayoutBuilder.
    return LayoutBuilder(builder:(ctx,constraints){
      final cardWidth = constraints.maxWidth.isFinite ? constraints.maxWidth : (width * .92);
      final hideImage = cardWidth < 220;
      final hasImage = !hideImage && hasImageBase;
      final adaptiveAspect = (){
        if(cardWidth >= 1000) return 5/2; // panoramic banner on huge grids
        if(cardWidth >= 720) return 16/7;
        if(cardWidth >= 500) return 16/8.5;
        if(cardWidth >= 360) return widget.aspectRatio; // default
        return 4/3; // tall-ish for very cramped width
      }();
  final radius = BorderRadius.circular(AppTokens.radiusLg);
    final brightness = Theme.of(context).brightness;
    final overlay = brightness == Brightness.dark
        ? [Colors.black.withOpacity(.55), Colors.black.withOpacity(.05)]
        : [scheme.surface.withOpacity(.55), scheme.surface.withOpacity(0)];

    Widget buildImage() {
      if(!hasImage) return const SizedBox.shrink();
      Widget img;
      if(widget.image != null) {
        img = widget.image!;
      } else {
        // Use lazy loading when hero precache disabled (e.g., large event lists)
        final placeholder = Container(color: scheme.surfaceContainerHighest.withOpacity(.15));
        if(!widget.heroPrecache){
          img = LazyNetworkImage(
            url: widget.imageUrl!,
            fit: BoxFit.cover,
            placeholder: placeholder,
          );
        } else {
          final dpr = media.devicePixelRatio;
          // Use measured cardWidth rather than a fixed target (allow override for thumbnails)
          final computed = (cardWidth * dpr).clamp(200, 1400).toInt();
          final maxWidth = widget.memCacheOverride != null ? math.min(widget.memCacheOverride!, computed) : computed;
          img = CachedNetworkImage(
            imageUrl: widget.imageUrl!,
            fit: BoxFit.cover,
            memCacheWidth: maxWidth,
            fadeInDuration: const Duration(milliseconds: 260),
            placeholder: (_, __) => placeholder,
            errorWidget: (_, __, ___) => Container(color: scheme.surfaceContainerHighest.withOpacity(.3), alignment: Alignment.center, child: Icon(Icons.broken_image, color: scheme.onSurface.withOpacity(.4))),
          );
        }
      }
      final content = AspectRatio(
        aspectRatio: adaptiveAspect,
        child: Stack(children:[
          Positioned.fill(child: img),
          if(widget.enableOverlay) Positioned.fill(child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: overlay),
            ),
          )),
          // Ripple visibility improvement: transparent Material on top
          Positioned.fill(child: IgnorePointer(child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
            ),
          ))),
        ]),
      );
      if(widget.heroTag!=null){
        return Hero(
          tag: widget.heroTag!,
          flightShuttleBuilder: widget.heroEnableFade ? (ctx, anim, direction, fromCtx, toCtx){
            final target = direction == HeroFlightDirection.push ? toCtx.widget : fromCtx.widget;
            return FadeTransition(opacity: anim.drive(CurveTween(curve: Curves.easeInOut)), child: target);
          } : null,
          child: content,
        );
      }
      return content;
    }

    final cardCore = Semantics(
      label: widget.title + (widget.body!=null ? '. ${widget.body!.substring(0, math.min(widget.body!.length, 60))}' : ''),
      button: widget.onTap != null,
      child: DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: radius,
        border: Border.all(color: scheme.outline.withOpacity(.25)),
        boxShadow: [BoxShadow(color: scheme.shadow.withOpacity(.04), blurRadius: 8, offset: const Offset(0,4))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          splashColor: scheme.primary.withOpacity(.08),
          highlightColor: scheme.primary.withOpacity(.04),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
            if(hasImage) buildImage(),
            Padding(
              padding: widget.padding,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
                Row(crossAxisAlignment: CrossAxisAlignment.start, children:[
                  Expanded(child: Text(widget.title, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -.25, height:1.15, fontSize: (textTheme.titleMedium?.fontSize ?? 18) * scale))),
                  if(widget.trailingBadge!=null) ...[const SizedBox(width: AppTokens.space2), widget.trailingBadge!],
                ]),
                if(widget.body!=null) ...[
                  const SizedBox(height: AppTokens.space2),
                  _ReservedBody(text: widget.body!, reserve: widget.reserveBodySpace, maxLines: widget.bodyMaxLines, scale: scale),
                ],
                if(widget.metaChips.isNotEmpty) ...[
                  const SizedBox(height: AppTokens.space3),
                  Semantics(
                    label: 'Метаданни',
                    child: Wrap(spacing: AppTokens.space2, runSpacing: widget.denseMeta? AppTokens.space1 : AppTokens.space2, children: widget.metaChips),
                  ),
                ],
                // Social actions row (optional)
                if(widget.onLike!=null || widget.onComment!=null || widget.onShare!=null) ...[
                  const SizedBox(height: AppTokens.space3),
                  Semantics(
                    label: 'Действия',
                    child: Row(children: [
                      if(widget.onLike!=null) ...[
                        IconButton(
                          tooltip: 'Харесай',
                          onPressed: widget.onLike,
                          icon: const Icon(Icons.favorite_border),
                        ),
                        if(widget.likesCount!=null) Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Text('${widget.likesCount}', style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                        ),
                      ],
                      if(widget.onComment!=null) ...[
                        IconButton(
                          tooltip: 'Коментар',
                          onPressed: widget.onComment,
                          icon: const Icon(Icons.chat_bubble_outline),
                        ),
                        if(widget.commentsCount!=null) Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Text('${widget.commentsCount}', style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                        ),
                      ],
                      if(widget.onShare!=null) ...[
                        IconButton(
                          tooltip: 'Сподели',
                          onPressed: widget.onShare,
                          icon: const Icon(Icons.share_outlined),
                        ),
                      ],
                    ]),
                  ),
                ],
              ]),
            )
          ]),
        ),
      ),
    ));

    // Hover scale (web/desktop only): use MouseRegion + AnimatedScale
    if(widget.disableHover){
      return cardCore; // no pointer hover transform
    }
    return MouseRegion(
      onEnter: (_) => _hoverNotifier.value = true,
      onExit: (_) => _hoverNotifier.value = false,
      child: ValueListenableBuilder<bool>(
        valueListenable: _hoverNotifier,
        builder: (_, hover, child) => AnimatedScale(
          scale: hover ? 1.015 : 1.0,
          duration: AppTokens.medium,
          curve: Curves.easeOut,
          child: child,
        ),
        child: cardCore,
      ),
    );
    });
  }
}

/// Convenience MetaChip builder for date strings (can be extended later).
Widget dateChip(String label) => MetaChip(label: label, dense: true);

// Internal hover state (kept outside widget tree for simplicity)
final ValueNotifier<bool> _hoverNotifier = ValueNotifier(false);

class _ReservedBody extends StatelessWidget {
  final String text; final bool reserve; final int maxLines; final double scale;
  const _ReservedBody({required this.text, required this.reserve, required this.maxLines, required this.scale});
  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(height:1.28, fontSize: (Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14) * scale);
    if(!reserve){
      return Text(text, style: style, maxLines: maxLines, overflow: TextOverflow.ellipsis);
    }
    // Estimate needed lines based on length (simple heuristic)
    const avgCharsPerLine = 52;
    int estLines = (text.length / avgCharsPerLine).ceil();
    estLines = estLines.clamp(1, maxLines);
    final fs = style?.fontSize ?? 14;
    final lh = style?.height ?? 1.28;
    final h = fs * lh * estLines;
    return SizedBox(
      height: h,
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(text, style: style, maxLines: maxLines, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

/// Skeleton placeholder matching ContentMediaCard layout
class ContentMediaCardSkeleton extends StatelessWidget {
  final bool showImage; final double aspectRatio; final int bodyLines; final bool showMeta; const ContentMediaCardSkeleton({super.key, this.showImage=true, this.aspectRatio=16/10, this.bodyLines=3, this.showMeta=true});
  @override
  Widget build(BuildContext context){
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(AppTokens.radiusLg);
    final lineHeight = 10.0;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: radius,
        border: Border.all(color: scheme.outline.withOpacity(.20)),
        boxShadow: [BoxShadow(color: scheme.shadow.withOpacity(.04), blurRadius: 8, offset: const Offset(0,4))],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
          if(showImage) AspectRatio(
            aspectRatio: aspectRatio,
            child: ClipRRect(
              borderRadius: BorderRadius.only(topLeft: radius.topLeft, topRight: radius.topRight),
              child: Shimmer(width: double.infinity, height: double.infinity, radius: BorderRadius.zero),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppTokens.space4, AppTokens.space4, AppTokens.space4, AppTokens.space4),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
              Shimmer(height: lineHeight+4, width: 160, radius: BorderRadius.circular(6)),
              const SizedBox(height: AppTokens.space3),
              for(int i=0;i<bodyLines;i++) ...[
                Shimmer(height: lineHeight, width: i==bodyLines-1? 140 : double.infinity, radius: BorderRadius.circular(4)),
                if(i<bodyLines-1) const SizedBox(height: 6),
              ],
              if(showMeta) ...[
                const SizedBox(height: AppTokens.space3),
                Row(children:[
                  Shimmer(height: 20, width: 60, radius: BorderRadius.circular(20)),
                  const SizedBox(width: 8),
                  Shimmer(height: 20, width: 36, radius: BorderRadius.circular(20)),
                ])
              ]
            ]),
          )
        ]),
      ),
    );
  }
}
