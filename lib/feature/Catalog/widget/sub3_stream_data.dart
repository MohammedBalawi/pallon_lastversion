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
import 'sub4_widget.dart';

Widget Sub3StreamData(
    BuildContext context,
    Catalog catalog,
    SubCatModel sub,
    SubSubCatModel subsub,
    UserModel user,
    ) {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final screenWidth = MediaQuery.of(context).size.width;
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
      final List<Sub3CatModel> sub3List = docs.reversed.map((doc) {
        return Sub3CatModel(
          doc: doc.id,
          name: doc.get('name'),
          pic: doc.get('pic'),
        );
      }).toList();

      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: sub3List.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final sub3 = sub3List[index];
          final bool isAdmin = user.type == "Admin";

          return InkWell(
            onTap: () {
              Get.to(
                Sub4Widget(
                  catalog,
                  sub,
                  subsub,
                  sub3,
                  user,
                ),
                transition: Transition.fadeIn,
                duration: const Duration(seconds: 1),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sub3.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: ManagerFontFamily.fontFamily,

                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0B5674),
                            ),
                          ),
                          const SizedBox(height: 6),
                          if (isAdmin)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {
                                    _showEditSub3NameDialog(
                                      context,
                                      catalog,
                                      sub,
                                      subsub,
                                      sub3,
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () async {
                                    await DeleteSub3Catalog(
                                      context,
                                      catalog,
                                      sub,
                                      subsub,
                                      sub3.doc,
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.delete_sweep_outlined,
                                    color: Color(0xFFCE232B),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  GestureDetector(
                    onTap: () {
                      Get.to(ViewImage(sub3.pic));
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CachedNetworkImage(
                        imageUrl: sub3.pic,
                        width: screenHeight * 0.09,
                        height: screenHeight * 0.09,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

void _showEditSub3NameDialog(
    BuildContext context,
    Catalog catalog,
    SubCatModel sub,
    SubSubCatModel subsub,
    Sub3CatModel sub3,
    ) {
  final TextEditingController _name =
  TextEditingController(text: sub3.name);

  showDialog(
    context: context,
    builder: (ctx) {
      final screenWidth = MediaQuery.of(ctx).size.width;
      final screenHeight = MediaQuery.of(ctx).size.height;

      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.white,
        title: Text(
          'Edit Name'.tr,
          style:  TextStyle(
            fontFamily: ManagerFontFamily.fontFamily,

            color: Color(0xFFCE232B),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextFormField(
          controller: _name,
          style: TextStyle(
            fontFamily: ManagerFontFamily.fontFamily,
            fontSize: 14
          ),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.text_fields),
            hintText: 'Name'.tr,
            filled: true,
            hintStyle: TextStyle(
              fontFamily: ManagerFontFamily.fontFamily,
              fontSize: 14
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
              style:  TextStyle(
                  fontFamily: ManagerFontFamily.fontFamily,

                  color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              if (_name.text.trim().isNotEmpty) {
                EditSub3Catalog(
                  ctx,
                  catalog,
                  sub,
                  subsub,
                  sub3.doc,
                  _name,
                );
              }
            },
            child: Text(
              'Save'.tr,
              style:  TextStyle(
                  fontFamily: ManagerFontFamily.fontFamily,

                  color: Color(0xFF07933E)),
            ),
          ),
        ],
      );
    },
  );
}
