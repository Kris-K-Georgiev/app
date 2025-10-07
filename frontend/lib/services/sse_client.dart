import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../core/config.dart';
import 'api_client.dart';

/// Simple SSE client with auto-reconnect + backoff.
class SseClient {
  final ApiClient api;
  final Duration minRetry;
  final Duration maxRetry;
  HttpClient? _http;
  StreamController<Map<String,dynamic>>? _controller;
  bool _stopped = false;
  Duration _currentDelay;

  SseClient(this.api,{this.minRetry=const Duration(seconds:2), this.maxRetry=const Duration(minutes:1)})
      : _currentDelay = minRetry;

  Stream<Map<String,dynamic>> get stream => (_controller ??= StreamController<Map<String,dynamic>>.broadcast(onListen: _open, onCancel: stop)).stream;

  Future<void> _open() async {
    _http ??= HttpClient();
    while(!_stopped){
      try {
        final uri = Uri.parse('${AppConfig.apiBaseUrl}/stream');
        final req = await _http!.getUrl(uri);
        final token = api.token;
        if(token!=null){ req.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token'); }
        req.headers.set(HttpHeaders.acceptHeader, 'text/event-stream');
        final res = await req.close();
        if(res.statusCode!=200){ throw HttpException('Bad status: ${res.statusCode}'); }
        _currentDelay = minRetry; // reset on successful connect
        final lines = utf8.decoder.bind(res).transform(const LineSplitter());
        String? event; String? dataBuf;
        await for(final line in lines){
          if(_stopped) break;
          if(line.isEmpty){
            if(event!=null && dataBuf!=null){
              try {
                final decoded = jsonDecode(dataBuf);
                _controller?.add({'event':event,'data':decoded});
              } catch(_) {/* ignore bad json */}
            }
            event=null; dataBuf=null; continue;
          }
          if(line.startsWith('event:')){ event = line.substring(6).trim(); }
          else if(line.startsWith('data:')){ dataBuf = (dataBuf==null? '' : '$dataBuf\n') + line.substring(5).trim(); }
        }
      } catch(_){
        if(_stopped) break;
        await Future.delayed(_currentDelay);
        // exponential backoff with cap
        _currentDelay = Duration(milliseconds: (_currentDelay.inMilliseconds * 2).clamp(minRetry.inMilliseconds, maxRetry.inMilliseconds));
      }
    }
  }

  Future<void> stop() async {
    _stopped = true;
    try {
      // HttpClient.close returns void, so don't await
      _http?.close(force: true);
    } catch (_) {}
    await _controller?.close();
  }
}
