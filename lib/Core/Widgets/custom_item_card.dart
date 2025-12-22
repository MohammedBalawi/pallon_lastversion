import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pallon_lastversion/Core/Utils/manager_fonts.dart';
import 'package:pallon_lastversion/Core/Widgets/image_view.dart';

import '../../feature/Catalog/widget/item_details_view.dart';
import '../../models/catalog_item_model.dart';

// class CustomItemCard extends StatelessWidget {
//   final CatalogItemModel _itemModel;
//
//   CustomItemCard(this._itemModel, {Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     final screenWidth  = MediaQuery.of(context).size.width;
//
//     final double cardWidth           = screenWidth * 0.45;
//     final double cardBorderRadius    = screenWidth * 0.09;
//     final double shadowSpreadRadius  = screenWidth * 0.005;
//     final double shadowBlurRadius    = screenWidth * 0.02;
//     final double shadowOffsetDy      = screenWidth * 0.01;
//     final double placeholderStrokeWidth = 2.0;
//     final double errorIconSize       = screenWidth * 0.1;
//     final double imageAspectRatio    = 16 / 9;
//     final double imageHeight         = cardWidth / imageAspectRatio;
//     final double contentPadding      = screenWidth * 0.025;
//     final double verticalSpacing     = screenWidth * 0.008;
//     final double titleFontSize       = screenWidth * 0.038;
//
//     return Container(
//       width: cardWidth,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(cardBorderRadius),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.2),
//             spreadRadius: shadowSpreadRadius,
//             blurRadius: shadowBlurRadius,
//             offset: Offset(0, shadowOffsetDy),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // الصورة
//           InkWell(
//             onTap: () {
//               Get.to(ViewImage(_itemModel.path));
//             },
//             child: ClipRRect(
//               borderRadius: BorderRadius.vertical(
//                 top: Radius.circular(cardBorderRadius),
//               ),
//               child: SizedBox(
//                 height: 200,
//                 width: double.infinity,
//                 child: CachedNetworkImage(
//                   imageUrl: _itemModel.path.isNotEmpty
//                       ? _itemModel.path
//                       : 'https://placehold.co/600x400/cccccc/000000?text=No+Image',
//                   fit: BoxFit.cover,
//                   placeholder: (context, url) => Container(
//                     color: Colors.grey[200],
//                     child: Center(
//                       child: CircularProgressIndicator(
//                         strokeWidth: placeholderStrokeWidth,
//                         color: Colors.grey,
//                       ),
//                     ),
//                   ),
//                   errorWidget: (context, url, error) => Center(
//                     child: Icon(
//                       Icons.broken_image,
//                       size: errorIconSize,
//                       color: Colors.grey,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//
//           Padding(
//             padding: EdgeInsets.all(contentPadding),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(height: verticalSpacing),
//                 Text(
//                   _itemModel.name,
//                   style: TextStyle(
//                     fontSize: titleFontSize,
//                     fontWeight: FontWeight.w600,
//                     fontFamily: 'NotoKufiArabic',
//                     color: Colors.black87,
//                   ),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 SizedBox(height: verticalSpacing),
//                 Text(
//                   _itemModel.des,
//                   style: TextStyle(
//                     fontSize: titleFontSize,
//                     fontWeight: FontWeight.w600,
//                     fontFamily: 'NotoKufiArabic',
//                     color: Colors.grey,
//                   ),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 SizedBox(height: verticalSpacing * 2),
//
//                 Align(
//                   alignment: Alignment.center,
//                   child: SizedBox(
//                     width: cardWidth * 0.8,
//                     child: ElevatedButton(
//                       onPressed: () {},
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFFCE232B),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(
//                             screenWidth * 0.05,
//                           ),
//                         ),
//                         elevation: 5,
//                       ),
//                       child: Text(
//                         "${_itemModel.price}",
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontFamily: 'NotoKufiArabic',
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class CustomItemCard extends StatelessWidget {
  final CatalogItemModel item;

  const CustomItemCard(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return  InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Get.to(() => ItemDetailsView(item: item));
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: CachedNetworkImage(
                    imageUrl: item.path,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: Colors.grey.shade200,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (_, __, ___) =>
                    const Icon(Icons.broken_image, size: 40),
                  ),
                ),
              ),
            ),
      
            const SizedBox(height: 8),
      
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: ManagerFontFamily.fontFamily,
                        fontSize: w * 0.04,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
      
                    Text(
                      item.des,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: ManagerFontFamily.fontFamily,
                        fontSize: w * 0.035,
                        color: Colors.black54,
                      ),
                    ),
      
                    const Spacer(),
      
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCE232B),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "${item.price} SAR",
                        style: TextStyle(
                          fontFamily: ManagerFontFamily.fontFamily,
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
      
                    const SizedBox(height: 6),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

  }
}
