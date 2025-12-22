import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pallon_lastversion/models/image_model.dart';
import 'package:pallon_lastversion/models/order_model.dart';
import 'package:pallon_lastversion/models/user_model.dart';

import '../../../Core/Widgets/image_view.dart';
import '../funcation/task_function.dart';

final FirebaseFirestore _firestore=FirebaseFirestore.instance;
final ImagePicker _picker = ImagePicker();
Widget DesginImageStream(BuildContext context,OrderModel order,UserModel user){
  Future<void> _pickImage() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    List<File> _images=[];
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      _images.addAll(pickedFiles.map((xFile) => File(xFile.path)));
      UploadDesgin(_images,context,order);
    }
  }
  final screenHeight = MediaQuery.of(context).size.height;
  final screenWidth = MediaQuery.of(context).size.width;
  return StreamBuilder<QuerySnapshot>(
    stream: _firestore.collection('req').doc(order.req!.doc).collection('designer').snapshots(),
    builder: (context,snapshot){
      double uploadTextSpacing = screenHeight * 0.01;
      double uploadTextFontSize = screenWidth * 0.04;
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(
          child: CircularProgressIndicator(
            backgroundColor: Color(0xFF07933E),
          ),
        );
      }
      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return Card(
          color: Colors.white,
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "Special Design Status".tr,
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFCE232B),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20, thickness: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Status:".tr,
                        style: TextStyle(
                          fontSize: screenWidth * 0.038,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(
                            8,
                          ),
                        ),
                        child: Text(
                          "No Design Provided".tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                order.Designer!.doc==user.doc?GestureDetector(
                  onTap: _pickImage,
                  child:Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.upload),
                        SizedBox(height: uploadTextSpacing),
                        Text(
                          "Upload Images".tr,
                          style: TextStyle(
                            fontSize: uploadTextFontSize,
                            color: Colors.grey.shade600,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ],
                    ),
                  ),
                ):Text(""),
              ],
            ),
          ),
        );
      }
      List<ImageModel> images=[];
      final messages = snapshot.data!.docs;
      for (var message in messages.reversed){
        images.add(
            ImageModel(doc: message.id, path: message.get('path'))
        );
      }
      bool hasDesign = images.isNotEmpty;
      double removeImageButtonPadding = screenWidth * 0.01;
      double removeImageButtonIconSize = screenWidth * 0.04;
      final imagePreviewWidth = screenWidth * 0.28;
      const imagePreviewMargin = 6.0;
      const imagePreviewBorderRadius = 12.0;
      final statusText = hasDesign ? "Design Attached".tr : "No Design Provided".tr;
      final statusColor = hasDesign
          ? const Color(0xFF07933E)
          : Colors.red.shade400;
      return  Card(
        color: Colors.white,
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Special Design Status".tr,
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFCE232B),
                    ),
                  ),
                ],
              ),
              const Divider(height: 20, thickness: 1),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Status:".tr,
                      style: TextStyle(
                        fontSize: screenWidth * 0.038,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(
                          8,
                        ),
                      ),
                      child: Text(
                        statusText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (hasDesign) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Design Images (${images.length}):",
                      style: TextStyle(
                        fontSize: screenWidth * 0.042,
                        fontWeight: FontWeight.w700,
                        color: Colors.black54,
                      ),
                    ),
                    order.Designer!.doc==user.doc?Card(
                      color: Colors.green,
                      child: IconButton(onPressed: (){
                        _pickImage();
                      },
                          icon: Icon(Icons.add,color: Colors.white,)),
                    ):Text("")
                  ],
                ),
                const SizedBox(height: 12),

                SizedBox(
                  height:
                  screenWidth *
                      0.35,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          Get.to(
                                () => ViewImage(images[index].path),
                            duration: const Duration(milliseconds: 500),
                            transition: Transition.fadeIn,
                          );
                        },
                        child: Stack(
                          children: [
                            Container(
                              width: imagePreviewWidth,
                              margin: const EdgeInsets.only(
                                right: imagePreviewMargin,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  imagePreviewBorderRadius,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    offset: const Offset(0, 3),
                                    blurRadius: 6,
                                  ),
                                ],
                                image: DecorationImage(
                                  image: NetworkImage(images[index].path),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                           order.Designer!.doc==user.doc? Positioned(
                              top: screenWidth * 0.01,
                              right: screenWidth * 0.01,
                              child: InkWell(
                                onTap: (){
                                  RemoveDesign(context, images[index], order);
                                },
                                child: Container(
                                  padding: EdgeInsets.all(removeImageButtonPadding),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.close,
                                      size: removeImageButtonIconSize,
                                      color: Colors.white),
                                ),
                              ),
                            ):Text(""),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
              if (!hasDesign) ...[
                GestureDetector(
                  onTap: _pickImage,
                  child: images.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.upload),
                        SizedBox(height: uploadTextSpacing),
                        Text(
                          "Upload Images".tr,
                          style: TextStyle(
                            fontSize: uploadTextFontSize,
                            color: Colors.grey.shade600,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ],
                    ),
                  )
                      : Text(""),
                ),
              ],
            ],
          ),
        ),
      );
    },
  );

}
