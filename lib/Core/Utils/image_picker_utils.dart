import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'permission_utils.dart';

final ImagePicker _picker = ImagePicker();

Future<XFile?> pickImageWithPermission(
  BuildContext context, {
  required ImageSource source,
  int? imageQuality,
}) async {
  final ok = source == ImageSource.camera
      ? await ensureCameraPermission(context)
      : await ensureGalleryPermission(context);
  if (!ok) return null;
  return _picker.pickImage(source: source, imageQuality: imageQuality);
}

Future<List<XFile>> pickMultiImageWithPermission(
  BuildContext context, {
  int? imageQuality,
}) async {
  final ok = await ensureGalleryPermission(context);
  if (!ok) return <XFile>[];
  final picked = await _picker.pickMultiImage(imageQuality: imageQuality);
  return picked ?? <XFile>[];
}
