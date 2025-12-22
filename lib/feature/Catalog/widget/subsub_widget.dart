import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:pallon_lastversion/feature/Catalog/widget/sub_sub_stream_data.dart';

import '../../../Core/Utils/manager_fonts.dart';
import '../../../models/catalog_model.dart';
import '../../../models/sub_cat_model.dart';
import '../../../models/user_model.dart';
import '../view/create_sub_sub_view.dart';
import 'add_new_item_widget.dart';
import 'item_strem_widget.dart';

class SubSubWidget extends StatefulWidget {
  final SubCatModel sub;
  final Catalog catalog;
  final UserModel userModel;

  const SubSubWidget(
      this.catalog,
      this.sub,
      this.userModel, {
        Key? key,
      }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SubSubWidgetState();
  }
}

class _SubSubWidgetState extends State<SubSubWidget> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth  = MediaQuery.of(context).size.width;

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
                            widget.sub.sub,
                            style: TextStyle(
                              fontFamily: ManagerFontFamily.fontFamily,

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

            SizedBox(
              height: screenHeight * 0.3,
              child: SubSubStreamData(
                context,
                widget.sub,
                widget.catalog,
                widget.userModel,
              ),
            ),

            SizedBox(
              height: screenHeight * 0.9,
              child: ItemStreamWidget(
                "/Catalog/${widget.catalog.doc}/sub/${widget.sub.doc}/item",
                widget.userModel,
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: widget.userModel.type == "Admin"
          ? FloatingActionButton(
        onPressed: () {
          _showActionDialog(
            context,
            "Please Choose Action".tr,
          );
        },
        backgroundColor: Colors.grey[100],
        child: const Icon(
          Icons.add,
          color: Colors.black,
        ),
      )
          : null,
    );
  }

  void _showActionDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
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
            message,
            style:  TextStyle(
                fontFamily: ManagerFontFamily.fontFamily,

                color: Colors.black87),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Add New Sub'.tr,
                style:  TextStyle(
                  fontFamily: ManagerFontFamily.fontFamily,

                  color: Color(0xFF07933E),
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Get.back();
                Get.bottomSheet(
                  CreateSubSubView(
                    widget.catalog,
                    widget.sub,
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
                    "/Catalog/${widget.catalog.doc}/sub/${widget.sub.doc}/item",
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
