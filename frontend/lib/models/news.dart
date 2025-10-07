class NewsItem {
  final int id;
  final String title;
  final String content;
  final String? image; // legacy main image
  final String? cover; // new cover field
  final List<String> images; // gallery
  final DateTime? createdAt;
  final int? userId; // author / owner id (optional)
  final int? likesCount;
  final int? commentsCount;
  NewsItem({required this.id, required this.title, required this.content, this.image, this.cover, required this.images, this.createdAt, this.userId, this.likesCount, this.commentsCount});
  factory NewsItem.fromJson(Map<String,dynamic> j) => NewsItem(
    id: j['id'],
    title: j['title']??'',
    content: j['content']??'',
    image: j['image'],
    cover: j['cover'],
    images: (j['images'] is List) ? List<String>.from(j['images'].whereType<String>()) : const [],
    createdAt: j['created_at']!=null?DateTime.tryParse(j['created_at'].toString()):null,
    userId: (() {
      final v = j['user_id'] ?? j['created_by'];
      if(v is int) return v; return int.tryParse(v?.toString()??'');
    })(),
    likesCount: (() {
      final v = j['likes_count'];
      if(v is int) return v; return int.tryParse(v?.toString()??'');
    })(),
    commentsCount: (() {
      final v = j['comments_count'];
      if(v is int) return v; return int.tryParse(v?.toString()??'');
    })(),
  );
}
