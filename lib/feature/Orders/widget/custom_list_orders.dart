import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pallon_lastversion/Core/Utils/manager_fonts.dart';

import '../../../models/order_model.dart';
import '../../../models/req_data_model.dart';
import '../view/order_details_view.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

Widget CustomListOrders(BuildContext context) {
  final screenHeight = MediaQuery.of(context).size.height;
  final screenWidth = MediaQuery.of(context).size.width;

  TextStyle titleStyle = TextStyle(
    fontFamily: ManagerFontFamily.fontFamily,
    fontSize: screenWidth * 0.045,
    fontWeight: FontWeight.bold,
    color: const Color(0xFF000000),
  );

  TextStyle labelStyle = TextStyle(
    fontFamily: ManagerFontFamily.fontFamily,
    fontSize: screenWidth * 0.035,
    color: Colors.grey[600],
  );

  TextStyle valueStyle = TextStyle(
    fontFamily: ManagerFontFamily.fontFamily,
    fontSize: screenWidth * 0.037,
    color: const Color(0xFF111111),
    fontWeight: FontWeight.w600,
  );

  double _safeDouble(String? s) => double.tryParse((s ?? "").trim()) ?? 0.0;

  double _progressFromTask(ReqDataModel req) {
    final task = (req.task ?? "").toLowerCase().trim();

    if (task == "designer") return 0.0;
    if (task == "vendor") return 0.35;
    if (task == "driver") return 0.7;
    if (task == "finish") return 1.0;

    final dep = _safeDouble(req.deposite);
    final tot = _safeDouble(req.total);
    if (tot <= 0) return 0.0;
    return dep / tot;
  }

  Widget infoLine({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: labelStyle),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: valueStyle.copyWith(fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  return StreamBuilder<QuerySnapshot>(
    stream: _firestore
        .collection('req')
        .where('status', isEqualTo: 'order')
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(
          child: CircularProgressIndicator(backgroundColor: Color(0xFF07933E)),
        );
      }

      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return Center(child: Text('No items found.'.tr));
      }

      final docs = snapshot.data!.docs;

      final List<ReqDataModel> lists = docs.reversed.map((message) {
        final data = message.data() as Map<String, dynamic>;

        final req = ReqDataModel(
          doc: message.id,
          name: (data['name'] ?? "").toString(),
          fees: (data['fees'] ?? "0").toString(),
          total: (data['total'] ?? "0").toString(),
          des: [],
          item: [],
          float: (data['float'] ?? "").toString(),
          address: (data['address'] ?? "").toString(),
          date: (data['date'] ?? "").toString(),
          hour: (data['hour'] ?? "").toString(),
          phone: (data['phone'] ?? "").toString(),
          createby: (data['createby'] ?? "").toString(),
          deposite: (data['deposit'] ?? data['deposite'] ?? "0").toString(),
          design: (data['desgin'] ?? data['design'] ?? "").toString(),
          notes: (data['notes'] ?? "").toString(),
          ownerOfevent: (data['ownerofevent'] ?? "").toString(),
          status: (data['status'] ?? "").toString(),
          typeby: (data['typeCreate'] ?? "").toString(),
          typeOfBuilding: (data['typeofbuilding'] ?? "").toString(),
          typeOfEvent: (data['typeofevent'] ?? "").toString(),
          branch: (data['branch'] ?? "").toString(),
          typebank: (data['banktype'] ?? "").toString(),
        );

        req.orderNumber = (data['orderNumber'] ?? "").toString().trim();

        req.jobOrderNumber = (data['ordernumber'] ?? "").toString().trim();

        req.task = (data['task'] ?? "").toString().trim();

        return req;
      }).toList();

      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: lists.length,
        itemBuilder: (context, index) {
          final req = lists[index];

          double progress = _progressFromTask(req);
          progress = progress.clamp(0.0, 1.0);

          final order = OrderModel()..req = req;

          final progressColor =
          (progress >= 0.5) ? const Color(0xFF07933E) : const Color(0xFFCE232B);

          final jobNoText = (req.jobOrderNumber ?? "").trim().isEmpty
              ? "-"
              : (req.jobOrderNumber ?? "").trim();

          final reqNoText = (req.orderNumber ?? "").trim().isEmpty
              ? "-"
              : (req.orderNumber ?? "").trim();

          return InkWell(
            onTap: () {
              Get.to(
                    () => OrderDetailsView(order),
                duration: const Duration(milliseconds: 450),
                transition: Transition.zoom,
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Container(
                padding: EdgeInsets.all(screenWidth * 0.045),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.grey.withOpacity(0.15)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 6,
                      height: screenHeight * 0.16,
                      decoration: BoxDecoration(
                        color: progressColor.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.04),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            req.typeOfEvent,
                            style: titleStyle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    infoLine(
                                      label: "Job Order #".tr,
                                      value: jobNoText,
                                    ),

                                    infoLine(
                                      label: "REQ #".tr,
                                      value: reqNoText,
                                    ),

                                    infoLine(
                                      label: "Created By".tr,
                                      value: req.createby,
                                    ),
                                    infoLine(
                                      label: "Branch".tr,
                                      value: req.branch,
                                    ),
                                    infoLine(
                                      label: "Payment Type:".tr,
                                      value: req.typebank,
                                    ),
                                    infoLine(
                                      label: "Status".tr,
                                      value: req.status,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),

                              SizedBox(
                                width: screenWidth * 0.18,
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: screenWidth * 0.16,
                                      height: screenWidth * 0.16,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          CircularProgressIndicator(
                                            value: progress,
                                            strokeWidth: 8,
                                            backgroundColor: Colors.grey[200],
                                            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                                          ),
                                          Text(
                                            '${(progress * 100).toInt()}%',
                                            style: TextStyle(
                                              fontFamily: ManagerFontFamily.fontFamily,
                                              fontSize: screenWidth * 0.03,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF000000),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),
                          Divider(color: Colors.grey.withOpacity(0.2), height: 1),
                          const SizedBox(height: 12),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      req.name,
                                      style: labelStyle.copyWith(fontWeight: FontWeight.w700),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      req.address,
                                      style: valueStyle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('Due date'.tr, style: labelStyle),
                                  const SizedBox(height: 6),
                                  Text(
                                    req.date,
                                    style: valueStyle.copyWith(fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
