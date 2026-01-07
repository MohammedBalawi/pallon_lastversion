import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

ImageProvider platformImageProviderForXFile(XFile file) {
  return NetworkImage(file.path);
}
