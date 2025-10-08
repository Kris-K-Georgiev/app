import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_client.dart';
import '../models/post.dart';
import '../models/prayer.dart';

abstract class ICommunityService {
  Future<(List<PostItem>, bool)> fetchPosts({int page, int perPage});
  Future<(List<PrayerItem>, bool)> fetchPrayers({int page, int perPage});
  Future<(List<Map<String,dynamic>>, bool)> fetchPostComments(int postId, {int page, int perPage});
  Future<PostItem> createPost({required String content, File? image});
  Future<PostItem> updatePost(int id, {String? content, File? image});
  Future<(bool liked, int likesCount)> togglePostLike(int id);
  Future<PrayerItem> createPrayer({required String content, bool isAnonymous});
  Future<PrayerItem> updatePrayer(int id, {String? content, bool? isAnonymous, bool? answered});
  Future<(bool liked, int likesCount)> togglePrayerLike(int id);
  Future<void> submitFeedback({required String message, String? contact});
}

class CommunityService implements ICommunityService {
  final ApiClient client;
  CommunityService(this.client);

  Future<(List<T>, bool)> _paged<T>(String path, T Function(Map<String,dynamic>) map) async {
    final dynamic json = await client.get(path);
    List rawList = const [];
    int lastPage = 1; int currentPage = 1;
    if(json is Map<String,dynamic>){
      if(json['data'] is List) rawList = json['data'];
      if(json['last_page'] is int) lastPage = json['last_page'];
      if(json['current_page'] is int) currentPage = json['current_page'];
    } else if(json is List){
      rawList = json; currentPage = 1; lastPage = 1;
    }
    final list = rawList.whereType<Map>().map((e){
      try { return map(Map<String,dynamic>.from(e)); } catch(_){ return null; }
    }).whereType<T>().toList();
    final hasMore = currentPage < lastPage;
    return (list, hasMore);
  }

  @override
  Future<(List<PostItem>, bool)> fetchPosts({int page = 1, int perPage = 10}) => _paged('/posts?page=$page&per_page=$perPage', (j)=> PostItem.fromJson(j));

  @override
  Future<(List<PrayerItem>, bool)> fetchPrayers({int page = 1, int perPage = 10}) => _paged('/prayers?page=$page&per_page=$perPage', (j)=> PrayerItem.fromJson(j));

  @override
  Future<(List<Map<String,dynamic>>, bool)> fetchPostComments(int postId, {int page = 1, int perPage = 20}) async {
    final (list, hasMore) = await _paged('/posts/$postId/comments?page=$page&per_page=$perPage', (j)=> j);
    return (list.cast<Map<String,dynamic>>(), hasMore);
  }

  @override
  Future<PostItem> createPost({required String content, File? image}) async {
    if(image!=null){
      // use multipart
      final res = await client.multipart('/posts', {'content':content}, {'image': image.path});
      return PostItem.fromJson(Map<String,dynamic>.from(res));
    }
    final res = await client.post('/posts', {'content': content});
    return PostItem.fromJson(Map<String,dynamic>.from(res));
  }

  @override
  Future<PostItem> updatePost(int id, {String? content, File? image}) async {
    if(image!=null){
      final res = await client.multipart('/posts/$id', { if(content!=null) 'content': content }, {'image': image.path}, method: 'POST');
      return PostItem.fromJson(Map<String,dynamic>.from(res));
    }
    final res = await client.put('/posts/$id', { if(content!=null) 'content': content });
    return PostItem.fromJson(Map<String,dynamic>.from(res));
  }

  @override
  Future<(bool liked, int likesCount)> togglePostLike(int id) async {
    final res = await client.post('/posts/$id/like', {});
    return (res['liked']==true, (res['likes_count'] is int) ? res['likes_count'] : int.tryParse('${res['likes_count'] ?? 0}') ?? 0);
  }

  @override
  Future<PrayerItem> createPrayer({required String content, bool isAnonymous = false}) async {
    final res = await client.post('/prayers', {'content': content, 'is_anonymous': isAnonymous});
    return PrayerItem.fromJson(Map<String,dynamic>.from(res));
  }

  @override
  Future<PrayerItem> updatePrayer(int id, {String? content, bool? isAnonymous, bool? answered}) async {
    final body = <String,dynamic>{};
    if(content!=null) body['content']=content;
    if(isAnonymous!=null) body['is_anonymous']=isAnonymous;
    if(answered!=null) body['answered']=answered;
    final res = await client.put('/prayers/$id', body);
    return PrayerItem.fromJson(Map<String,dynamic>.from(res));
  }

  @override
  Future<(bool liked, int likesCount)> togglePrayerLike(int id) async {
    final res = await client.post('/prayers/$id/like', {});
    return (res['liked']==true, (res['likes_count'] is int) ? res['likes_count'] : int.tryParse('${res['likes_count'] ?? 0}') ?? 0);
  }

  @override
  Future<void> submitFeedback({required String message, String? contact}) async {
    await client.post('/feedback', { 'message': message, if(contact!=null && contact.isNotEmpty) 'contact': contact });
  }
}
