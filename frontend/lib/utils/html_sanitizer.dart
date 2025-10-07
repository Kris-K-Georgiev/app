/// Simple client-side HTML sanitizer.
/// Strips disallowed tags and dangerous attributes. This is a fallback –
/// server-side sanitization is strongly recommended.
String sanitizeHtml(String input) {
  if (input.isEmpty) return input;
  // Remove script/style tags completely
  final removedScripts = input.replaceAll(RegExp(r'<\s*(script|style)[^>]*?>[\s\S]*?<\/\s*\1\s*>', caseSensitive: false), '');
  // Allowed tags whitelist
  const allowed = <String>{'p','br','strong','b','em','i','u','h1','h2','h3','ul','ol','li','img','a'};
  // Strip disallowed tags while keeping inner text
  final tagRegex = RegExp(r'<(/?)([a-zA-Z0-9]+)([^>]*)>', multiLine: true);
  final buffer = StringBuffer();
  int lastIndex = 0;
  for (final match in tagRegex.allMatches(removedScripts)) {
    buffer.write(removedScripts.substring(lastIndex, match.start));
    final closing = match.group(1) == '/';
    final tag = match.group(2)!.toLowerCase();
    var attrs = match.group(3) ?? '';
    if (allowed.contains(tag)) {
      if (!closing) {
        // Clean attributes: keep only href on <a> and src on <img>
        if (tag == 'a') {
          final hrefMatch = RegExp(r'href\s*=\s*(["\"][^"\"]*["\"])', caseSensitive: false).firstMatch(attrs);
          final href = hrefMatch!=null? ' href=${hrefMatch.group(1)}' : '';
          buffer.write('<a$href>');
        } else if (tag == 'img') {
          final srcMatch = RegExp(r'src\s*=\s*(["\"][^"\"]*["\"])', caseSensitive: false).firstMatch(attrs);
          final src = srcMatch!=null? ' src=${srcMatch.group(1)}' : '';
          buffer.write('<img$src />');
        } else {
          buffer.write('<$tag>');
        }
      } else {
        // Closing tag
        buffer.write('</$tag>');
      }
    } else {
      // Skip tag (strip); do not include
    }
    lastIndex = match.end;
  }
  buffer.write(removedScripts.substring(lastIndex));
  return buffer.toString();
}
