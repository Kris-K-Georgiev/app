import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/providers/community_provider.dart';
import 'package:frontend/services/community_service.dart';
import 'package:frontend/models/post.dart';
import 'package:frontend/models/prayer.dart';

class _MockService implements ICommunityService {
  int postFetchCalls = 0;
  int prayerFetchCalls = 0;
  bool likeFlip = false;

  @override
  Future<(List<PostItem>, bool)> fetchPosts({int page = 1, int perPage = 10}) async {
    postFetchCalls++;
    return ([PostItem(id: page, content: 'p$page', image: null, likesCount: 0, commentsCount: 0, liked: false, canEdit: true)], page < 3);
  }

  @override
  Future<(List<PrayerItem>, bool)> fetchPrayers({int page = 1, int perPage = 10}) async {
    prayerFetchCalls++;
    return ([PrayerItem(id: page, content: 'r$page', isAnonymous: false, answered: false, likesCount: 0, liked: false, userName: 'U', canEdit: true)], page < 2);
  }

  @override
  Future<PostItem> createPost({required String content, image}) async {
    return PostItem(id: 999, content: content, image: null, likesCount: 0, commentsCount: 0, liked: false, canEdit: true);
  }

  @override
  Future<PrayerItem> createPrayer({required String content, bool isAnonymous = false}) async {
    return PrayerItem(id: 777, content: content, isAnonymous: isAnonymous, answered: false, likesCount: 0, liked: false, userName: 'U', canEdit: true);
  }

  @override
  Future<(bool liked, int likesCount)> togglePostLike(int id) async {
    likeFlip = !likeFlip; return (likeFlip, likeFlip? 1:0);
  }

  @override
  Future<(bool liked, int likesCount)> togglePrayerLike(int id) async {
    likeFlip = !likeFlip; return (likeFlip, likeFlip? 1:0);
  }

  @override
  Future<PostItem> updatePost(int id, {String? content, image}) async {
    return PostItem(id: id, content: content ?? 'updated', image: null, likesCount: 5, commentsCount: 0, liked: false, canEdit: true);
  }

  @override
  Future<PrayerItem> updatePrayer(int id, {String? content, bool? isAnonymous, bool? answered}) async {
    return PrayerItem(id: id, content: content ?? 'updated', isAnonymous: isAnonymous ?? false, answered: answered ?? false, likesCount: 3, liked: false, userName: 'U', canEdit: true);
  }
}

void main(){
  test('pagination load & like optimistic', () async {
    final service = _MockService();
    final provider = CommunityProvider(service);
    await provider.reloadPosts();
    expect(provider.posts.length, 1);
    // load more
    await provider.loadMorePosts();
    expect(provider.posts.length, 2);
    // optimistic like
    final first = provider.posts.first;
    final beforeLikes = first.likesCount;
    await provider.togglePostLike(first);
    expect(provider.posts.first.likesCount, isNot(beforeLikes));
  });

  test('prayers pagination', () async {
    final service = _MockService();
    final provider = CommunityProvider(service);
    await provider.reloadPrayers();
    expect(provider.prayers.length, 1);
    await provider.loadMorePrayers();
    expect(provider.prayers.length, 2);
  });
}
