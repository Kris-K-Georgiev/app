import 'package:flutter/foundation.dart';
import 'dart:io';
import '../models/post.dart';
import '../models/prayer.dart';
import '../services/community_service.dart';

class CommunityProvider extends ChangeNotifier {
  final ICommunityService service;
  CommunityProvider(this.service);

  // Posts state
  final List<PostItem> posts = [];
  bool postsLoading = false;
  bool postsLoadingMore = false;
  bool postsHasMore = true;
  int _postsPage = 1;

  // Prayers state
  final List<PrayerItem> prayers = [];
  bool prayersLoading = false;
  bool prayersLoadingMore = false;
  bool prayersHasMore = true;
  int _prayersPage = 1;

  Future<void> loadInitial() async {
    await Future.wait([reloadPosts(), reloadPrayers()]);
  }

  Future<void> reloadPosts() async {
    postsLoading = true; postsHasMore = true; _postsPage = 1; notifyListeners();
    try {
      final (list, hasMore) = await service.fetchPosts(page: 1);
      posts..clear()..addAll(list);
      postsHasMore = hasMore;
    } finally { postsLoading = false; notifyListeners(); }
  }

  Future<void> loadMorePosts() async {
    if(!postsHasMore || postsLoadingMore || postsLoading) return;
    postsLoadingMore = true; notifyListeners();
    try {
      _postsPage += 1;
      final (list, hasMore) = await service.fetchPosts(page: _postsPage);
      posts.addAll(list);
      postsHasMore = hasMore;
    } catch(_){ _postsPage -= 1; } finally { postsLoadingMore = false; notifyListeners(); }
  }

  Future<void> reloadPrayers() async {
    prayersLoading = true; prayersHasMore = true; _prayersPage = 1; notifyListeners();
    try {
      final (list, hasMore) = await service.fetchPrayers(page: 1);
      prayers..clear()..addAll(list);
      prayersHasMore = hasMore;
    } finally { prayersLoading = false; notifyListeners(); }
  }

  Future<void> loadMorePrayers() async {
    if(!prayersHasMore || prayersLoadingMore || prayersLoading) return;
    prayersLoadingMore = true; notifyListeners();
    try {
      _prayersPage += 1;
      final (list, hasMore) = await service.fetchPrayers(page: _prayersPage);
      prayers.addAll(list);
      prayersHasMore = hasMore;
    } catch(_){ _prayersPage -= 1; } finally { prayersLoadingMore = false; notifyListeners(); }
  }

  Future<void> togglePostLike(PostItem p) async {
    final idx = posts.indexWhere((e)=> e.id==p.id); if(idx<0) return;
    final optimistic = p.copyWith(liked: !p.liked, likesCount: p.liked? (p.likesCount-1).clamp(0, 1<<31) : p.likesCount+1);
    posts[idx] = optimistic; notifyListeners();
    try {
      final (liked, count) = await service.togglePostLike(p.id);
      posts[idx] = posts[idx].copyWith(liked: liked, likesCount: count);
      notifyListeners();
    } catch(_){
      posts[idx] = p; notifyListeners();
    }
  }

  Future<void> togglePrayerLike(PrayerItem pr) async {
    final idx = prayers.indexWhere((e)=> e.id==pr.id); if(idx<0) return;
    final optimistic = pr.copyWith(liked: !pr.liked, likesCount: pr.liked? (pr.likesCount-1).clamp(0, 1<<31) : pr.likesCount+1);
    prayers[idx] = optimistic; notifyListeners();
    try {
      final (liked, count) = await service.togglePrayerLike(pr.id);
      prayers[idx] = prayers[idx].copyWith(liked: liked, likesCount: count);
      notifyListeners();
    } catch(_){ prayers[idx] = pr; notifyListeners(); }
  }

  Future<void> addPost({required String content, String? imagePath}) async {
    File? file;
    if(imagePath!=null){
      try { file = File(imagePath); } catch(_){ file=null; }
    }
    try {
      final created = await service.createPost(content: content, image: file);
      posts.insert(0, created);
      notifyListeners();
    } catch(e){
      // ignore or surface via separate error channel
    }
  }

  Future<void> editPost(PostItem p, {String? content, String? imagePath}) async {
    File? file;
    if(imagePath!=null){ try { file = File(imagePath); } catch(_){ file=null; } }
    final idx = posts.indexWhere((e)=> e.id==p.id); if(idx<0) return;
    try {
      final updated = await service.updatePost(p.id, content: content, image: file);
      posts[idx] = updated; notifyListeners();
    } catch(_){ /* ignore */ }
  }

  Future<void> addPrayer({required String content, bool isAnonymous=false}) async {
    try {
      final created = await service.createPrayer(content: content, isAnonymous: isAnonymous);
      prayers.insert(0, created); notifyListeners();
    } catch(_){ }
  }

  Future<void> editPrayer(PrayerItem pr, {String? content, bool? isAnonymous, bool? answered}) async {
    final idx = prayers.indexWhere((e)=> e.id==pr.id); if(idx<0) return;
    try {
      final updated = await service.updatePrayer(pr.id, content: content, isAnonymous: isAnonymous, answered: answered);
      prayers[idx] = updated; notifyListeners();
    } catch(_){ }
  }
}
