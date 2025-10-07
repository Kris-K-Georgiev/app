import 'package:flutter/foundation.dart';
import '../models/news.dart';
import '../models/event.dart';
import '../models/app_version.dart';
import '../services/content_service.dart';
import '../services/heartbeat_service.dart';

class ContentProvider extends ChangeNotifier {
  final IContentService service;
  List<NewsItem> news = [];
  List<EventItem> events = [];
  AppVersionInfo? latest;
  bool loading = false;
  bool eventsLoading = false;
  bool eventsLoadingMore = false;
  bool eventsHasMore = true;
  bool eventsError = false; // capture last load error
  bool newsLoadingMore = false;
  bool newsHasMore = true;
  int _newsPage = 1;
  int _eventsPage = 1;
  String? lastStatusFilter;
  HeartbeatService? heartbeat;

  ContentProvider(this.service);

  void attachHeartbeat(HeartbeatService hb) {
    heartbeat = hb;
    hb.stream.listen((snap) {
      // If we detect newer content, refresh lists (lightweight strategy: reload page 1 + events)
      final currentMaxNews = news.isEmpty ? 0 : news.first.id;
      if (snap.latestNewsId != null && snap.latestNewsId! > currentMaxNews) {
        reloadNews();
      }
      final currentMaxEvent = events.isEmpty ? 0 : events.first.id;
      if (snap.latestEventId != null && snap.latestEventId! > currentMaxEvent) {
        reloadEvents();
      }
    });
    hb.start();
  }

  Future<void> loadAll() async {
    loading = true;
  eventsLoading = true; eventsError=false;
    notifyListeners();
    try {
      _newsPage = 1;
      newsHasMore = true;
      _eventsPage = 1;
      eventsHasMore = true;
      try {
        final (n, hasMore) = await service.fetchNews(page: _newsPage);
        news = n; newsHasMore = hasMore;
      } catch(_) {
        news = [];
      }
      try {
        final (e, hasMoreEv) = await service.fetchEventsPaged(page: _eventsPage, perPage: 30);
        events = e; eventsHasMore = hasMoreEv;
      } catch(_) {
        events = [];
      }
    } finally {
      loading = false;
      eventsLoading = false;
      notifyListeners();
    }
  }

  Future<void> reloadNews() async {
    final (n, hasMore) = await service.fetchNews(page: 1);
    news = n;
    _newsPage = 1;
    newsHasMore = hasMore;
    notifyListeners();
  }

  Future<void> reloadEvents({String? status,String? type,String? audience,String? city}) async {
    eventsLoading = true;
    lastStatusFilter = status;
    notifyListeners();
    try {
      _eventsPage = 1; eventsHasMore = true;
      try {
        final (e, hasMoreEv) = await service.fetchEventsPaged(page: _eventsPage, perPage: 30, status: status, type: type, audience: audience, city: city);
        events = e; eventsHasMore = hasMoreEv;
      } catch(err, st){
        // ignore: avoid_print
        print('[content][reloadEvents][error] $err\n$st');
        events = []; eventsHasMore = false; eventsError = true;
      }
    } finally {
      eventsLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreEvents({String? status,String? type,String? audience,String? city}) async {
    if(!eventsHasMore || eventsLoadingMore || eventsLoading) return;
    eventsLoadingMore = true; notifyListeners();
    try {
      _eventsPage += 1;
      try {
        final (e, hasMoreEv) = await service.fetchEventsPaged(page: _eventsPage, perPage: 30, status: status, type: type, audience: audience, city: city);
        events.addAll(e); eventsHasMore = hasMoreEv;
      } catch(err, st){
        // ignore: avoid_print
        print('[content][loadMoreEvents][error] $err\n$st');
        // rollback page increment so we can retry later
        _eventsPage -= 1; eventsError = true;
      }
    } finally {
      eventsLoadingMore = false; notifyListeners();
    }
  }

  Future<void> loadMoreNews() async {
    if (!newsHasMore || newsLoadingMore) return;
    newsLoadingMore = true;
    notifyListeners();
    try {
      _newsPage += 1;
      final (n, hasMore) = await service.fetchNews(page: _newsPage);
      news.addAll(n);
      newsHasMore = hasMore;
    } finally {
      newsLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> checkVersion() async {
    latest = await service.latestVersion();
    notifyListeners();
  }
}
