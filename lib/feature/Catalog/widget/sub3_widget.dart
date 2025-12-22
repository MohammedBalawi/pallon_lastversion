import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Core/Utils/manager_fonts.dart';
import '../../../models/catalog_model.dart';
import '../../../models/sub_cat_model.dart';
import '../../../models/sub_sub_cat.dart';
import '../../../models/user_model.dart';
import 'add_new_item_widget.dart';
import 'create_sub3_view.dart';
import 'item_strem_widget.dart';
import 'sub3_stream_widget.dart';

class Sub3Widget extends StatefulWidget {
  final Catalog catalog;
  final SubCatModel sub;
  final SubSubCatModel subsub;
  final UserModel userModel;

  const Sub3Widget(
      this.catalog,
      this.sub,
      this.subsub,
      this.userModel, {
        super.key,
      });

  @override
  State<Sub3Widget> createState() => _Sub3WidgetState();
}

class _Sub3WidgetState extends State<Sub3Widget> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth  = MediaQuery.of(context).size.width;
    final bool isAdmin = widget.userModel.type == "Admin";

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: screenHeight * 0.25,
              width: double.infinity,
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
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.08,
                vertical: screenHeight * 0.05,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenHeight * 0.04),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.subsub.subsub,
                            style: TextStyle(
                              fontSize: screenWidth * 0.085,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),

                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              height: screenHeight * 0.28,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Sub3StreamWidget(
                    widget.catalog,
                    widget.sub,
                    widget.subsub,
                    widget.userModel,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              height: screenHeight * 0.9,
              child: ItemStreamWidget(
                "/Catalog/${widget.catalog.doc}/sub/${widget.sub.doc}/subsub/${widget.subsub.doc}/item",
                widget.userModel,
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),

      floatingActionButton: isAdmin
          ? FloatingActionButton(
        backgroundColor: Colors.grey[100],
        onPressed: _showChooseActionDialog,
        child: const Icon(Icons.add, color: Colors.black),
      )
          : null,
    );
  }

  void _showChooseActionDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        final screenWidth  = MediaQuery.of(ctx).size.width;
        final screenHeight = MediaQuery.of(ctx).size.height;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Colors.white,
          titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          title: Row(
            children: [
              const Icon(
                Icons.playlist_add,
                color: Color(0xFFCE232B),
              ),
              const SizedBox(width: 8),
              Text(
                'Choose Action'.tr,
                style:  TextStyle(
                  fontFamily: ManagerFontFamily.fontFamily,

                  color: Color(0xFFCE232B),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'Please Choose Action'.tr,
            style:  TextStyle(
                fontFamily: ManagerFontFamily.fontFamily,

                color: Colors.black87),
          ),
          actions: <Widget>[
            SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: screenHeight * 0.06,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.back();
                        Get.bottomSheet(
                          CreateSub3View(
                            widget.catalog,
                            widget.sub,
                            widget.subsub,
                          ),
                          isScrollControlled: true,
                          backgroundColor: Colors.white,
                        );
                      },
                      icon: const Icon(Icons.category_outlined),
                      label: Text(
                        'Add New Sub3'.tr,
                        style: TextStyle(
                          fontFamily: ManagerFontFamily.fontFamily,

                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF07933E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    height: screenHeight * 0.06,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.back();
                        Get.bottomSheet(
                          AddNewItemWidget(
                            "/Catalog/${widget.catalog.doc}/sub/${widget.sub.doc}/subsub/${widget.subsub.doc}/item",
                            "",
                          ),
                          isScrollControlled: true,
                          backgroundColor: Colors.white,
                        );
                      },
                      icon: const Icon(Icons.add_shopping_cart_outlined),
                      label: Text(
                        'Add New Item'.tr,
                        style: TextStyle(
                          fontFamily: ManagerFontFamily.fontFamily,

                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCE232B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
