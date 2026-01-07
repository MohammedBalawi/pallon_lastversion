import 'dart:typed_data';

import 'share_download_io.dart'
    if (dart.library.html) 'share_download_web.dart';

Future<void> shareOrDownloadBytes({
  required Uint8List bytes,
  required String filename,
  String? mimeType,
  String? text,
}) {
  return platformShareOrDownloadBytes(
    bytes: bytes,
    filename: filename,
    mimeType: mimeType,
    text: text,
  );
}
