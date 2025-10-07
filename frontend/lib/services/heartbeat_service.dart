import 'dart:async';
import 'api_client.dart';

class HeartbeatSnapshot {
  final int? latestNewsId;
  final int? latestEventId;
  final String? newsUpdatedAt;
  final String? eventsUpdatedAt;
  final int usersCount;
  final DateTime ts;
  HeartbeatSnapshot({this.latestNewsId,this.latestEventId,this.newsUpdatedAt,this.eventsUpdatedAt,required this.usersCount,required this.ts});
  factory HeartbeatSnapshot.fromJson(Map<String,dynamic> j)=> HeartbeatSnapshot(
    latestNewsId: j['latest_news_id'] as int?,
    latestEventId: j['latest_event_id'] as int?,
    newsUpdatedAt: j['news_updated_at']?.toString(),
    eventsUpdatedAt: j['events_updated_at']?.toString(),
    usersCount: (j['users_count'] is int)? j['users_count'] : int.tryParse(j['users_count']?.toString()??'0') ?? 0,
    ts: DateTime.now(),
  );
}

class HeartbeatService {
  final ApiClient client;
  Duration interval;
  Timer? _timer;
  HeartbeatSnapshot? last;
  final _controller = StreamController<HeartbeatSnapshot>.broadcast();
  Stream<HeartbeatSnapshot> get stream => _controller.stream;
  int _stableCycles = 0;

  HeartbeatService(this.client,{this.interval = const Duration(seconds:30)});

  void start(){ stop(); _tick(); _timer = Timer.periodic(interval, (_)=> _tick()); }
  void stop(){ _timer?.cancel(); _timer=null; }

  Future<void> _tick() async {
    try {
      final json = await client.get('/heartbeat');
      if(json is Map<String,dynamic>){
        final snap = HeartbeatSnapshot.fromJson(json);
        final changed = last==null || (snap.latestNewsId!=last!.latestNewsId) || (snap.latestEventId!=last!.latestEventId) || json['has_changes']==true;
        if(changed){
          _stableCycles = 0;
        } else {
          _stableCycles += 1;
        }
        last = snap; _controller.add(snap);
        // Adaptive: shorten if changes, lengthen if stable
        final desired = changed ? const Duration(seconds:15) : (_stableCycles>5 ? const Duration(seconds:60) : interval);
        if(desired.inSeconds != interval.inSeconds){
          interval = desired;
          if(_timer!=null){ start(); }
        }
      }
    } catch(_){ /* swallow for stability */ }
  }

  void dispose(){ stop(); _controller.close(); }
}
