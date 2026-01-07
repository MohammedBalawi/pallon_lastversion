import 'dart:io';
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> platformShareOrDownloadBytes({
  required Uint8List bytes,
  required String filename,
  String? mimeType,
  String? text,
}) async {
  final directory = await getTemporaryDirectory();
  final path = '${directory.path}/$filename';
  final file = File(path)..createSync(recursive: true);
  await file.writeAsBytes(bytes);
  await Share.shareXFiles([XFile(path, mimeType: mimeType)], text: text);
}
