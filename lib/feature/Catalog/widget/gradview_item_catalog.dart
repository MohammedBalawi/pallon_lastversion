import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Core/Utils/manager_fonts.dart';
import '../../../Core/Widgets/custom_item_card.dart';
import '../../../models/catalog_item_model.dart';
import '../../../models/catalog_model.dart';
import '../../../models/sub_cat_model.dart';
import '../../../models/sub_sub_cat.dart';
import '../../../models/user_model.dart';
import '../view/item_details_catalog_view.dart';

class GradviewItemCatalog extends StatefulWidget {
  final Catalog cat;
  final SubCatModel sub;
  final SubSubCatModel subsub;
  final UserModel userModel;

  const GradviewItemCatalog(
      this.cat,
      this.sub,
      this.subsub,
      this.userModel, {
        Key? key,
      }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _GradviewItemCatalogState();
  }
}

class _GradviewItemCatalogState extends State<GradviewItemCatalog> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('Catalog')
          .doc(widget.cat.doc)
          .collection('sub')
          .doc(widget.sub.doc)
          .collection('subsub')
          .doc(widget.subsub.doc)
          .collection('item')
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
            child: Text('No items found.'.tr,style: TextStyle(
              fontFamily: ManagerFontFamily.fontFamily,

            ),),
          );
        }

        final docs = snapshot.data!.docs;
        final List<CatalogItemModel> items = docs.reversed.map((doc) {
          return CatalogItemModel(
            doc: doc.id,
            name: doc.get('name'),
            path: doc.get('path'),
            des: doc.get('des'),
            price: doc.get('price'),
          );
        }).toList();

        widget.sub.items = items;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = items[index];

              return InkWell(
                onTap: () {
                  if (widget.userModel.type == "Admin") {
                    Get.to(
                      ItemDetailsCatalogView(
                        widget.cat,
                        widget.sub,
                        widget.subsub,
                        item,
                      ),
                      duration: const Duration(seconds: 1),
                      transition: Transition.fadeIn,
                    );
                  }
                },
                child: CustomItemCard(item),
              );
            },
          ),
        );
      },
    );
  }
}
