import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/banner_model.dart';
import '../view/edit_banner_view.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

Widget GradViewBanners(BuildContext context) {
  final screenHeight = MediaQuery.of(context).size.height;
  final screenWidth = MediaQuery.of(context).size.width;

  return StreamBuilder<QuerySnapshot>(
    stream: _firestore.collection('banner').snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(
          child: CircularProgressIndicator(
            backgroundColor: Color(0xFF07933E),
          ),
        );
      }

      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_outlined,
                size: screenWidth * 0.18,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 12),
              Text(
                'No items found.'.tr,
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Add a new banner to see it here.'.tr,
                style: TextStyle(
                  fontSize: screenWidth * 0.038,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      List<BannerModel> banners = [];
      final messages = snapshot.data!.docs;
      for (var message in messages.reversed) {
        banners.add(
          BannerModel(
            doc: message.id,
            path: message.get('path'),
            action: message.get('action'),
            typeaction: message.get('typeaction'),
          ),
        );
      }

      return GridView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenHeight * 0.015,
        ),
        itemCount: banners.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: screenWidth * 0.05,
          crossAxisSpacing: screenWidth * 0.05,
          childAspectRatio: 0.9,
        ),
        itemBuilder: (context, index) {
          final banner = banners[index];

          String actionLabel;
          if (banner.typeaction == "same") {
            actionLabel = 'Open image only'.tr;
          } else if (banner.typeaction == "image") {
            actionLabel = 'Open another image'.tr;
          } else {
            actionLabel = 'Open link'.tr;
          }

          String chipText = banner.typeaction.tr;

          return InkWell(
            onTap: () {
              Get.to(
                EditBannerView(banner),
                transition: Transition.fadeIn,
                duration: const Duration(milliseconds: 350),
              );
            },
            borderRadius: BorderRadius.circular(18),
            child: Card(
              elevation: 3,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(banner.path),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 14,
                          right: 14,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.touch_app,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  chipText,
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.032,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Banner'.tr,
                          style: TextStyle(
                            fontSize: screenWidth * 0.038,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF222222),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          actionLabel,
                          style: TextStyle(
                            fontSize: screenWidth * 0.033,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Icon(
                            Icons.edit_outlined,
                            size: screenWidth * 0.045,
                            color: const Color(0xFF07933E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
