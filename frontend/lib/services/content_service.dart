import '../models/news.dart';
import '../models/event.dart';
import '../models/app_version.dart';
import 'api_client.dart';

/// Abstraction to allow mocking in tests.
abstract class IContentService {
  Future<(List<NewsItem>, bool)> fetchNews({int page, int perPage});
  Future<List<EventItem>> fetchEvents({String? status,String? type,String? audience,String? city});
  Future<(List<EventItem>, bool)> fetchEventsPaged({int page,int perPage,String? status,String? type,String? audience,String? city});
  Future<AppVersionInfo?> latestVersion();
}

class ContentService implements IContentService {
  final ApiClient client;
  ContentService(this.client);

  /// Fetch paginated news.
  /// Returns a record: (items, hasMore)
  /// Safe against backend returning either a pagination object { data: [...], current_page, last_page }
  /// or a plain JSON array [...].
  @override
  Future<(List<NewsItem>, bool)> fetchNews({int page=1, int perPage=10}) async {
    final dynamic json = await client.get('/news?page=$page&per_page=$perPage');

    // Extract list part safely
    List rawList = const [];
    if (json is Map<String, dynamic>) {
      final dynamic dataField = json['data'];
      if (dataField is List) {
        rawList = dataField;
      } else if (json['data'] == null && json is List) {
        // unlikely branch, but kept for completeness
        rawList = List.from(json as List);
      }
    } else if (json is List) {
      rawList = json;
    }

    final items = rawList.map((e){
      if (e is Map<String,dynamic>) {
        return NewsItem.fromJson(e);
      }
      // Fallback: attempt dynamic cast
      return NewsItem.fromJson(Map<String,dynamic>.from(e as Map));
    }).toList();

    int lastPage = 1;
    int currentPage = page;
    if (json is Map<String,dynamic>) {
      final lp = json['last_page'];
      final cp = json['current_page'];
      if (lp is int) lastPage = lp;
      if (cp is int) currentPage = cp;
    }
    final hasMore = currentPage < lastPage;
    return (items, hasMore);
  }

  @override
  Future<List<EventItem>> fetchEvents({String? status,String? type,String? audience,String? city}) async {
    final params = <String,String>{};
    if(status!=null && status.isNotEmpty) params['status']=status;
    if(type!=null && type.isNotEmpty) params['type']=type;
    if(audience!=null && audience.isNotEmpty) params['audience']=audience;
    if(city!=null && city.isNotEmpty) params['city']=city;
    final qs = params.isEmpty? '' : '?${params.entries.map((e)=> '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}').join('&')}';
    final json = await client.get('/events$qs');
    List raw;
    if(json is List){
      raw = json;
    } else if(json is Map && json['data'] is List){
      raw = List.from(json['data']);
    } else {
      raw = const [];
    }
    final list = <EventItem>[];
    for(final r in raw.whereType<Map>()){
      try {
        final ev = EventItem.fromJson(Map<String,dynamic>.from(r));
        if(ev.id!=0 && ev.title.isNotEmpty){
          list.add(ev);
        } else {
          // ignore: avoid_print
          print('[events][skip-invalid] raw=$r');
        }
      } catch(err,st){
        // ignore: avoid_print
        print('[events][parse-error] $err\n$st raw=$r');
      }
    }
    return list;
  }

  /// Paginated events request. Returns (items, hasMore)
  @override
  Future<(List<EventItem>, bool)> fetchEventsPaged({int page=1,int perPage=20,String? status,String? type,String? audience,String? city}) async {
    final params = <String,String>{'page':page.toString(),'per_page':perPage.toString()};
    if(status!=null && status.isNotEmpty) params['status']=status;
    if(type!=null && type.isNotEmpty) params['type']=type;
    if(audience!=null && audience.isNotEmpty) params['audience']=audience;
    if(city!=null && city.isNotEmpty) params['city']=city;
    final qs = '?${params.entries.map((e)=> '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}').join('&')}';
    final json = await client.get('/events$qs');
    List rawList = const [];
    int currentPage = page;
    int lastPage = page;
    if(json is Map){
      if(json['data'] is List){ rawList = List.from(json['data']); }
      if(json['current_page'] is int) currentPage = json['current_page'];
      if(json['last_page'] is int) lastPage = json['last_page'];
    } else if(json is List){
      rawList = json;
      lastPage = currentPage; // no pagination metadata
    }
    final items = <EventItem>[];
    for(final r in rawList.whereType<Map>()){
      try {
        final ev = EventItem.fromJson(Map<String,dynamic>.from(r));
        if(ev.id!=0 && ev.title.isNotEmpty){
          items.add(ev);
        } else {
          // ignore: avoid_print
          print('[events][skip-invalid] raw=$r');
        }
      } catch(err,st){
        // ignore: avoid_print
        print('[events][parse-error] $err\n$st raw=$r');
      }
    }
    final hasMore = currentPage < lastPage;
    return (items, hasMore);
  }

  @override
  Future<AppVersionInfo?> latestVersion() async {
    final json = await client.get('/version/latest');
    if(json==null) return null;
    return AppVersionInfo.fromJson(json);
  }
}
