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
import 'category_card.dart';

class Sub4StreamWidget extends StatefulWidget {
  final Catalog catalog;
  final SubCatModel sub;
  final SubSubCatModel subsub;
  final Sub3CatModel sub3;
  final UserModel userModel;

  const Sub4StreamWidget(
      this.catalog,
      this.sub,
      this.subsub,
      this.sub3,
      this.userModel, {
        super.key,
      });

  @override
  State<Sub4StreamWidget> createState() => _Sub4StreamWidgetState();
}

class _Sub4StreamWidgetState extends State<Sub4StreamWidget> {
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
          .doc(widget.sub3.doc)
          .collection('sub4')
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
        final List<Sub4CatModel> sub4List = docs.reversed.map((doc) {
          return Sub4CatModel(
            doc: doc.id,
            name: doc.get('name'),
            pic: doc.get('pic'),
          );
        }).toList();

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          itemCount: sub4List.length,
          itemBuilder: (context, index) {
            final current = sub4List[index];

            return CategoryCard(
              title: current.name,
              imageUrl: current.pic,
              isAdmin: isAdmin,
              onTap: () {
              },
              onEdit: isAdmin
                  ? () {
                _showEditSub4NameDialog(
                  context,
                  widget.catalog,
                  widget.sub,
                  widget.subsub,
                  widget.sub3,
                  current,
                );
              }
                  : null,
              onDelete: isAdmin
                  ? () async {
                await DeleteSub4Catalog(
                  context,
                  widget.catalog,
                  widget.sub,
                  widget.subsub,
                  widget.sub3.doc,
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

void _showEditSub4NameDialog(
    BuildContext context,
    Catalog catalog,
    SubCatModel sub,
    SubSubCatModel subsub,
    Sub3CatModel sub3,
    Sub4CatModel sub4,
    ) {
}
