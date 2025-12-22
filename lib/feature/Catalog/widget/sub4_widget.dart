import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Core/Utils/manager_fonts.dart';
import '../../../models/catalog_model.dart';
import '../../../models/sub_cat_model.dart';
import '../../../models/sub_sub_cat.dart';
import '../../../models/user_model.dart';
import '../models/sub3_cat_model.dart';
import 'create_sub4_view.dart';
import 'sub4_stream_widget.dart';
import 'item_strem_widget.dart';
import 'add_new_item_widget.dart';

class Sub4Widget extends StatefulWidget {
  final Catalog catalog;
  final SubCatModel sub;
  final SubSubCatModel subsub;
  final Sub3CatModel sub3;
  final UserModel userModel;

  const Sub4Widget(
      this.catalog,
      this.sub,
      this.subsub,
      this.sub3,
      this.userModel, {
        super.key,
      });

  @override
  State<Sub4Widget> createState() => _Sub4WidgetState();
}

class _Sub4WidgetState extends State<Sub4Widget> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth  = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
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
                            widget.sub3.name,
                            style: TextStyle(
                              fontFamily: ManagerFontFamily.fontFamily,

                              fontSize: screenWidth * 0.085,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
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
              height: screenHeight * 0.3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Sub4StreamWidget(
                  widget.catalog,
                  widget.sub,
                  widget.subsub,
                  widget.sub3,
                  widget.userModel,
                ),
              ),
            ),

            const SizedBox(height: 8),

            SizedBox(
              height: screenHeight * 0.9,
              child: ItemStreamWidget(
                "/Catalog/${widget.catalog.doc}"
                    "/sub/${widget.sub.doc}"
                    "/subsub/${widget.subsub.doc}"
                    "/sub3/${widget.sub3.doc}/item",
                widget.userModel,
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: widget.userModel.type == "Admin"
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
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          title: Text(
            'Choose Action'.tr,
            style:  TextStyle(
              fontFamily: ManagerFontFamily.fontFamily,

              color: Color(0xFFCE232B),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Please Choose Action'.tr,
            style:  TextStyle(
                fontFamily: ManagerFontFamily.fontFamily,

                color: Colors.black87),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Add New Sub4'.tr,
                style:  TextStyle(
                  fontFamily: ManagerFontFamily.fontFamily,

                  color: Color(0xFF07933E),
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Get.back();
                Get.bottomSheet(
                  CreateSub4View(
                    widget.catalog,
                    widget.sub,
                    widget.subsub,
                    widget.sub3,
                  ),
                  isScrollControlled: true,
                  backgroundColor: Colors.white,
                );
              },
            ),
            TextButton(
              child: Text(
                'Add New Item'.tr,
                style:  TextStyle(
                  fontFamily: ManagerFontFamily.fontFamily,

                  color: Color(0xFF07933E),
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Get.back();
                Get.bottomSheet(
                  AddNewItemWidget(
                    "/Catalog/${widget.catalog.doc}"
                        "/sub/${widget.sub.doc}"
                        "/subsub/${widget.subsub.doc}"
                        "/sub3/${widget.sub3.doc}/item",
                    "",
                  ),
                  isScrollControlled: true,
                  backgroundColor: Colors.white,
                );
              },
            ),
          ],
        );
      },
    );
  }
}
