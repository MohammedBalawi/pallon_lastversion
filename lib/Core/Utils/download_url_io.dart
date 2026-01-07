import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

Future<bool> platformDownloadUrl(
  String url, {
  String? filename,
}) async {
  Directory? directory;
  if (defaultTargetPlatform == TargetPlatform.android) {
    directory = Directory('/storage/emulated/0/Download');
    if (!directory.existsSync()) {
      directory = await getExternalStorageDirectory();
    }
  } else if (defaultTargetPlatform == TargetPlatform.iOS) {
    directory = await getApplicationDocumentsDirectory();
  } else {
    directory = await getDownloadsDirectory();
  }

  if (directory == null) return false;

  final safeName = filename ??
      'file_${DateTime.now().millisecondsSinceEpoch.toString()}.bin';
  final savePath = '${directory.path}/$safeName';

  final dio = Dio();
  await dio.download(url, savePath);
  return true;
}
