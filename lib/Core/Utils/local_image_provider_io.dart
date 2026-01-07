import 'dart:io';

import 'package:flutter/widgets.dart';

ImageProvider platformLocalImageProvider(String path) {
  return FileImage(File(path));
}
