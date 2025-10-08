import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/models/post.dart';
import 'package:frontend/models/prayer.dart';
import 'package:frontend/providers/community_provider.dart';
import 'package:frontend/services/community_service.dart';
import 'package:frontend/screens/community_screen.dart';
import 'package:frontend/l10n/l10n.dart';

class _StubService implements ICommunityService {
  @override Future<(List<PostItem>, bool)> fetchPosts({int page = 1}) async => ([], false);
  @override Future<(bool, int)> togglePostLike(int id) async => (false, 0);
  @override Future<PostItem> createPost({required String content, File? image}) async => throw UnimplementedError();
  @override Future<PostItem> updatePost(int id, {String? content, File? image}) async => throw UnimplementedError();
  @override Future<(List<PrayerItem>, bool)> fetchPrayers({int page = 1}) async => ([], false);
  @override Future<(bool, int)> togglePrayerLike(int id) async => (false, 0);
  @override Future<PrayerItem> createPrayer({required String content, bool isAnonymous = false}) async => throw UnimplementedError();
  @override Future<PrayerItem> updatePrayer(int id, {String? content, bool? isAnonymous, bool? answered}) async => throw UnimplementedError();
}

void main(){
  testWidgets('Post shows New chip when isNew', (tester) async {
    final provider = CommunityProvider(_StubService());
    provider.posts.add(
      PostItem(
        id: 1,
        content: 'Hello world',
        image: null,
        likesCount: 0,
        commentsCount: 0,
        liked: false,
        canEdit: false,
        isNew: true,
        author: PostAuthor(id: 5, name: 'Alice', avatarPath: null),
      )
    );

    await tester.pumpWidget(MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const [AppLocalizations.delegate],
      supportedLocales: const [Locale('en'), Locale('bg')],
      home: ChangeNotifierProvider.value(
        value: provider,
        child: const CommunityScreen(),
      ),
    ));

    await tester.pumpAndSettle();
    expect(find.text('New'), findsOneWidget);
    expect(find.text('Alice'), findsOneWidget);
  });
}
