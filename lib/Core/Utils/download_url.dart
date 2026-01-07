import 'download_url_io.dart' if (dart.library.html) 'download_url_web.dart';

Future<bool> downloadUrl(
  String url, {
  String? filename,
}) {
  return platformDownloadUrl(url, filename: filename);
}
