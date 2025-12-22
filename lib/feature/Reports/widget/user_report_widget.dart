import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pallon_lastversion/Core/Utils/manager_fonts.dart';

import '../../../models/user_model.dart';
import '../function/reports_functions.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

Widget UserReportWidget(BuildContext context, String type) {
  final screenHeight = MediaQuery.of(context).size.height;
  final screenWidth = MediaQuery.of(context).size.width;

  if (type == "All") {
    type = type;
  } else if (type == "Admin") {
    type = "Admin";
  } else if (type == "Client") {
    type = "client";
  } else if (type == "Vendor") {
    type = "vendor";
  } else if (type == "Driver") {
    type = "driver";
  } else if (type == "Designer") {
    type = "designer";
  } else if (type == "Coordinator") {
    type = "coordinator";
  }

  return StreamBuilder<QuerySnapshot>(
    stream: type == "All"
        ? _firestore.collection('user').snapshots()
        : _firestore.collection('user').where("type", isEqualTo: type).snapshots(),
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
      List<UserModel> users = [];
      int indexx = 1;
      final messages = snapshot.data!.docs;

      for (var message in messages.reversed) {
        final data = message.data() as Map<String, dynamic>;

        final userModel = UserModel(
          doc: message.id,
          email: data['email'],
          phone: data['phone'].toString(),
          name: data['name'],
          pic: data['pic'],
          type: data['type'],
        );

        rows.add(
          DataRow(
            cells: [
              DataCell(
                Text(
                  indexx.toString(),
                  style: TextStyle(
                    fontFamily: ManagerFontFamily.fontFamily,
                    fontSize: screenWidth * 0.032,
                    color: const Color(0xFF333333),
                  ),
                ),
              ),
              DataCell(
                Text(
                  data['name'].toString(),
                  style: TextStyle(
                    fontFamily: ManagerFontFamily.fontFamily,
                    fontSize: screenWidth * 0.032,
                    color: const Color(0xFF333333),
                  ),
                ),
              ),
              DataCell(
                Text(
                  data['email'].toString(),
                  style: TextStyle(
                    fontFamily: ManagerFontFamily.fontFamily,
                    fontSize: screenWidth * 0.032,
                    color: const Color(0xFF333333),
                  ),
                ),
              ),
              DataCell(
                Text(
                  data['phone'].toString(),
                  style: TextStyle(
                    fontFamily: ManagerFontFamily.fontFamily,
                    fontSize: screenWidth * 0.032,
                    color: const Color(0xFF333333),
                  ),
                ),
              ),
              DataCell(
                Text(
                  userModel.type.tr,
                  style: TextStyle(
                    fontFamily: ManagerFontFamily.fontFamily,
                    fontSize: screenWidth * 0.032,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF07933E),
                  ),
                ),
              ),
            ],
          ),
        );

        users.add(userModel);
        indexx++;
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
                        'Users Report'.tr,
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
                          '${users.length} ${"Users".tr}',
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
                                'Email'.tr,
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
                                'Phone'.tr,
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
                                'Type'.tr,
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
                  UserexportToPdf(context, users);
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
                  UserexportToExcel(context, users);
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
                      color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}
