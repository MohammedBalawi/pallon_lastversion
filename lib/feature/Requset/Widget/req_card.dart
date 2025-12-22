import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pallon_lastversion/feature/Requset/Widget/req_details_widget.dart';
import '../../../models/req_data_model.dart';
import '../../Orders/function/order_function.dart';
import '../../Orders/view/create_order_view.dart';
import '../../Orders/view/order_view.dart';
import '../functions/req_functions.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

Widget buildReqCard(BuildContext context, ReqDataModel req) {
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString().trim()) ?? 0.0;
  }

  String _safeText(dynamic v, {String fallback = "-"}) {
    if (v == null) return fallback;
    final s = v.toString().trim();
    return s.isEmpty ? fallback : s;
  }

  double _safeProgress(dynamic deposit, dynamic total) {
    final d = _toDouble(deposit);
    final t = _toDouble(total);
    if (t <= 0) return 0.0;

    final p = d / t;
    if (p.isNaN || p.isInfinite) return 0.0;

    return p.clamp(0.0, 1.0);
  }

  final double progress = _safeProgress(req.deposite, req.total);
  final int percent = ((progress * 100).isNaN || (progress * 100).isInfinite)
      ? 0
      : (progress * 100).round();

  Text _line(String text) => Text(
    text,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: TextStyle(
      fontSize: screenWidth * 0.035,
      color: Colors.grey[600],
    ),
  );

  return InkWell(
    onTap: () {
      Get.to(
            () => ReqDetailsWidget(req),
        transition: Transition.zoom,
        duration: const Duration(seconds: 1),
      );
    },
    child: Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: screenWidth * 0.015,
            height: screenHeight * 0.1,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          SizedBox(width: screenWidth * 0.04),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _safeText(
                      req.name),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF000000),
                  ),
                ),
                SizedBox(height: screenHeight * 0.005),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _line("Created By ${_safeText(req.createby)}"),
                          _line("Branch ${_safeText(req.branch)}"),
                          _line("Payment Type: ${_safeText(req.typebank)}"),
                          _line(_safeText(req.status)),
                        ],
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03),

                    SizedBox(
                      width: screenWidth * 0.15, height: screenWidth * 0.15,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 8,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              (progress > 0.5)
                                  ? const Color(0xFF07933E)
                                  : const Color(0xFFCE232B),
                            ),
                          ),
                          Text(
                            '$percent%',
                            style: TextStyle(
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

                SizedBox(height: screenHeight * 0.02),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _safeText(req.typeOfEvent),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.005),
                          Text(
                            _safeText(req.address),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Due date',
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.005),
                        Text(
                          _safeText(req.date),
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            color: const Color(0xFF000000),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: screenHeight * 0.02),

                req.status == "inreview"
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await _firestore
                              .collection('req')
                              .doc(req.doc)
                              .update({'status': 'active'});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF07933E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 16.0,
                          ),
                          elevation: 5,
                        ),
                        child: Text(
                          "Accept".tr,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          RejectRequset(req, context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 16.0,
                          ),
                          elevation: 5,
                        ),
                        child: Text(
                          "Reject".tr,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                )
                    : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      bool cheeck =
                      await cheeckJopOrderCreated(req, context);
                      if (cheeck == false) {
                        Get.to(
                              () => CreateOrderView(req),
                          transition: Transition.fadeIn,
                          duration: const Duration(seconds: 1),
                        );
                      } else {
                        Get.to(
                              () => OrderView(),
                          transition: Transition.fadeIn,
                          duration: const Duration(seconds: 1),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF07933E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 16.0,
                        horizontal: 33,
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      "Create Job Order".tr,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
