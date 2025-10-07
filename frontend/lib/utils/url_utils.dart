import '../core/config.dart';

/// Returns an absolute URL for a backend-provided path.
/// If the value is already an absolute http(s) URL, it is returned unchanged.
/// Otherwise, it prefixes the backend base (without '/api') to the path.
String? absUrl(String? path){
  if(path==null || path.isEmpty) return path;
  if(path.startsWith('http')) return path;
  final base = AppConfig.apiBaseUrl.replaceFirst('/api','');
  if(path.startsWith('/')) return '$base$path';
  return '$base/$path';
}

List<String> absUrls(List<String> paths){
  final base = AppConfig.apiBaseUrl.replaceFirst('/api','');
  return paths.map((p){
    if(p.isEmpty) return p;
    if(p.startsWith('http')) return p;
    if(p.startsWith('/')) return '$base$p';
    return '$base/$p';
  }).toList();
}