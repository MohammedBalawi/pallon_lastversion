import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pallon_lastversion/feature/Requset/Widget/req_card.dart';

import '../../../models/req_data_model.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

Widget CustomListReq(BuildContext context) {
  dynamic safeNum(dynamic v) {
    if (v == null) return "0";
    if (v is num) return v.toString();
    final s = v.toString().trim();
    if (s.isEmpty) return "0";
    return (num.tryParse(s) ?? 0).toString();
  }

  String safeStr(dynamic v, {String def = ""}) {
    if (v == null) return def;
    final s = v.toString();
    return s;
  }

  return StreamBuilder<QuerySnapshot>(
    stream: _firestore
        .collection('req')
        .where('status', isNotEqualTo: 'reject')
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
        return Center(child: Text('No items found.'.tr));
      }

      final docs = snapshot.data!.docs.reversed;
      final List<ReqDataModel> lists = [];

      for (final doc in docs) {
        final status = safeStr(doc.data() is Map ? (doc.get('status')) : null);

        if (status == "order" || status == "finish") continue;

        lists.add(
          ReqDataModel(
            doc: doc.id,
            name: safeStr(doc.get('name')),
            fees: safeNum(doc.get('fees')),
            total: safeNum(doc.get('total')),
            des: [],
            item: [],
            float: safeNum(doc.get('float')),
            address: safeStr(doc.get('address')),
            date: safeStr(doc.get('date')),
            hour: safeStr(doc.get('hour')),
            phone: safeStr(doc.get('phone')),
            createby: safeStr(doc.get('createby')),
            deposite: safeNum(doc.get('deposit')),
            design: safeStr(doc.get('desgin')),
            notes: safeStr(doc.get('notes')),
            ownerOfevent: safeStr(doc.get('ownerofevent')),
            status: status,
            typeby: safeStr(doc.get('typeCreate')),
            typeOfBuilding: safeStr(doc.get('typeofbuilding')),
            typeOfEvent: safeStr(doc.get('typeofevent')),
            branch: safeStr(doc.get('branch')),
            typebank: safeStr(doc.get('banktype')),
          ),
        );
      }

      if (lists.isEmpty) {
        return Center(child: Text("No items found.".tr));
      }

      return ListView.builder(
        itemCount: lists.length,
        itemBuilder: (context, index) {
          return buildReqCard(context, lists[index]);
        },
      );
    },
  );
}
