import 'package:flutter/widgets.dart';

import 'local_image_provider_io.dart'
    if (dart.library.html) 'local_image_provider_web.dart';

ImageProvider localImageProvider(String path) {
  return platformLocalImageProvider(path);
}
