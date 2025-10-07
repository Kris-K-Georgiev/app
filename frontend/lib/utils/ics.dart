import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Builds a minimal RFC5545 iCalendar string for a single event.
String buildEventIcs({
  required int id,
  required String title,
  String? description,
  required DateTime start,
  required DateTime end,
}) {
  String esc(String v) => v
      .replaceAll('\\', '\\\\')
      .replaceAll(',', '\\,')
      .replaceAll('\n', '\\n');
  String fmt(DateTime d) => '${d.toUtc().toIso8601String().replaceAll('-', '').replaceAll(':', '').split('.').first}Z';
  return [
    'BEGIN:VCALENDAR',
    'VERSION:2.0',
  'PRODID:-//БХСС//BG',
    'BEGIN:VEVENT',
  'UID:$id@бхсс.бг',
    'DTSTAMP:${fmt(DateTime.now())}',
    'DTSTART:${fmt(start)}',
    'DTEND:${fmt(end.add(const Duration(days:1)))}',
    'SUMMARY:${esc(title)}',
    'DESCRIPTION:${esc(description ?? '')}',
    'END:VEVENT',
    'END:VCALENDAR'
  ].join('\n');
}

/// Writes the ICS content to a temporary file and returns the File reference.
Future<File> writeIcsTemp(String icsContent, {String filename = 'event.ics'}) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$filename');
  return file.writeAsString(icsContent, flush: true);
}
