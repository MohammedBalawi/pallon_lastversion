import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> ensureCameraPermission(BuildContext context) async {
  final status = await Permission.camera.request();
  if (status.isGranted) return true;
  await _showPermissionDialog(
    context,
    message: "permission_camera_body".tr,
    openSettings: status.isPermanentlyDenied,
  );
  return false;
}

Future<bool> ensureGalleryPermission(BuildContext context) async {
  if (!Platform.isAndroid) {
    final status = await Permission.photos.request();
    if (status.isGranted) return true;
    await _showPermissionDialog(
      context,
      message: "permission_gallery_body".tr,
      openSettings: status.isPermanentlyDenied,
    );
    return false;
  }

  final photosStatus = await Permission.photos.request();
  if (photosStatus.isGranted) return true;

  final storageStatus = await Permission.storage.request();
  if (storageStatus.isGranted) return true;

  await _showPermissionDialog(
    context,
    message: "permission_gallery_body".tr,
    openSettings: photosStatus.isPermanentlyDenied || storageStatus.isPermanentlyDenied,
  );
  return false;
}

Future<void> _showPermissionDialog(
  BuildContext context, {
  required String message,
  required bool openSettings,
}) async {
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: Text("permission_required_title".tr),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text("permission_cancel".tr),
          ),
          if (openSettings)
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                openAppSettings();
              },
              child: Text("permission_open_settings".tr),
            ),
        ],
      );
    },
  );
}
