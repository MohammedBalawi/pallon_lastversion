import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Core/Utils/manager_fonts.dart';
import '../../../models/catalog_model.dart';
import '../../../models/sub_cat_model.dart';
import '../../../models/sub_sub_cat.dart';
import '../../../models/user_model.dart';
import '../view/create_catalog_item_view.dart';
import 'gradview_item_catalog.dart';

class CatalogItemWidget extends StatefulWidget {
  final Catalog cat;
  final SubCatModel sub;
  final SubSubCatModel subsub;
  final UserModel userModel;

  CatalogItemWidget(
      this.cat,
      this.sub,
      this.subsub,
      this.userModel, {
        Key? key,
      }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CatalogItemWidget();
  }
}

class _CatalogItemWidget extends State<CatalogItemWidget> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth  = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                left: screenWidth * 0.06,
                right: screenWidth * 0.06,
                top: screenHeight * 0.02,
                bottom: screenHeight * 0.03,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF07933E),
                    Color(0xFF007530),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          widget.subsub.subsub,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: ManagerFontFamily.fontFamily,

                            fontSize: screenWidth * 0.055,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.cat.cat}  •  ${widget.sub.sub}',
                    style: TextStyle(
                      fontFamily: ManagerFontFamily.fontFamily,

                      color: Colors.white.withOpacity(0.9),
                      fontSize: screenWidth * 0.034,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Items in this category'.tr,
                    style: TextStyle(
                      fontFamily: ManagerFontFamily.fontFamily,

                      color: Colors.white.withOpacity(0.8),
                      fontSize: screenWidth * 0.032,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: GradviewItemCatalog(
                  widget.cat,
                  widget.sub,
                  widget.subsub,
                  widget.userModel,
                ),
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: widget.userModel.type == "Admin"
          ? FloatingActionButton.extended(
        onPressed: () {
          Get.bottomSheet(
            CreateCatalogItemView(
              widget.cat,
              widget.sub,
              widget.subsub,
            ),
          );
        },
        backgroundColor: Colors.white,
        icon: const Icon(
          Icons.add_rounded,
          color: Colors.black,
        ),
        label: Text(
          'Add Item'.tr,
          style:  TextStyle(
            fontFamily: ManagerFontFamily.fontFamily,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      )
          : null,
    );
  }
}
