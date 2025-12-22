import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Core/Utils/manager_fonts.dart';
import '../../../Core/Widgets/custom_item_card.dart';
import '../../../models/catalog_item_model.dart';
import '../../../models/user_model.dart';
import 'package:pallon_lastversion/feature/Catalog/view/item_view.dart';

class ItemStreamWidget extends StatefulWidget {
  final UserModel userModel;
  final String path;

  const ItemStreamWidget(
      this.path,
      this.userModel, {
        Key? key,
      }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ItemStreamWidgetState();
  }
}

class _ItemStreamWidgetState extends State<ItemStreamWidget> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    // final screenWidth  = MediaQuery.of(context).size.width;

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection(widget.path).snapshots(),
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

        return  Padding(
          padding: const EdgeInsets.all(18.0),
          child: GridView.builder(
            itemCount: items.length,
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.6,
            ),
            itemBuilder: (context, index) {
              final item = items[index];

              return InkWell(
                onTap: () {
                  if (widget.userModel.type == "Admin") {
                    Get.to(
                      ItemView(item, widget.path),
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
