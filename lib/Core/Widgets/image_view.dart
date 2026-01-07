import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pallon_lastversion/Core/Utils/app.images.dart';
import 'package:pallon_lastversion/Core/Utils/download_url.dart';
import 'package:pallon_lastversion/Core/Utils/local_image_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';

class ViewImage extends StatelessWidget {
  final String path;

  ViewImage(this.path);

  bool get _isNetwork => path.startsWith("http");

  Future<void> _download(BuildContext context) async {
    try {
      if (!_isNetwork) {
        Get.snackbar("تحذير".tr, "هذه الصورة ليست من الإنترنت".tr);

        return;
      }

      if (!kIsWeb) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          Get.snackbar("حذير".tr, "يرجى السماح بالوصول للتخزين".tr);
          return;
        }
      }

      final fileName = "image_${DateTime.now().millisecondsSinceEpoch}.jpg";
      final ok = await downloadUrl(path, filename: fileName);
      if (!ok) {
        Get.snackbar("Error".tr, "تعذر الوصول لمجلد التنزيلات".tr);
        return;
      }

      Get.snackbar(
        "Error".tr,
        kIsWeb
            ? "تم بدء تنزيل الصورة".tr
            : "تم حفظ الصورة في مجلد التنزيلات".tr,
      );
      

      // Navigator.pop(context);

    } catch (e) {
      Get.snackbar("Error".tr, "فشل تنزيل الصورة".tr);

    }
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = _isNetwork
        ? CachedNetworkImageProvider(path)
        : localImageProvider(path);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "View Image".tr,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          PhotoView(
            imageProvider: imageProvider,
            minScale: PhotoViewComputedScale.contained * 0.9,
            maxScale: PhotoViewComputedScale.covered * 3,
            enableRotation: true,
          ),

          Positioned(
            bottom: 30,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: () => _download(context),
              child: SvgPicture.asset(AppImages.solarDownload),
            ),
          ),
        ],
      ),
    );
  }
}
