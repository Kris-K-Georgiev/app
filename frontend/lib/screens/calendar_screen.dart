import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../providers/content_provider.dart';
import '../models/event.dart';
import 'event_detail_screen.dart';
import '../icons/app_icons.dart';

class CalendarScreen extends StatefulWidget { const CalendarScreen({super.key}); @override State<CalendarScreen> createState()=> _CalendarScreenState(); }
class _CalendarScreenState extends State<CalendarScreen>{
  DateTime focused = DateTime.now();
  DateTime? selected;
  Map<DateTime,List<EventItem>> grouped = {};

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    final events = context.watch<ContentProvider>().events;
    grouped = {};
    for(final e in events){
      final base = e.startDate ?? e.primaryDate;
      // If multi-day include each day span for highlighting events across range
      if(e.startDate!=null && e.endDate!=null){
        var d = DateTime(e.startDate!.year, e.startDate!.month, e.startDate!.day);
        final last = DateTime(e.endDate!.year, e.endDate!.month, e.endDate!.day);
        while(!d.isAfter(last)){
          grouped.putIfAbsent(d, ()=> []).add(e);
          d = d.add(const Duration(days:1));
        }
      } else {
        final day = DateTime(base.year, base.month, base.day);
        grouped.putIfAbsent(day, ()=> []).add(e);
      }
    }
  }

  List<EventItem> _eventsForDay(DateTime day){
    final key = DateTime(day.year, day.month, day.day);
    return grouped[key] ?? [];
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text('Календар', style: TextStyle(fontWeight: FontWeight.w700))),
      body: Column(
        children: [
          TableCalendar<EventItem>(
            focusedDay: focused,
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            eventLoader: _eventsForDay,
            selectedDayPredicate: (d)=> selected!=null && d.year==selected!.year && d.month==selected!.month && d.day==selected!.day,
            onDaySelected: (sel, foc){ setState((){ selected = sel; focused=foc; }); },
            calendarFormat: CalendarFormat.month,
            startingDayOfWeek: StartingDayOfWeek.monday,
            locale: 'bg_BG',
          ),
          const Divider(),
          Expanded(
            child: ListView(
              children: _eventsForDay(selected ?? DateTime.now()).map((e){
                final df = DateFormat('yyyy-MM-dd');
                final dateStr = e.startDate!=null && e.endDate!=null
                  ? (df.format(e.startDate!) == df.format(e.endDate!)
                      ? df.format(e.startDate!)
                      : '${df.format(e.startDate!)} – ${df.format(e.endDate!)}')
                  : (e.startDate!=null ? df.format(e.startDate!) : df.format(e.primaryDate));
                Widget? trailing;
                final neutral = Theme.of(context).colorScheme.onSurface;
                if(e.userStatus == 'confirmed'){
                  trailing = AppIcons.statusConfirmed(color: neutral);
                } else if(e.userStatus == 'waitlist'){
                  trailing = AppIcons.statusWaitlist(color: neutral.withOpacity(.7));
                } else if(e.isPast){
                  trailing = AppIcons.history(color: neutral.withOpacity(.6));
                }
                return ListTile(
                  title: Text(e.title),
                  subtitle: Text(dateStr + (e.days!=null ? (e.days==1? ' • 1 ден' : ' • ${e.days} дни') : '')),
                  trailing: trailing,
                  onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> EventDetailScreen(event: e))),
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }
}
