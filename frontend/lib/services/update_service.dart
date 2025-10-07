import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class UpdateService {
  Future<DownloadResult> download(String url, {Function(double progress)? onProgress}) async {
    final req = http.Request('GET', Uri.parse(url));
    final streamed = await req.send();
    if(streamed.statusCode!=200){
      return DownloadResult(null, 'HTTP ${streamed.statusCode}');
    }
    final total = streamed.contentLength ?? 0;
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/update_${DateTime.now().millisecondsSinceEpoch}.apk');
    final sink = file.openWrite();
    int received = 0;
    await for(final chunk in streamed.stream){
      received += chunk.length;
      sink.add(chunk);
      if(total>0 && onProgress!=null){ onProgress(received/total); }
    }
    await sink.flush(); await sink.close();
    return DownloadResult(file, null);
  }
}

class DownloadResult {
  final File? file; final String? error;
  DownloadResult(this.file, this.error);
  bool get ok => file!=null && error==null;
}