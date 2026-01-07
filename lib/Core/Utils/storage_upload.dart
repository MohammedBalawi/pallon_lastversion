import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import 'storage_upload_io.dart' if (dart.library.html) 'storage_upload_web.dart';

Future<UploadTask> uploadXFile(
  Reference ref,
  XFile file, {
  SettableMetadata? metadata,
}) {
  return platformUploadXFile(ref, file, metadata: metadata);
}
