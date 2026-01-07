import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

ImageProvider platformImageProviderForXFile(XFile file) {
  return FileImage(File(file.path));
}
