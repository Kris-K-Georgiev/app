class PrayerItem {
  final int id;
  final String content;
  final bool isAnonymous;
  final bool answered;
  final int likesCount;
  final bool liked;
  final String? userName; // null if anonymous
  final bool canEdit;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  PrayerItem({
    required this.id,
    required this.content,
    required this.isAnonymous,
    required this.answered,
    required this.likesCount,
    required this.liked,
    required this.userName,
    required this.canEdit,
    this.createdAt,
    this.updatedAt,
  });
  factory PrayerItem.fromJson(Map<String,dynamic> j) => PrayerItem(
    id: j['id']??0,
    content: j['content']??'',
    isAnonymous: j['is_anonymous']==true,
    answered: j['answered']==true,
    likesCount: (j['likes_count'] is int)? j['likes_count'] : int.tryParse('${j['likes_count'] ?? 0}') ?? 0,
    liked: j['liked']==true,
    userName: j['user_name'] as String?,
    canEdit: j['can_edit']==true,
    createdAt: j['created_at']!=null? DateTime.tryParse(j['created_at'].toString()) : null,
    updatedAt: j['updated_at']!=null? DateTime.tryParse(j['updated_at'].toString()) : null,
  );
  PrayerItem copyWith({
    String? content,
    bool? isAnonymous,
    bool? answered,
    int? likesCount,
    bool? liked,
  }) => PrayerItem(
    id: id,
    content: content ?? this.content,
    isAnonymous: isAnonymous ?? this.isAnonymous,
    answered: answered ?? this.answered,
    likesCount: likesCount ?? this.likesCount,
    liked: liked ?? this.liked,
    userName: userName,
    canEdit: canEdit,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
