class EventItem {
  final int id;
  final String title;
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? startTime; // HH:mm
  final String? location;
  final String? cover;
  final String? city;
  final String? audience; // open|city|limited
  final int? limit;
  final int? registrationsCount;
  final List<String> images;
  final int? days; // optional days count from backend
  final String? userStatus; // confirmed | waitlist | null
  final String? status; // active|inactive
  final EventTypeRef? type; // nullable event type
  final int? userId; // owner / creator id

  EventItem({
    required this.id,
    required this.title,
    this.description,
    this.startDate,
    this.endDate,
    this.startTime,
    this.location,
    this.cover,
    this.city,
    this.audience,
    this.limit,
    this.registrationsCount,
    required this.images,
    this.days,
    this.userStatus,
    this.status,
    this.type,
    this.userId,
  });

  DateTime get primaryDate => startDate ?? DateTime.now();
  bool get isPast => (endDate ?? startDate ?? primaryDate).isBefore(DateTime.now());
  bool get isMultiDay => startDate!=null && endDate!=null && endDate!.difference(startDate!).inDays != 0;

  factory EventItem.fromJson(Map<String,dynamic> j){
    int parseInt(dynamic v){ if(v is int) return v; if(v is String) return int.tryParse(v)??0; return int.tryParse(v?.toString()??'')??0; }
    DateTime? parseDate(dynamic v){ if(v==null) return null; final s=v.toString(); if(s.isEmpty) return null; return DateTime.tryParse(s); }
    List<String> parseImages(dynamic v){ if(v is List){ return v.whereType<String>().toList(); } return const []; }
    EventTypeRef? parseType(dynamic v){ if(v is Map<String,dynamic>){ try{ return EventTypeRef.fromJson(v); }catch(_){ return null; } } return null; }
    return EventItem(
      id: parseInt(j['id']),
      title: (j['title']??'').toString(),
      description: j['description']?.toString(),
      startDate: parseDate(j['start_date']),
      endDate: parseDate(j['end_date']),
      startTime: j['start_time']?.toString(),
      location: j['location']?.toString(),
      cover: j['cover']?.toString(),
      city: j['city']?.toString(),
      audience: j['audience']?.toString(),
      limit: ((){ final v=j['limit']; if(v is int) return v; return int.tryParse(v?.toString()??''); })(),
      registrationsCount: ((){ final v=j['registrations_count']; if(v is int) return v; return int.tryParse(v?.toString()??''); })(),
      images: parseImages(j['images']),
      days: ((){ final v=j['days']; if(v is int) return v; return int.tryParse(v?.toString()??''); })(),
      userStatus: j['user_status']?.toString(),
      status: j['status']?.toString(),
      type: parseType(j['event_type']),
      userId: ((){ final v=j['user_id'] ?? j['created_by']; if(v is int) return v; return int.tryParse(v?.toString()??''); })(),
    );
  }
}

class EventTypeRef {
  final int id; final String slug; final String name; final String? color;
  EventTypeRef({required this.id, required this.slug, required this.name, this.color});
  factory EventTypeRef.fromJson(Map<String,dynamic> j)=> EventTypeRef(
    id: j['id'] ?? 0,
    slug: j['slug'] ?? '',
    name: j['name'] ?? '',
    color: j['color'],
  );
}
