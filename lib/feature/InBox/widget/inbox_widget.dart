import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pallon_lastversion/feature/InBox/widget/stream_inbox_list.dart';

import '../../../Core/Utils/manager_fonts.dart';
import '../../../models/user_model.dart';
import '../view/create_inbox_view.dart';

class InBoxWidget extends StatefulWidget {
  final UserModel userModel;
  InBoxWidget(this.userModel);

  @override
  State<StatefulWidget> createState() {
    return _InBoxWidget();
  }
}

class _InBoxWidget extends State<InBoxWidget> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth  = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      floatingActionButton: widget.userModel.type == "Admin"
          ? FloatingActionButton(
        onPressed: () {
          Get.bottomSheet(
            CreateInBoxView(),
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            ),
          );
        },
        backgroundColor: Colors.white,
        elevation: 4,
        child: const Icon(
          Icons.add,
          color: Color(0xFF07933E),
        ),
      )
          : null,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Container(
              height: screenHeight * 0.22,
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
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.06,
                vertical: screenHeight * 0.025,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  SizedBox(height: screenHeight * 0.06),
                  Text(
                    'InBox'.tr,
                    style: TextStyle(
                      fontFamily: ManagerFontFamily.fontFamily,

                      fontSize: screenWidth * 0.075,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.004),
                  Text(
                    widget.userModel.type == "Admin"
                        ? 'Manage notifications and messages'.tr
                        : 'View latest messages and updates'.tr,
                    style: TextStyle(
                      fontFamily: ManagerFontFamily.fontFamily,

                      fontSize: screenWidth * 0.038,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.015),

            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0.005,
                ),
                child: Card(
                  color: Colors.white,
                  elevation: 3,
                  shadowColor: Colors.black.withOpacity(0.08),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: StreamInBoxList(context, widget.userModel),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
