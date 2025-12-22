import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Core/Utils/manager_fonts.dart';
import '../../../models/catalog_model.dart';
import '../../../models/sub_cat_model.dart';
import '../../../models/sub_sub_cat.dart';
import '../../../models/user_model.dart';
import '../Funcation/catalog_function.dart';
import '../models/sub3_cat_model.dart';
import 'sub4_widget.dart';
import 'category_card.dart';

class Sub3StreamWidget extends StatefulWidget {
  final Catalog catalog;
  final SubCatModel sub;
  final SubSubCatModel subsub;
  final UserModel userModel;

  const Sub3StreamWidget(
      this.catalog,
      this.sub,
      this.subsub,
      this.userModel, {
        super.key,
      });

  @override
  State<Sub3StreamWidget> createState() => _Sub3StreamWidgetState();
}

class _Sub3StreamWidgetState extends State<Sub3StreamWidget> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = widget.userModel.type == "Admin";

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection("Catalog")
          .doc(widget.catalog.doc)
          .collection('sub')
          .doc(widget.sub.doc)
          .collection('subsub')
          .doc(widget.subsub.doc)
          .collection('sub3')
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
          return Center(
            child: Text(
              'No items found.'.tr,
              style: TextStyle(
                fontFamily: ManagerFontFamily.fontFamily,
              ),
            ),
          );
        }

        final docs = snapshot.data!.docs;
        final List<Sub3CatModel> sub3List = docs.reversed.map((doc) {
          return Sub3CatModel(
            doc: doc.id,
            name: doc.get('name'),
            pic: doc.get('pic'),
          );
        }).toList();

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          itemCount: sub3List.length,
          itemBuilder: (context, index) {
            final current = sub3List[index];

            return CategoryCard(
              title: current.name,
              imageUrl: current.pic,
              isAdmin: isAdmin,
              onTap: () {
                Get.to(
                  Sub4Widget(
                    widget.catalog,
                    widget.sub,
                    widget.subsub,
                    current,
                    widget.userModel,
                  ),
                  transition: Transition.fadeIn,
                  duration: const Duration(milliseconds: 500),
                );
              },
              onEdit: isAdmin
                  ? () {
              }
                  : null,
              onDelete: isAdmin
                  ? () async {
                await DeleteSub3Catalog(
                  context,
                  widget.catalog,
                  widget.sub,
                  widget.subsub,
                  current.doc,
                );
              }
                  : null,
            );
          },
        );
      },
    );
  }
}
