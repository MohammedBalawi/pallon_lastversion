import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pallon_lastversion/Core/Widgets/image_view.dart';

import '../../../models/item_model.dart';
import '../view/edit_item_view.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

Widget CustomeItemTable(BuildContext context, {String searchQuery = ''}) {
  final screenHeight = MediaQuery.of(context).size.height;
  final screenWidth = MediaQuery.of(context).size.width;

  return StreamBuilder<QuerySnapshot>(
    stream: _firestore.collection("item").snapshots(),
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

      final messages = snapshot.data!.docs;

      final filteredMessages = messages.where((message) {
        final data = message.data() as Map<String, dynamic>;
        final itemName = (data['Item'] ?? '').toString().toLowerCase();
        return itemName.contains(searchQuery.toLowerCase());
      }).toList();

      if (filteredMessages.isEmpty) {
        return Center(
          child: Text('No items match your search.'.tr),
        );
      }

      List<DataRow> rows = [];

      for (var message in filteredMessages.reversed) {
        final data = message.data() as Map<String, dynamic>;

        final id = data['id']?.toString() ?? '';
        final name = data['Item']?.toString() ?? '';
        final pic = data['pic']?.toString() ?? '';
        final count = int.tryParse(data['count']?.toString() ?? '0') ?? 0;
        final price = double.tryParse(data['price']?.toString() ?? '0') ?? 0;
        final priceBuy = double.tryParse(data['pricebuy']?.toString() ?? '0') ?? 0;
        final show = data['show'].toString() == 'true' || data['show'] == true;

        final itemModel = ItemModel(
          doc: message.id,
          id: id,
          name: name,
          count: count,
          price: price,
          pic: pic,
          show: show,
        )..pricebuy = priceBuy;
        itemModel.des=data['des'];
        rows.add(
          DataRow(
            cells: [
              DataCell(InkWell(
                  onTap:(){
                    Get.to(
                      EditItemView(itemModel),
                      duration: const Duration(seconds: 1),
                      transition: Transition.topLevel,
                    );
                  },child: Text(id))),
              DataCell(
                InkWell(
                  onTap:(){
                    Get.to(
                      ViewImage(pic),
                      duration: const Duration(seconds: 1),
                      transition: Transition.topLevel,
                    );
                  },
                  child:Card(
                    child: CachedNetworkImage(imageUrl: pic,width: 50,fit: BoxFit.cover,),
                  )
                ),
              ),
              DataCell(InkWell(
                  onTap:(){
                    Get.to(
                      EditItemView(itemModel),
                      duration: const Duration(seconds: 1),
                      transition: Transition.topLevel,
                    );
                  },child: Text(name))),
              DataCell(InkWell(
                  onTap:(){
                    Get.to(
                      EditItemView(itemModel),
                      duration: const Duration(seconds: 1),
                      transition: Transition.topLevel,
                    );
                  },child: Text(count.toString()))),
              DataCell(InkWell(
                  onTap:(){
                    Get.to(
                      EditItemView(itemModel),
                      duration: const Duration(seconds: 1),
                      transition: Transition.topLevel,
                    );
                  },child: Text(priceBuy.toString()))),
              DataCell(InkWell(
                  onTap:(){
                    Get.to(
                      EditItemView(itemModel),
                      duration: const Duration(seconds: 1),
                      transition: Transition.topLevel,
                    );
                  },child: Text(price.toString()))),
              DataCell(InkWell(
                  onTap:(){
                    Get.to(
                      EditItemView(itemModel),
                      duration: const Duration(seconds: 1),
                      transition: Transition.topLevel,
                    );
                  },child: Text(itemModel.des.toString()))),
              DataCell(
                IconButton(
                  onPressed: () {
                    Get.to(
                      EditItemView(itemModel),
                      duration: const Duration(seconds: 1),
                      transition: Transition.topLevel,
                    );
                  },
                  icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent),
                ),
              ),
            ],
          ),
        );
      }

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: screenWidth * 0.18,
          horizontalMargin: 16,
          dividerThickness: 2.0,
          showBottomBorder: true,
          columns: [
            _dataColumn('ID', screenWidth),
            _dataColumn('Picture', screenWidth),
            _dataColumn('Name', screenWidth),
            _dataColumn('Count', screenWidth),
            _dataColumn('Price Buy', screenWidth),
            _dataColumn('Total Price', screenWidth),
            _dataColumn('Des', screenWidth),
            _dataColumn('Action', screenWidth),
          ],
          rows: rows,
        ),
      );
    },
  );
}

DataColumn _dataColumn(String label, double screenWidth) {
  return DataColumn(
    label: SizedBox(
      height: 40,
      child: Center(
        child: Text(
          label.tr,
          style: TextStyle(
            fontSize: screenWidth * 0.035,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );
}
