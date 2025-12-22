import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:pallon_lastversion/feature/Catalog/widget/sub_catalog_widget.dart';
import 'package:pallon_lastversion/feature/Catalog/widget/category_card.dart';

import '../../../models/catalog_model.dart';
import '../../../models/user_model.dart';
import 'edit_cateory_widget.dart';

class CatalogStreamWidget extends StatefulWidget {
  final UserModel user;

  const CatalogStreamWidget(
      this.user, {
        Key? key,
      }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CatalogStreamWidgetState();
  }
}

class _CatalogStreamWidgetState extends State<CatalogStreamWidget> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('Catalog').snapshots(),
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
            child: Text('No items found.'.tr),
          );
        }

        final docs = snapshot.data!.docs;
        final List<Catalog> catalogs = docs.reversed.map((doc) {
          return Catalog(
            doc: doc.id,
            cat: doc.get('cat'),
            pic: doc.get('pic'),
          );
        }).toList();

        final bool isAdmin = widget.user.type == "Admin";

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          physics: const BouncingScrollPhysics(),
          itemCount: catalogs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final catalog = catalogs[index];

            return CategoryCard(
              title: catalog.cat,
              imageUrl: catalog.pic,
              isAdmin: isAdmin,
              onTap: () {
                Get.to(
                  SubCatalogWidgte(catalog, widget.user),
                  transition: Transition.fadeIn,
                  duration: const Duration(milliseconds: 400),
                );
              },
              onEdit: isAdmin
                  ? () {
                Get.bottomSheet(
                  EditCategoryWidget(catalog),
                  clipBehavior: Clip.hardEdge,
                  enableDrag: true,
                  persistent: true,
                  ignoreSafeArea: true,
                );
              }
                  : null,
              onDelete: isAdmin
                  ? () async {
                await _firestore
                    .collection('Catalog')
                    .doc(catalog.doc)
                    .delete();
              }
                  : null,
            );
          },
        );
      },
    );
  }
}
