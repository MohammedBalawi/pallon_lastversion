import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/catalog_model.dart';
import '../../../models/sub_cat_model.dart';
import '../../../models/user_model.dart';
import '../Funcation/catalog_function.dart';
import '../view/subsub_view.dart';
import 'edit_sub_category_catalog_widget.dart';
import 'category_card.dart';

class SubCatalogStreamWidget extends StatefulWidget {
  final UserModel userModel;
  final Catalog catalog;

  const SubCatalogStreamWidget(
      this.catalog,
      this.userModel, {
        Key? key,
      }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SubCatalogStreamWidget();
  }
}

class _SubCatalogStreamWidget extends State<SubCatalogStreamWidget> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('Catalog')
          .doc(widget.catalog.doc)
          .collection('sub')
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

        final docs = snapshot.data!.docs;
        final List<SubCatModel> subcatalogs = docs.reversed.map((doc) {
          return SubCatModel(
            doc: doc.id,
            sub: doc.get('sub'),
            pic: doc.get('pic'),
          );
        }).toList();

        widget.catalog.sub = subcatalogs;

        final bool isAdmin = widget.userModel.type == "Admin";

        return ListView.builder(
          itemCount: subcatalogs.length,
          itemBuilder: (context, index) {
            final subCat = subcatalogs[index];

            return CategoryCard(
              title: subCat.sub,
              imageUrl: subCat.pic,
              isAdmin: isAdmin,
              onTap: () {
                Get.to(
                  SubSubView(
                    widget.catalog,
                    subCat,
                    widget.userModel,
                  ),
                  transition: Transition.fadeIn,
                  duration: const Duration(milliseconds: 500),
                );
              },
              onEdit: isAdmin
                  ? () {
                Get.bottomSheet(
                  EditSubCategoryCatalog(
                    widget.catalog,
                    subCat,
                  ),
                  clipBehavior: Clip.hardEdge,
                );
              }
                  : null,
              onDelete: isAdmin
                  ? () {
                DeleteSubCategory(
                  context,
                  widget.catalog,
                  subCat,
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
