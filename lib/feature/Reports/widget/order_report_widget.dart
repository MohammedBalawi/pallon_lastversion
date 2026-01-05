import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/req_data_model.dart';
import '../function/reports_functions.dart';
import 'package:pallon_lastversion/Core/Utils/manager_fonts.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

Widget OrderReportWidget(BuildContext context, String type) {
  if (type == "All") {
    type = type;
  } else if (type == "Compelete") {
    type = "finish";
  } else if (type == "InReview") {
    type = "inreview";
  } else if (type == "Accept") {
    type = "active";
  } else if (type == "Progress") {
    type = "order";
  } else if (type == "Reject") {
    type = "reject";
  }

  final screenHeight = MediaQuery.of(context).size.height;
  final screenWidth = MediaQuery.of(context).size.width;

  final TextStyle headerTextStyle = TextStyle(
    fontFamily: ManagerFontFamily.fontFamily,
    fontSize: screenWidth * 0.032,
    fontWeight: FontWeight.w700,
    color: const Color(0xFF222222),
  );

  final TextStyle cellTextStyle = TextStyle(
    fontFamily: ManagerFontFamily.fontFamily,
    fontSize: screenWidth * 0.03,
    fontWeight: FontWeight.w500,
    color: const Color(0xFF444444),
  );

  return StreamBuilder<QuerySnapshot>(
    stream: type == "All"
        ? _firestore.collection('req').snapshots()
        : _firestore.collection('req').where('status', isEqualTo: type).snapshots(),
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
              color: Colors.grey[700],
            ),
          ),
        );
      }

      List<DataRow> rows = [];
      List<ReqDataModel> reqs = [];
      int indexx = 1;

      final messages = snapshot.data!.docs;
      for (var message in messages.reversed) {
        final data = message.data() as Map<String, dynamic>;

        ReqDataModel req = ReqDataModel(
          doc: message.id,
          name: data['name'],
          fees: data['fees'],
          total: data['total'],
          des: [],
          item: [],
          float: data['float'],
          address: data['address'],
          date: ReqDataModel.normalizeDate(data['date']),
          hour: data['hour'],
          phone: data['phone'],
          createby: data['createby'],
          deposite: data['deposit'],
          design: data['desgin'],
          notes: data['notes'],
          ownerOfevent: data['ownerofevent'],
          status: data['status'],
          typeby: data['typeCreate'],
          typeOfBuilding: data['typeofbuilding'],
          typeOfEvent: data['typeofevent'],
          branch: data["branch"],
          typebank: data["banktype"],
          invoiceNumber: (data['invoiceNumber'] ?? data['invoice_number'] ?? "").toString(),
          eventName: (data['eventName'] ?? data['event_name'] ?? "").toString(),
          requestDate: ReqDataModel.normalizeDate(data['requestDate'] ?? data['request_date']),
          createdAt: ReqDataModel.normalizeDate(data['createdAt']),
        );

        DataRow row = DataRow(
          cells: [
            DataCell(Text(indexx.toString(), style: cellTextStyle)),
            DataCell(Text(data['name'] ?? '', style: cellTextStyle)),
            DataCell(Text(data['ownerofevent']?.toString() ?? '', style: cellTextStyle)),
            DataCell(Text(data['phone']?.toString() ?? '', style: cellTextStyle)),
            DataCell(Text(data['address']?.toString() ?? '', style: cellTextStyle)),
            DataCell(Text(data['typeofevent']?.toString() ?? '', style: cellTextStyle)),
            DataCell(Text(data['typeofbuilding']?.toString() ?? '', style: cellTextStyle)),
            DataCell(Text(data['createby']?.toString() ?? '', style: cellTextStyle)),
            DataCell(Text(data['date']?.toString() ?? '', style: cellTextStyle)),
            DataCell(Text(data['deposit']?.toString() ?? '', style: cellTextStyle)),
            DataCell(Text(data['total']?.toString() ?? '', style: cellTextStyle)),
            DataCell(Text(data['status']?.toString() ?? '', style: cellTextStyle)),
          ],
        );

        indexx++;
        rows.add(row);
        reqs.add(req);
      }

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Card(
              color: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: screenWidth * 0.08,
                    horizontalMargin: 12,
                    dividerThickness: 1.0,
                    showBottomBorder: true,
                    headingRowHeight: 44,
                    dataRowMinHeight: 40,
                    headingRowColor: MaterialStateProperty.resolveWith(
                          (states) => const Color(0xFFF3F6F8),
                    ),
                    columns: [
                      DataColumn(
                        label: SizedBox(
                          height: 40,
                          child: Center(
                            child: Text('ID'.tr, style: headerTextStyle),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          height: 40,
                          child: Center(
                            child: Text('Name'.tr, style: headerTextStyle),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          height: 40,
                          child: Center(
                            child: Text('Owner Of Event'.tr, style: headerTextStyle),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          height: 40,
                          child: Center(
                            child: Text('Phone'.tr, style: headerTextStyle),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          height: 40,
                          child: Center(
                            child: Text('Address'.tr, style: headerTextStyle),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          height: 40,
                          child: Center(
                            child: Text('Type Of Event'.tr, style: headerTextStyle),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          height: 40,
                          child: Center(
                            child: Text('Type Of Building'.tr, style: headerTextStyle),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          height: 40,
                          child: Center(
                            child: Text('Created By'.tr, style: headerTextStyle),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          height: 40,
                          child: Center(
                            child: Text('Date'.tr, style: headerTextStyle),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          height: 40,
                          child: Center(
                            child: Text('Deposit'.tr, style: headerTextStyle),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          height: 40,
                          child: Center(
                            child: Text('Total'.tr, style: headerTextStyle),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          height: 40,
                          child: Center(
                            child: Text('Status'.tr, style: headerTextStyle),
                          ),
                        ),
                      ),
                    ],
                    rows: rows,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: screenHeight * 0.015),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 4),
            child: SizedBox(
              width: double.infinity,
              height: screenHeight * 0.065,
              child: ElevatedButton.icon(
                onPressed: () {
                  OrderexportToPdf(context, reqs);
                },
                icon: const Icon(Icons.picture_as_pdf,color: Colors.white,),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCE232B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.05),
                  ),
                  elevation: 5,
                ),
                label:
                 Text(
                  'Export as PDF'.tr,
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
              height: screenHeight * 0.065,
              child: ElevatedButton.icon(
                onPressed: () {
                  OrderexportToExcel(context, reqs);
                },
                icon: const Icon(Icons.grid_on_rounded,color: Colors.white,),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF07933E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.05),
                  ),
                  elevation: 5,
                ),
                label:
                 Text(
                  'Export as Excel'.tr,
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

          SizedBox(height: screenHeight * 0.01),
        ],
      );
    },
  );
}
