import 'package:flutter/widgets.dart';

ImageProvider platformLocalImageProvider(String path) {
  return NetworkImage(path);
}
