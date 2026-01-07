import 'dart:html' as html;

Future<bool> platformDownloadUrl(
  String url, {
  String? filename,
}) async {
  final anchor = html.AnchorElement(href: url)
    ..download = filename ?? ''
    ..target = '_blank'
    ..style.display = 'none';
  html.document.body?.children.add(anchor);
  anchor.click();
  anchor.remove();
  return true;
}
