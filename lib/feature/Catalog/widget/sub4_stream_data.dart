import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pallon_lastversion/Core/Widgets/image_view.dart';

import '../../../Core/Utils/manager_fonts.dart';
import '../../../models/catalog_model.dart';
import '../../../models/sub_cat_model.dart';
import '../../../models/sub_sub_cat.dart';
import '../../../models/user_model.dart';
import '../Funcation/catalog_function.dart';
import '../models/sub3_cat_model.dart';
import 'category_card.dart';

Widget Sub4StreamData(
    BuildContext context,
    Catalog catalog,
    SubCatModel sub,
    SubSubCatModel subsub,
    Sub3CatModel sub3,
    UserModel user,
    ) {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final screenWidth  = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  return StreamBuilder<QuerySnapshot>(
    stream: _firestore
        .collection('Catalog')
        .doc(catalog.doc)
        .collection('sub')
        .doc(sub.doc)
        .collection('subsub')
        .doc(subsub.doc)
        .collection('sub3')
        .doc(sub3.doc)
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
          final sub4 = sub4List[index];

          return CategoryCard(
            title: sub4.name,
            imageUrl: sub4.pic,
            isAdmin: user.type == "Admin",

            onTap: () {
            },

            onEdit: () {
              _showEditSub4NameDialog(
                context,
                catalog,
                sub,
                subsub,
                sub3,
                sub4,
              );
            },

            onDelete: () async {
              await DeleteSub4Catalog(
                context,
                catalog,
                sub,
                subsub,
                sub3.doc,
                sub4.doc,
              );
            },
          );
        },
      );

    },
  );
}

void _showEditSub4NameDialog(
    BuildContext context,
    Catalog catalog,
    SubCatModel sub,
    SubSubCatModel subsub,
    Sub3CatModel sub3,
    Sub4CatModel sub4,
    ) {
  final TextEditingController _name =
  TextEditingController(text: sub4.name);

  showDialog(
    context: context,
    builder: (ctx) {
      final screenWidth  = MediaQuery.of(ctx).size.width;
      final screenHeight = MediaQuery.of(ctx).size.height;

      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            const Icon(
              Icons.edit,
              color: Color(0xFFCE232B),
            ),
            const SizedBox(width: 8),
            Text(
              'Edit Name'.tr,
              style: TextStyle(
                fontFamily: ManagerFontFamily.fontFamily,
                color: const Color(0xFFCE232B),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: TextFormField(
          style: TextStyle(
            fontFamily: ManagerFontFamily.fontFamily,
            fontSize: 14,
          ),
          controller: _name,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.text_fields),
            hintText: 'Name'.tr,
            filled: true,
            hintStyle: TextStyle(
              fontFamily: ManagerFontFamily.fontFamily,
              fontSize: 14,
            ),
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(screenWidth * 0.03),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.02,
              horizontal: screenWidth * 0.05,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel'.tr,
              style: TextStyle(
                fontFamily: ManagerFontFamily.fontFamily,
                color: Colors.grey,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              if (_name.text.trim().isNotEmpty) {
                EditSub4Catalog(
                  ctx,
                  catalog,
                  sub,
                  subsub,
                  sub3.doc,
                  sub4.doc,
                  _name,
                );
              }
            },
            child: Text(
              'Save'.tr,
              style: TextStyle(
                fontFamily: ManagerFontFamily.fontFamily,
                color: const Color(0xFF07933E),
              ),
            ),
          ),
        ],
      );
    },
  );
}
