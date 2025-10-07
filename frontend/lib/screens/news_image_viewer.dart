import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NewsImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final String heroPrefix;
  const NewsImageViewer({super.key, required this.images, required this.initialIndex, required this.heroPrefix});
  @override State<NewsImageViewer> createState()=> _NewsImageViewerState();
}

class _NewsImageViewerState extends State<NewsImageViewer> {
  late PageController _pc;
  late int index;
  @override void initState(){
    super.initState();
    index = widget.initialIndex;
    _pc = PageController(initialPage: index);
  }
  @override void dispose(){ _pc.dispose(); super.dispose(); }
  @override Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Center(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal:12.0),
            child: Text('${index+1}/${widget.images.length}', style: const TextStyle(color: Colors.white, fontSize: 16)),
          ))
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: (){ Navigator.of(context).maybePop(); },
        child: PageView.builder(
          controller: _pc,
          onPageChanged: (i)=> setState(()=> index=i),
          itemCount: widget.images.length,
          itemBuilder: (_,i){
            final url = widget.images[i];
            return Hero(
              tag: '${widget.heroPrefix}$i',
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 4.0,
                child: Center(
                  child: CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.contain,
                    placeholder: (_,__)=>(const SizedBox(width:60,height:60,child: CircularProgressIndicator())),
                    errorWidget: (_,__,___)=> const Icon(Icons.broken_image, color: Colors.white, size: 64),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
