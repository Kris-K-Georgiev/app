class PostAuthor {
  final int id;
  final String name;
  final String? avatarPath;
  PostAuthor({required this.id, required this.name, this.avatarPath});
  factory PostAuthor.fromJson(Map<String,dynamic> j) => PostAuthor(
    id: j['id'] ?? 0,
    name: (j['name'] ?? '').toString(),
    avatarPath: j['avatar_path']?.toString(),
  );
}

class PostItem {
  final int id;
  final String content;
  final String? image;
  final int likesCount;
  final int commentsCount; // reserved (comments may be added later)
  final bool liked;
  final bool canEdit;
  final bool isNew;
  final PostAuthor? author;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  PostItem({
    required this.id,
    required this.content,
    required this.image,
    required this.likesCount,
    required this.commentsCount,
    required this.liked,
    required this.canEdit,
    required this.isNew,
    required this.author,
    this.createdAt,
    this.updatedAt,
  });
  factory PostItem.fromJson(Map<String,dynamic> j) => PostItem(
    id: j['id']??0,
    content: j['content']??'',
    image: j['image'],
    likesCount: (j['likes_count'] is int) ? j['likes_count'] : int.tryParse('${j['likes_count'] ?? 0}') ?? 0,
    commentsCount: (j['comments_count'] is int) ? j['comments_count'] : int.tryParse('${j['comments_count'] ?? 0}') ?? 0,
    liked: j['liked']==true,
    canEdit: j['can_edit']==true,
    isNew: j['is_new'] == true,
    author: (j['author'] is Map<String,dynamic>) ? PostAuthor.fromJson(j['author']) : null,
    createdAt: j['created_at']!=null? DateTime.tryParse(j['created_at'].toString()) : null,
    updatedAt: j['updated_at']!=null? DateTime.tryParse(j['updated_at'].toString()) : null,
  );
  PostItem copyWith({
    String? content,
    String? image,
    int? likesCount,
    int? commentsCount,
    bool? liked,
    bool? isNew,
    PostAuthor? author,
  }) => PostItem(
    id: id,
    content: content ?? this.content,
    image: image ?? this.image,
    likesCount: likesCount ?? this.likesCount,
    commentsCount: commentsCount ?? this.commentsCount,
    liked: liked ?? this.liked,
    canEdit: canEdit,
    isNew: isNew ?? this.isNew,
    author: author ?? this.author,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
