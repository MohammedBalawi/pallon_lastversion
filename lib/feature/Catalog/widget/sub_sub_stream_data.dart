import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/catalog_model.dart';
import '../../../models/sub_cat_model.dart';
import '../../../models/sub_sub_cat.dart';
import '../../../models/user_model.dart';
import '../../../Core/Widgets/image_view.dart';
import '../Funcation/catalog_function.dart';
import 'edit_subsub_widget.dart';
import 'sub3_widget.dart';
import 'category_card.dart';

Widget SubSubStreamData(
    BuildContext context,
    SubCatModel sub,
    Catalog catalog,
    UserModel user,
    ) {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final screenHeight = MediaQuery.of(context).size.height;
  final screenWidth  = MediaQuery.of(context).size.width;

  return StreamBuilder<QuerySnapshot>(
    stream: _firestore
        .collection("Catalog")
        .doc(catalog.doc)
        .collection('sub')
        .doc(sub.doc)
        .collection('subsub')
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(
          child: CircularProgressIndicator(
            backgroundColor: Color(0xFF07933E),
          ),
        );
      }
      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return Center(child: Text('No items found.'.tr));
      }

      List<SubSubCatModel> subsub = [];
      final messages = snapshot.data!.docs;
      for (var message in messages.reversed) {
        subsub.add(
          SubSubCatModel(
            doc: message.id,
            subsub: message.get('subsub'),
            pic: message.get('pic'),
          ),
        );
      }

      final bool isAdmin = user.type == "Admin";

      return ListView.builder(
        itemCount: subsub.length,
        itemBuilder: (context, index) {
          final current = subsub[index];

          return   SizedBox(
              // height: screenHeight * 0.28,
              child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                  ),
            child: CategoryCard(
              title: current.subsub,
              imageUrl: current.pic,
              isAdmin: isAdmin,
              onTap: () {
                Get.to(
                  Sub3Widget(
                    catalog,
                    sub,
                    current,
                    user,
                  ),
                  transition: Transition.fadeIn,
                  duration: const Duration(milliseconds: 500),
                );
              },
              onEdit: isAdmin
                  ? () {
                Get.bottomSheet(
                  EditSubSubWidget(
                    cat: catalog,
                    sub: sub,
                    subsub: current,
                  ),
                  clipBehavior: Clip.hardEdge,
                  enableDrag: true,
                  persistent: true,
                  ignoreSafeArea: true,
                );
              }
                  : null,
              onDelete: isAdmin
                  ? () {
                DeleteSubSub(context, catalog, sub, current);
              }
                  : null,
            ),
              ),
          );
        },
      );
    },
  );
}
