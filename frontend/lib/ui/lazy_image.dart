import 'package:flutter/widgets.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Lightweight lazy network image: only starts resolving when at least `visibilityThreshold`
/// of the widget is visible. Falls back to placeholder until then.
class LazyNetworkImage extends StatefulWidget {
  final String url;
  final BoxFit fit;
  final Widget placeholder;
  final Duration fadeIn;
  final double visibilityThreshold; // 0..1
  const LazyNetworkImage({super.key, required this.url, this.fit=BoxFit.cover, required this.placeholder, this.fadeIn=const Duration(milliseconds:320), this.visibilityThreshold=.05});
  @override State<LazyNetworkImage> createState()=> _LazyNetworkImageState();
}
class _LazyNetworkImageState extends State<LazyNetworkImage> {
  bool _shouldLoad = false;
  @override
  Widget build(BuildContext context){
    return VisibilityDetector(
      key: Key('lazy-img-${widget.url.hashCode}'),
      onVisibilityChanged: (info){
        if(!_shouldLoad && info.visibleFraction >= widget.visibilityThreshold){
          setState(()=> _shouldLoad = true);
        }
      },
      child: AnimatedSwitcher(
        duration: widget.fadeIn,
        child: !_shouldLoad ? widget.placeholder : CachedNetworkImage(
          key: ValueKey('img-${widget.url}'),
          imageUrl: widget.url,
          fit: widget.fit,
          fadeInDuration: widget.fadeIn,
          placeholder: (_, __) => widget.placeholder,
          errorWidget: (_, __, ___) => widget.placeholder,
        ),
      ),
    );
  }
}
