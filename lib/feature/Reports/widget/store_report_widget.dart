import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pallon_lastversion/models/item_model.dart';
import 'package:pallon_lastversion/Core/Utils/manager_fonts.dart';

import '../function/reports_functions.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

Widget StoreReport(BuildContext context) {
  final screenHeight = MediaQuery.of(context).size.height;
  final screenWidth = MediaQuery.of(context).size.width;

  return StreamBuilder<QuerySnapshot>(
    stream: _firestore.collection('itemhistory').snapshots(),
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
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        );
      }

      List<DataRow> rows = [];
      List<ItemModel> items = [];
      final messages = snapshot.data!.docs;

      for (var message in messages.reversed) {
        final data = message.data() as Map<String, dynamic>;

        final itemModel = ItemModel(
          doc: message.id,
          id: data['id'],
          name: data['Item'],
          count: int.parse(data['count'].toString()),
          price: double.parse(data['price'].toString()),
          pic: data['pic'],
          show: bool.parse(data['show'].toString()),
        )
          ..time = data['time']
          ..action = data['type'];

        rows.add(
          DataRow(
            cells: [
              DataCell(
                Text(
                  data['id'].toString(),
                  style: TextStyle(
                    fontFamily: ManagerFontFamily.fontFamily,
                    fontSize: screenWidth * 0.032,
                    color: const Color(0xFF333333),
                  ),
                ),
              ),
              DataCell(
                Text(
                  data['Item'] ?? '',
                  style: TextStyle(
                    fontFamily: ManagerFontFamily.fontFamily,
                    fontSize: screenWidth * 0.032,
                    color: const Color(0xFF333333),
                  ),
                ),
              ),
              DataCell(
                Text(
                  data['time']?.toString() ?? '',
                  style: TextStyle(
                    fontFamily: ManagerFontFamily.fontFamily,
                    fontSize: screenWidth * 0.032,
                    color: const Color(0xFF333333),
                  ),
                ),
              ),
              DataCell(
                Text(
                  itemModel.action.toString().tr,
                  style: TextStyle(
                    fontFamily: ManagerFontFamily.fontFamily,
                    fontSize: screenWidth * 0.032,
                    fontWeight: FontWeight.w600,
                    color: itemModel.action == "add"
                        ? const Color(0xFF07933E)
                        : const Color(0xFFCE232B),
                  ),
                ),
              ),
              DataCell(
                Text(
                  data['count']?.toString() ?? '',
                  style: TextStyle(
                    fontFamily: ManagerFontFamily.fontFamily,
                    fontSize: screenWidth * 0.032,
                    color: const Color(0xFF333333),
                  ),
                ),
              ),
            ],
          ),
        );

        items.add(itemModel);
      }

      return Column(
        children: [
          Card(
            color: Colors.white,
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Store History'.tr,
                        style: TextStyle(
                          fontFamily: ManagerFontFamily.fontFamily,
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF222222),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF07933E).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${items.length} ${"Records".tr}',
                          style: TextStyle(
                            fontFamily: ManagerFontFamily.fontFamily,
                            fontSize: screenWidth * 0.03,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF07933E),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: screenWidth * 0.12,
                      horizontalMargin: 10,
                      dividerThickness: 0.8,
                      headingRowHeight: 42,
                      dataRowMinHeight: 40,
                      dataRowMaxHeight: 52,
                      headingRowColor: MaterialStateProperty.all(
                        const Color(0xFF07933E).withOpacity(0.06),
                      ),
                      showBottomBorder: true,
                      columns: [
                        DataColumn(
                          label: SizedBox(
                            height: 40,
                            child: Center(
                              child: Text(
                                'ID'.tr,
                                style: TextStyle(
                                  fontFamily: ManagerFontFamily.fontFamily,
                                  fontSize: screenWidth * 0.033,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF444444),
                                ),
                              ),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            height: 40,
                            child: Center(
                              child: Text(
                                'Name'.tr,
                                style: TextStyle(
                                  fontFamily: ManagerFontFamily.fontFamily,
                                  fontSize: screenWidth * 0.033,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF444444),
                                ),
                              ),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            height: 40,
                            child: Center(
                              child: Text(
                                'Time'.tr,
                                style: TextStyle(
                                  fontFamily: ManagerFontFamily.fontFamily,
                                  fontSize: screenWidth * 0.033,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF444444),
                                ),
                              ),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            height: 40,
                            child: Center(
                              child: Text(
                                'Action'.tr,
                                style: TextStyle(
                                  fontFamily: ManagerFontFamily.fontFamily,
                                  fontSize: screenWidth * 0.033,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF444444),
                                ),
                              ),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            height: 40,
                            child: Center(
                              child: Text(
                                'Count'.tr,
                                style: TextStyle(
                                  fontFamily: ManagerFontFamily.fontFamily,
                                  fontSize: screenWidth * 0.033,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF444444),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                      rows: rows,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: screenHeight * 0.01),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 4),
            child: SizedBox(
              width: double.infinity,
              height: screenHeight * 0.07,
              child: ElevatedButton.icon(
                onPressed: () {
                  StoreexportToPdf(context, items);
                },
                icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCE232B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.05),
                  ),
                  elevation: 5,
                ),
                label: Text(
                  "PDF",
                  style: TextStyle(
                    fontFamily: ManagerFontFamily.fontFamily,
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 4),
            child: SizedBox(
              width: double.infinity,
              height: screenHeight * 0.07,
              child: ElevatedButton.icon(
                onPressed: () {
                  StoreexportToExcel(context, items);
                },
                icon: const Icon(Icons.table_chart, color: Colors.white),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCE232B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.05),
                  ),
                  elevation: 5,
                ),
                label: Text(
                  "Excel",
                  style: TextStyle(
                    fontFamily: ManagerFontFamily.fontFamily,
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}
