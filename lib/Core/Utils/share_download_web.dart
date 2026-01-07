import 'dart:html' as html;
import 'dart:typed_data';

Future<void> platformShareOrDownloadBytes({
  required Uint8List bytes,
  required String filename,
  String? mimeType,
  String? text,
}) async {
  final blob = html.Blob([bytes], mimeType ?? 'application/octet-stream');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..download = filename
    ..style.display = 'none';
  html.document.body?.children.add(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(url);
}
