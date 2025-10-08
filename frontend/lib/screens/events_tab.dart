import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

import '../providers/content_provider.dart';
import '../models/event.dart';
import '../ui/meta_chip.dart';
import '../ui/content_media_card.dart';
import '../theme/design_tokens.dart';
import '../theme/event_type_colors.dart';
import '../icons/app_icons.dart';
import '../utils/responsive.dart';
import 'event_detail_screen.dart';

/// Old design restoration of Events tab (list/calendar with inline filters)
class EventsTab extends StatefulWidget {
  const EventsTab({super.key});
  @override
  State<EventsTab> createState() => _EventsTabState();
}

enum _LayoutMode { list, calendar }

class _EventsTabState extends State<EventsTab> {
  // Filters
  String _aud = 'all';
  String _status = 'active';
  String? _type;
  String? _city;
  _LayoutMode _mode = _LayoutMode.list;

  // Calendar state
  DateTime _focused = DateTime.now();
  DateTime? _selDay;
  Map<DateTime, List<EventItem>>? _calendarCache;
  String _calendarHash = '';
  final LinkedHashMap<String, Map<DateTime, List<EventItem>>> _calendarLru = LinkedHashMap();

  // Progressive reveal
  int _cap = 48;
  Timer? _grow;
  Timer? _debounce;
  DateTime _lastLoadReq = DateTime.fromMillisecondsSinceEpoch(0);
  final Map<int, List<Widget>> _metaCache = {};
  final Map<String, Color> _cityColors = {};

  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _restorePrefs();
  }

  Future<void> _restorePrefs() async {
    final p = await SharedPreferences.getInstance();
    if(!mounted) return; // safety guard to avoid setState after dispose
    setState(() {
      _aud = p.getString('events_audience') ?? 'all';
      _status = p.getString('events_status') ?? 'active';
      final t = p.getString('events_type');
      if (t != null && t.isNotEmpty) _type = t;
      final c = p.getString('events_city');
      if (c != null && c.isNotEmpty) _city = c;
      final m = p.getString('events_mode');
      if (m != null) {
        _mode = _LayoutMode.values.firstWhere(
          (e) => e.name == m,
          orElse: () => _LayoutMode.list,
        );
      }
    });
    // Trigger initial load
    if(mounted){
      // Avoid unhandled exception bringing whole build down
      unawaited(_reload());
    }
  }

  void _queueReload() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 260), _reload);
  }

  Future<void> _reload() async {
    if(!mounted) return;
    _metaCache.clear();
    _cap = 48;
    _grow?.cancel();
    ContentProvider? cp;
    try {
      cp = context.read<ContentProvider>();
    } catch(_){
      return; // context no longer valid
    }
    try {
      await cp.reloadEvents(
        status: _status == 'all' ? null : _status,
        type: _type,
        audience: _aud == 'all' ? null : _aud,
        city: _city,
      );
    } catch(err, st){
      // ignore: avoid_print
      print('[events][reload][error] $err\n$st');
    }
    if(!mounted) return;
    _calendarCache = null;
    _calendarHash = '';
    _calendarLru.clear();
  }

  void _progressive(int total) {
    if (total <= _cap || _grow != null) return;
    final chunk = (total / 9).ceil().clamp(32, 180);
    _grow = Timer.periodic(const Duration(milliseconds: 160), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_cap >= total) {
        t.cancel();
        _grow = null;
        return;
      }
      setState(() => _cap = math.min(_cap + chunk, total));
    });
  }

  void _debugLog(String msg){
    // Central place to toggle verbose diagnostics; set to false to silence.
    const verbose = true; // set false to disable
    if(verbose){
      // ignore: avoid_print
      print('[events][diag] $msg');
    }
  }

  void _loadMoreDebounced() {
    final now = DateTime.now();
    if (now.difference(_lastLoadReq).inMilliseconds < 320) return;
    _lastLoadReq = now;
    final cp = context.read<ContentProvider>();
    if (!cp.eventsHasMore || cp.eventsLoadingMore) return;
    cp.loadMoreEvents(
      status: _status == 'all' ? null : _status,
      type: _type,
      audience: _aud == 'all' ? null : _aud,
      city: _city,
    );
  }

  Color _cityColor(String city, ColorScheme s) => _cityColors.putIfAbsent(city, () {
        final palette = [
          s.primary,
          s.secondary,
          s.tertiary,
          s.primaryContainer,
          s.secondaryContainer,
          s.tertiaryContainer,
        ];
        final h = city.codeUnits.fold<int>(0, (a, b) => (a * 33 + b) & 0x7fffffff);
        return palette[h % palette.length];
      });

  Map<DateTime, List<EventItem>> _buildCalendar(List<EventItem> list) {
    if (_mode != _LayoutMode.calendar) return const {};
    final key = 'all_${list.length}_${list.isNotEmpty ? list.first.id : 0}_${list.isNotEmpty ? list.last.id : 0}';
    if (_calendarCache != null && _calendarHash == key) return _calendarCache!;
    if (_calendarLru.containsKey(key)) {
      final hit = _calendarLru.remove(key)!;
      _calendarLru[key] = hit;
      _calendarCache = hit;
      _calendarHash = key;
      return hit;
    }
    final map = <DateTime, List<EventItem>>{};
    for (final e in list) {
      final st = e.startDate ?? e.primaryDate;
      final en = e.endDate ?? st;
      var d = DateTime(st.year, st.month, st.day);
      final last = DateTime(en.year, en.month, en.day);
      int guard = 0;
      while (!d.isAfter(last)) {
        final k = DateTime(d.year, d.month, d.day);
        (map[k] ??= <EventItem>[]).add(e);
        d = d.add(const Duration(days: 1));
        if (++guard > 62) break; // safety
      }
    }
    _calendarCache = map;
    _calendarHash = key;
    _calendarLru[key] = map;
    if (_calendarLru.length > 5) {
      _calendarLru.remove(_calendarLru.keys.first);
    }
    return map;
  }

  List<Widget> _meta(EventItem e, {bool compact = false, Color? cc}) {
    if (compact) {
      final start = e.startDate ?? e.primaryDate;
      final end = e.endDate;
      String f(DateTime d) => '${d.month}/${d.day}';
      final date = end != null && end.isAfter(start) ? '${f(start)}-${f(end)}' : f(start);
      return [MetaChip(label: date, dense: true)];
    }
    final cached = _metaCache[e.id];
    if (cached != null) return cached;
    String fmt(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final start = e.startDate ?? e.primaryDate;
    final end = e.endDate;
    final range = (end != null && end.isAfter(start)) ? '${fmt(start)} → ${fmt(end)}' : fmt(start);
    final chips = <Widget>[MetaChip(label: range, dense: true)];
    if (cc != null) {
      // Show city name explicitly
      if(e.city != null && e.city!.isNotEmpty){
        chips.add(MetaChip(label: e.city!, dotColor: cc, dense: true));
      } else {
        chips.add(MetaChip(label: '', dotColor: cc, dense: true));
      }
    }
    if (e.isPast) chips.add(const MetaChip(label: 'Минало', dense: true));
    if ((e.status ?? 'active') != 'active') chips.add(const MetaChip(label: 'Неактивно', dense: true));
    if (e.limit != null && e.registrationsCount != null) {
      final rem = e.limit! - e.registrationsCount!.clamp(0, e.limit!);
      chips.add(MetaChip(label: 'Места $rem/${e.limit}', dense: true));
    }
    _metaCache[e.id] = chips;
    return chips;
  }

  Future<void> _onRefresh() async => _reload();

  Future<void> _setMode(_LayoutMode m) async {
    if (_mode == m) return;
    setState(() => _mode = m);
    final p = await SharedPreferences.getInstance();
    p.setString('events_mode', m.name);
    if (m == _LayoutMode.calendar) {
      _selDay = null;
      _calendarCache = null;
      _calendarHash = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cp = context.watch<ContentProvider>();
    final scheme = Theme.of(context).colorScheme;
    // Вземаме вече филтрираните събития
    final filteredEvents = cp.events.where((e) {
  if (_status != 'all' && (e.status ?? 'active') != _status) return false;
  if (_type != null && e.type?.slug != _type) return false;
  // if (_aud == 'open' && !(e.isOpen ?? false)) return false; // премахнато, ако няма isOpen
  if (_aud == 'city' && (e.city == null || e.city!.isEmpty)) return false;
  if (_aud == 'limited' && (e.limit == null || e.limit == 0)) return false;
  if (_city != null && e.city != _city) return false;
  return true;
    }).toList();

    _debugLog('build start: events=${filteredEvents.length} loading=${cp.eventsLoading} error=${cp.eventsError} mode=${_mode.name}');

    _progressive(filteredEvents.length);

    final calendarMap = _buildCalendar(filteredEvents);

    List<EventItem> currentList() {
  return filteredEvents;
    }

    final list = currentList();
    final cities = <String>{
      for (final e in filteredEvents)
        if (e.city != null && e.city!.isNotEmpty) e.city!
    };

    return RefreshIndicator(
      onRefresh: _onRefresh,
      edgeOffset: 100,
      child: LayoutBuilder(builder: (ctx, constraints) {
        final w = constraints.maxWidth;
        final contentW = maxContentWidth(w);
        final sidePad = ((w - contentW) / 2).clamp(0, 600).toDouble();
        final wide = w >= 1300;

        // FILTERS ----------------------------------------------------
        Widget filtersSection() {
          InputChip buildFilter({
            required String label,
            required bool selected,
            required VoidCallback onTap,
            IconData? icon,
          }) {
            return InputChip(
              label: Text(label),
              selected: selected,
              onPressed: onTap,
              avatar: icon != null ? Icon(icon, size: 16) : null,
              selectedColor: scheme.primary.withOpacity(.18),
              side: BorderSide(
                color: (selected ? scheme.primary : scheme.outlineVariant)
                    .withOpacity(.5),
              ),
              visualDensity: VisualDensity.compact,
              labelStyle: TextStyle(
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            );
          }

          final resetActive =
              _type != null || _status != 'active' || _aud != 'all' || _city != null;

          final row1 = [
            SegmentedButton<_LayoutMode>(
              segments: const [
                ButtonSegment(
                    value: _LayoutMode.list,
                    icon: Icon(Icons.view_list),
                    label: Text('Списък')),
                ButtonSegment(
                    value: _LayoutMode.calendar,
                    icon: Icon(Icons.calendar_month),
                    label: Text('Календар')),
              ],
              selected: <_LayoutMode>{_mode},
              onSelectionChanged: (s) => _setMode(s.first),
              style: const ButtonStyle(visualDensity: VisualDensity.compact),
            ),
            const SizedBox(width: 12),
            buildFilter(
                label: 'Отворени',
                selected: _aud == 'open',
                onTap: () {
                  setState(() => _aud = 'open');
                  _queueReload();
                }),
            buildFilter(
                label: 'По град',
                selected: _aud == 'city',
                onTap: () {
                  setState(() => _aud = 'city');
                  _queueReload();
                }),
            buildFilter(
                label: 'Ограничени',
                selected: _aud == 'limited',
                onTap: () {
                  setState(() => _aud = 'limited');
                  _queueReload();
                }),
            buildFilter(
                label: 'Всички',
                selected: _aud == 'all',
                onTap: () {
                  setState(() => _aud = 'all');
                  _queueReload();
                }),
            buildFilter(
                label: 'Активни',
                selected: _status == 'active',
                onTap: () {
                  setState(() => _status = 'active');
                  _queueReload();
                }),
            buildFilter(
                label: 'Неактивни',
                selected: _status == 'inactive',
                onTap: () {
                  setState(() => _status = 'inactive');
                  _queueReload();
                }),
          ];

          final types = {
            for (final e in filteredEvents)
              if (e.type != null) e.type!.slug: e.type
          }.values.whereType();
          final typeWrap = [
            for (final t in types)
              buildFilter(
                  label: t!.name,
                  selected: _type == t.slug,
                  onTap: () {
                    setState(() => _type = _type == t.slug ? null : t.slug);
                    _queueReload();
                  })
          ];
          final cityWrap = [
            for (final c in cities.take(20))
              buildFilter(
                  label: c,
                  selected: _city == c,
                  onTap: () {
                    setState(() => _city = _city == c ? null : c);
                    _queueReload();
                  })
          ];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(spacing: 8, runSpacing: 8, children: row1),
              if (typeWrap.isNotEmpty)
                Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Wrap(spacing: 8, runSpacing: 8, children: typeWrap)),
              if (cityWrap.isNotEmpty)
                Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Wrap(spacing: 8, runSpacing: 8, children: cityWrap)),
              if (resetActive)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: TextButton.icon(
                    onPressed: () async {
                      setState(() {
                        _type = null;
                        _status = 'active';
                        _aud = 'all';
                        _city = null;
                      });
                      final p = await SharedPreferences.getInstance();
                      p
                        ..setString('events_type', '')
                        ..setString('events_status', 'active')
                        ..setString('events_audience', 'all')
                        ..setString('events_city', '');
                      _queueReload();
                    },
                    label: const Text('Изчисти филтрите'),
                  ),
                ),
            ],
          );
        }

        // CALENDAR ---------------------------------------------------
        Widget calendarSection() {
          if (_mode != _LayoutMode.calendar) return const SizedBox.shrink();
          try {
            return Padding(
              padding: EdgeInsets.fromLTRB(8 + sidePad, 12, 8 + sidePad, 8),
              child: LayoutBuilder(
                builder: (ctx, constraints) {
                  final calWidth = constraints.maxWidth < 500 ? constraints.maxWidth - 16 : 480;
                  return TableCalendar<EventItem>(
                    focusedDay: _focused,
                    firstDay: DateTime(DateTime.now().year - 1, 1, 1),
                    lastDay: DateTime(DateTime.now().year + 1, 12, 31),
                    locale: 'bg_BG',
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    calendarFormat: CalendarFormat.month,
                    availableCalendarFormats: const { CalendarFormat.month: 'Месец' },
                    headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                    daysOfWeekVisible: true,
                    selectedDayPredicate: (d) => _selDay != null && d.year == _selDay!.year && d.month == _selDay!.month && d.day == _selDay!.day,
                    onDaySelected: (s, f) { setState(() { _selDay = s; _focused = f; }); },
                    onPageChanged: (f) { setState(() => _focused = f); },
                    eventLoader: (d) {
                      try {
                        final k = DateTime(d.year, d.month, d.day);
                        return calendarMap[k] ?? [];
                      } catch(err){
                        _debugLog('calendar eventLoader error: $err');
                        return const [];
                      }
                    },
                    calendarStyle: CalendarStyle(
                      markersAlignment: Alignment.bottomCenter,
                      markersMaxCount: 4,
                      markerDecoration: const BoxDecoration(shape: BoxShape.circle),
                      cellMargin: EdgeInsets.all(calWidth < 400 ? 2 : 4),
                      cellPadding: EdgeInsets.all(calWidth < 400 ? 2 : 6),
                    ),
                    calendarBuilders: CalendarBuilders<EventItem>(
                      markerBuilder: (ctx, date, evs) {
                        try {
                          if (evs.isEmpty) return const SizedBox.shrink();
                          return Wrap(
                            spacing: calWidth < 400 ? 1 : 2,
                            runSpacing: calWidth < 400 ? 1 : 2,
                            children: [
                              for (final e in evs.take(4))
                                Container(
                                  width: calWidth < 400 ? 5 : 7,
                                  height: calWidth < 400 ? 5 : 7,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: e.city != null
                                        ? _cityColor(e.city!, Theme.of(ctx).colorScheme)
                                        : Theme.of(ctx).colorScheme.primary,
                                  ),
                                ),
                              if (evs.length > 4)
                                Text(
                                  '+',
                                  style: TextStyle(fontSize: calWidth < 400 ? 7 : 9),
                                ),
                            ],
                          );
                        } catch(err){
                          _debugLog('calendar markerBuilder error: $err');
                          return const SizedBox.shrink();
                        }
                      },
                    ),
                  );
                },
              ),
            );
          } catch(err){
            _debugLog('calendar build error: $err');
            return Padding(
              padding: EdgeInsets.fromLTRB(16+sidePad,12,16+sidePad,8),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: scheme.error.withOpacity(.4)),
                  borderRadius: BorderRadius.circular(12),
                  color: scheme.errorContainer.withOpacity(.3),
                ),
                child: Row(children:[
                  Icon(Icons.error_outline, color: scheme.error),
                  const SizedBox(width:12),
                  Expanded(child: Text('Календарът временно недостъпен', style: Theme.of(context).textTheme.bodyMedium)),
                ]),
              ),
            );
          }
        }

        // EMPTY ------------------------------------------------------
        Widget emptyState() {
          return Padding(
            padding: EdgeInsets.fromLTRB(24 + sidePad, 40, 24 + sidePad, 120),
            child: Column(
              children: [
                AppIcons.events(
                  color: scheme.onSurface.withOpacity(.35),
                  size: 58,
                ),
                const SizedBox(height: 16),
                Text(
                  'Няма събития',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Променете филтрите или изберете друга дата.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: scheme.onSurface.withOpacity(.6)),
                ),
                const SizedBox(height: 24),
                // Event creation is handled in the admin panel; no create button in the app
              ],
            ),
          );
        }

        // CARD -------------------------------------------------------
        Widget buildCard(EventItem e,
            {required bool compact, required bool allowHero}) {
          Color? typeColor;
          final type = e.type;
          if (!compact && type != null) {
            typeColor = scheme.primary;
            try {
              final dynamic ext = Theme.of(context).extension<EventTypeColors>();
              if (ext is EventTypeColors) {
                typeColor = ext.colors[type.slug] ??
                    EventTypeColors.parseBackendHex(type.color) ??
                    EventTypeColors.hashColor(type.slug, scheme);
              }
            } catch (_) {}
          }
          return ContentMediaCard(
            heroTag: allowHero ? 'event_img_${e.id}' : null,
            imageUrl: e.cover ?? (e.images.isNotEmpty ? e.images.first : null),
            title: e.title,
            body: null,
            heroPrecache: !compact,
            heroEnableFade: !compact,
            metaChips: _meta(e,
                compact: compact,
                cc: !compact && e.city != null
                    ? _cityColor(e.city!, scheme)
                    : null),
            trailingBadge: (!compact && e.type != null)
                ? Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppTokens.space3,
                        vertical: AppTokens.space2 - 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: (typeColor ?? scheme.primary).withOpacity(.12),
                      border: Border.all(
                        color: (typeColor ?? scheme.primary).withOpacity(.55),
                      ),
                    ),
                    child: Text(
                      e.type!.name,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: (typeColor ?? scheme.primary).withOpacity(.9),
                      ),
                    ),
                  )
                : null,
            memCacheOverride: compact ? 420 : null,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EventDetailScreen(event: e),
              ),
            ),
          );
        }

        SliverMultiBoxAdaptorWidget sliverStrategy() {
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) {
                if (i >= list.length) return const SizedBox.shrink();
                if (i >= _cap) {
                  return const Padding(
                    padding: EdgeInsets.only(bottom: AppTokens.space4),
                    child: ContentMediaCardSkeleton(
                      showImage: true,
                      bodyLines: 0,
                      showMeta: false,
                    ),
                  );
                }
                final e = list[i];
                try {
                  return Padding(
                    padding: EdgeInsets.fromLTRB(
                        16 + sidePad, 0, 16 + sidePad, AppTokens.space4),
                    child: RepaintBoundary(
                      child: buildCard(
                        e,
                        compact: false,
                        allowHero: list.length <= 160,
                      ),
                    ),
                  );
                } catch (err, st) {
                  // ignore: avoid_print
                  print('[events][card-error] $err\n$st');
                  return Padding(
                    padding: EdgeInsets.fromLTRB(
                        16 + sidePad, 0, 16 + sidePad, AppTokens.space4),
                    child: ListTile(
                      title: Text(e.title),
                      subtitle: const Text('Грешка при визуализация'),
                    ),
                  );
                }
              },
              childCount: math.min(list.length, _cap + 6),
              addRepaintBoundaries: true,
              addAutomaticKeepAlives: false,
              addSemanticIndexes: false,
            ),
          );
        }

        Widget? dayHeader() {
          if (_mode != _LayoutMode.calendar) return null;
          final day = _selDay ?? _focused;
          final formatted =
              '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
          if (list.isEmpty) return null;
          return SliverPersistentHeader(
            pinned: true,
            delegate: _SimpleHeaderDelegate(
              height: 42,
              child: Container(
                color: Theme.of(context)
                    .scaffoldBackgroundColor
                    .withOpacity(.94),
                padding: EdgeInsets.fromLTRB(16 + sidePad, 8, 16 + sidePad, 6),
                child: Row(
                  children: [
                    Icon(Icons.event, size: 18, color: scheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      formatted,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Text(
                      '${list.length} събития',
                      style: Theme.of(context).textTheme.labelSmall,
                    )
                  ],
                ),
              ),
            ),
          );
        }

        final slivers = <Widget>[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 24, left: 32, right: 32, bottom: 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Събития',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 28,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ];

        // Error banner (restored minimal safety layer)
        if (cp.eventsError) {
          slivers.add(
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.fromLTRB(16 + sidePad, 12, 16 + sidePad, 0),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: scheme.errorContainer.withOpacity(.65),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: scheme.error.withOpacity(.55)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.error_outline, color: scheme.error),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Грешка при зареждане на събития', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text('Натисни опитай отново или промени филтрите.', style: Theme.of(context).textTheme.bodySmall),
                          const SizedBox(height: 8),
                          Wrap(spacing: 8, children: [
                            FilledButton.tonal(onPressed: (){ _reload(); }, child: const Text('Опитай отново')),
                            OutlinedButton(onPressed: (){ setState((){ _type=null; _status='active'; _aud='all'; _city=null; }); _reload(); }, child: const Text('Нулирай филтри')),
                          ])
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

  if (cp.eventsLoading && filteredEvents.isEmpty) {
          slivers.add(
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16 + sidePad, 16, 16 + sidePad, 120),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => const Padding(
                    padding: EdgeInsets.only(bottom: AppTokens.space4),
                    child: ContentMediaCardSkeleton(),
                  ),
                  childCount: 6,
                ),
              ),
            ),
          );
        } else {
          if (_mode == _LayoutMode.calendar) {
            slivers.add(SliverToBoxAdapter(child: calendarSection()));
          }
          if (!wide) {
            slivers.add(
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      EdgeInsets.fromLTRB(16 + sidePad, 12, 16 + sidePad, 4),
                  child: filtersSection(),
                ),
              ),
            );
          }
          final stickyDay = dayHeader();
            if (stickyDay != null) slivers.add(stickyDay);
          if (list.isEmpty) {
            slivers.add(SliverToBoxAdapter(child: emptyState()));
          } else {
            final strat = sliverStrategy();
            slivers.add(strat);
          }
          if (cp.eventsLoadingMore) {
            slivers.add(
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 26),
                  child: Center(
                    child: SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(strokeWidth: 2.2),
                    ),
                  ),
                ),
              ),
            );
          }
          if (!cp.eventsLoadingMore && !cp.eventsHasMore && filteredEvents.isNotEmpty) {
            slivers.add(
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Center(
                    child: Text(
                      'Няма повече събития',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: scheme.onSurface.withOpacity(.6)),
                    ),
                  ),
                ),
              ),
            );
          }
          slivers.add(
            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.of(context).padding.bottom + 110,
              ),
            ),
          );
        }

        Widget scrollContent = NotificationListener<ScrollNotification>(
          onNotification: (n) {
            if (n.metrics.maxScrollExtent <= 0) return false;
            final ratio =
                (n.metrics.pixels / n.metrics.maxScrollExtent).clamp(0, 1);
            if (ratio >= .70) {
              _loadMoreDebounced();
            }
            return false;
          },
          child: CustomScrollView(
            controller: _scroll,
            slivers: slivers,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
          ),
        );

        _debugLog('build end: slivers=${slivers.length} listCount=${list.length} cap=$_cap');

        Widget scroll = AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
          child: KeyedSubtree(key: ValueKey(_mode), child: scrollContent),
        );
        if (!wide) return scroll; // narrow layout: inline filters

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 260,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16 + sidePad, 140, 12, 180),
                child: filtersSection(),
              ),
            ),
            Expanded(child: scroll),
          ],
        );
      }),
    );
  }

  @override
  void dispose() {
    _grow?.cancel();
    _debounce?.cancel();
    _scroll.dispose();
    super.dispose();
  }
}

class _SimpleHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;
  _SimpleHeaderDelegate({required this.height, required this.child});
  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) =>
      child;
  @override
  bool shouldRebuild(covariant _SimpleHeaderDelegate old) =>
      old.child != child || old.height != height;
}