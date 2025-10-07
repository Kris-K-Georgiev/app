import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../core/config.dart';

/// Custom exception to provide richer context for API failures.
class ApiException implements Exception {
  final int statusCode;
  final String path;
  final String message;
  final String? responseBody;
  ApiException({required this.statusCode, required this.path, required this.message, this.responseBody});
  @override
  String toString() => 'ApiException($statusCode $path: $message${responseBody == null || responseBody!.isEmpty ? '' : ' => ${_shortened(responseBody!)}'})';

  static String _shortened(String s) {
    if (s.length <= 180) return s;
    return '${s.substring(0, 180)}…';
  }
}

class ApiClient {
  ApiClient(this._token, {this.debug = false, Duration? timeout}) : requestTimeout = timeout ?? defaultTimeout;
  String? _token;
  final bool debug;
  static const Duration defaultTimeout = Duration(seconds: 8);
  final Duration requestTimeout; // per-request timeout
  set token(String? t)=> _token = t;
  String? get token => _token; // exposed for read-only (tests / diagnostics)

  Map<String,String> _headers() => {
    'Accept':'application/json',
    if(_token!=null) 'Authorization':'Bearer $_token'
  };

  Uri _uri(String path) => Uri.parse('${AppConfig.apiBaseUrl}$path');

  Future<dynamic> get(String path) async {
    final uri = _uri(path);
    http.Response res;
    try {
      res = await http.get(uri, headers: _headers()).timeout(requestTimeout);
    } on TimeoutException {
      throw ApiException(statusCode: 408, path: path, message: 'Timeout (GET)');
    }
    return _handle(res, path);
  }

  Future<dynamic> post(String path, Map body) async {
    final uri = _uri(path);
    http.Response res;
    try {
      res = await http.post(uri, headers: {..._headers(),'Content-Type':'application/json'}, body: jsonEncode(body)).timeout(requestTimeout);
    } on TimeoutException {
      throw ApiException(statusCode: 408, path: path, message: 'Timeout (POST)');
    }
    return _handle(res, path);
  }

  Future<dynamic> put(String path, Map body) async {
    final uri = _uri(path);
    http.Response res;
    try {
      res = await http.put(uri, headers: {..._headers(),'Content-Type':'application/json'}, body: jsonEncode(body)).timeout(requestTimeout);
    } on TimeoutException {
      throw ApiException(statusCode: 408, path: path, message: 'Timeout (PUT)');
    }
    return _handle(res, path);
  }

  Future<dynamic> multipart(String path, Map<String,String> fields, Map<String,String> files, {String method = 'POST'}) async {
    final uri = _uri(path);
    final req = http.MultipartRequest(method, uri);
    req.headers.addAll(_headers());
    fields.forEach((k,v)=> req.fields[k]=v);
    for(final entry in files.entries){
      req.files.add(await http.MultipartFile.fromPath(entry.key, entry.value));
    }
    http.StreamedResponse streamed;
    try {
      streamed = await req.send().timeout(requestTimeout);
    } on TimeoutException {
      throw ApiException(statusCode: 408, path: path, message: 'Timeout (MULTIPART)');
    }
    final res = await http.Response.fromStream(streamed);
    return _handle(res, path);
  }

  /// Lightweight health probe. Returns true if /health responded (any 2xx), false otherwise.
  Future<bool> health({Duration timeout = const Duration(seconds: 3)}) async {
    try {
      final uri = _uri('/health');
  await http.get(uri, headers: _headers()).timeout(timeout);
      // Consider any HTTP response as reachability (even 4xx/5xx) so caller distinguishes network down vs server error.
      return true;
    } catch(_) { return false; }
  }

  dynamic _handle(http.Response r, String path){
    final status = r.statusCode;
    final body = r.body;
    if(status>=200 && status<300){
      if(body.isEmpty) return null; // 204 or empty success
      try {
        return jsonDecode(body);
      } catch(e){
        if(debug) print('[ApiClient] JSON decode failed on $path: $e, raw: ${body.substring(0, body.length>200?200:body.length)}');
        return body; // fallback raw text
      }
    }

    // Attempt to extract message from JSON error if present
    String message = 'HTTP $status';
    if(body.isNotEmpty){
      try {
        final parsed = jsonDecode(body);
        if(parsed is Map){
          message = parsed['message']?.toString() ?? message;
        }
      } catch(_) {
        // ignore parse error, keep default
      }
    } else {
      message = 'HTTP $status (empty response)';
    }
    if(debug) {
      print('[ApiClient] Error $status on $path bodyLength=${body.length}');
    }
    throw ApiException(statusCode: status, path: path, message: message, responseBody: body.isEmpty? null : body);
  }
}
