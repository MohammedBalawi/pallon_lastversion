import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

import 'xfile_image_provider_io.dart'
    if (dart.library.html) 'xfile_image_provider_web.dart';

ImageProvider imageProviderForXFile(XFile file) {
  return platformImageProviderForXFile(file);
}
