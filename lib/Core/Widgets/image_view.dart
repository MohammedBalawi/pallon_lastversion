import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pallon_lastversion/Core/Utils/app.images.dart';
import 'package:path_provider/path_provider.dart';
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

      final status = await Permission.storage.request();
      if (!status.isGranted) {
        Get.snackbar("حذير".tr, "يرجى السماح بالوصول للتخزين".tr);


        return;
      }

      Directory? directory;

      if (Platform.isAndroid) {
        directory = Directory("/storage/emulated/0/Download");
        if (!directory.existsSync()) {
          directory = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getDownloadsDirectory();
      }

      if (directory == null) {
        Get.snackbar("Error".tr, "تعذر الوصول لمجلد التنزيلات".tr);

        return;
      }

      final dio = Dio();

      String fileName =
          "image_${DateTime.now().millisecondsSinceEpoch}.jpg";
      String savePath = "${directory.path}/$fileName";

      await dio.download(
        path,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            // double progress = received / total;
          }
        },
      );
      Get.snackbar("Error".tr,   Platform.isAndroid
          ? "تم حفظ الصورة في مجلد التنزيلات".tr
          : "تم حفظ الصورة في مجلد المستندات".tr,);
      

      // Navigator.pop(context);

    } catch (e) {
      Get.snackbar("Error".tr, "فشل تنزيل الصورة".tr);

    }
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = _isNetwork
        ? CachedNetworkImageProvider(path)
        : FileImage(File(path)) as ImageProvider;

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
