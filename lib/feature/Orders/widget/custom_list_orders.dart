import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pallon_lastversion/Core/Utils/manager_fonts.dart';

import '../../../models/order_model.dart';
import '../../../models/req_data_model.dart';
import '../view/order_details_view.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

final Map<String, String> _creatorNameCache = {};
final Map<String, Future<String>> _creatorNameFutureCache = {};

Future<String> _getCreatorName(ReqDataModel req) async {
  final name = (req.createname ?? '').trim();
  final uid = (req.createby).trim();

  if (name.isNotEmpty) {
    if (uid.isNotEmpty) _creatorNameCache[uid] = name;
    return name;
  }

  if (uid.isEmpty) return "-";

  final cached = _creatorNameCache[uid];
  if (cached != null && cached.trim().isNotEmpty) return cached;

  final cachedFuture = _creatorNameFutureCache[uid];
  if (cachedFuture != null) return cachedFuture;

  final future = _firestore.collection('user').doc(uid).get().then((doc) {
    final data = doc.data() ?? {};
    final resolved = (data['name'] ?? '').toString().trim();
    if (resolved.isNotEmpty) _creatorNameCache[uid] = resolved;
    return resolved.isNotEmpty ? resolved : "-";
  }).catchError((_) => "-");

  _creatorNameFutureCache[uid] = future;
  return future;
}

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

  DateTime? _parseDateValue(dynamic raw) {
    if (raw == null) return null;
    if (raw is Timestamp) return raw.toDate();
    if (raw is DateTime) return raw;
    if (raw is num) {
      return DateTime.fromMillisecondsSinceEpoch(raw.toInt());
    }

    final value = raw.toString().trim();
    if (value.isEmpty) return null;

    try {
      return DateTime.parse(value);
    } catch (_) {}

    for (final fmt in [
      DateFormat('yyyy/MM/dd'),
      DateFormat('yyyy-MM-dd'),
      DateFormat('dd/MM/yyyy'),
      DateFormat('MM/dd/yyyy'),
    ]) {
      try {
        return fmt.parseLoose(value);
      } catch (_) {}
    }

    return null;
  }

  String _formatDateText(dynamic raw) {
    final parsed = _parseDateValue(raw);
    final rawText = raw?.toString().trim() ?? "";
    if (parsed == null) return rawText.isEmpty ? "-" : rawText;
    final locale = Get.locale?.languageCode ?? Intl.getCurrentLocale();
    return DateFormat.yMMMd(locale).format(parsed);
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
          date: ReqDataModel.normalizeDate(data['date']),
          hour: (data['hour'] ?? "").toString(),
          phone: (data['phone'] ?? "").toString(),
          createby: (data['createby'] ?? "").toString(),
          createname: (data['createname'] ?? "").toString(),
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
          invoiceNumber: (data['invoiceNumber'] ?? data['invoice_number'] ?? "").toString(),
          eventName: (data['eventName'] ?? data['event_name'] ?? "").toString(),
          requestDate: ReqDataModel.normalizeDate(data['requestDate'] ?? data['request_date']),
          createdAt: ReqDataModel.normalizeDate(data['createdAt']),
        );

        req.orderNumber = (data['orderNumber'] ?? "").toString().trim();

        req.jobOrderNumber = (data['jobOrderNumber'] ?? "").toString().trim();

        req.task = (data['task'] ?? "").toString().trim();

        return req;
      }).toList();

      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: lists.length,
        itemBuilder: (context, index) {
          final req = lists[index];
          final creatorNameFuture = _getCreatorName(req);

          double progress = _progressFromTask(req);
          progress = progress.clamp(0.0, 1.0);

          final order = OrderModel()..req = req;

          final progressColor =
          (progress >= 0.5) ? const Color(0xFF07933E) : const Color(0xFFCE232B);

          final jobNoText = (req.jobOrderNumber ?? "").trim().isEmpty
              ? "-"
              : (req.jobOrderNumber ?? "").trim();

          final reqNoText = req.canonicalOrderNumber().trim().isEmpty
              ? "-"
              : req.canonicalOrderNumber();
          final dueDateText = _formatDateText(req.date);

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
                          FutureBuilder<String>(
                            future: creatorNameFuture,
                            builder: (context, snapshot) {
                              final creatorName = (snapshot.data ?? "").trim();
                              final displayName = creatorName.isNotEmpty ? creatorName : "-";
                              final titleText = req.displayTitleName(fallback: "no_name".tr);
                              return Text(
                                titleText,
                                style: titleStyle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              );
                            },
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

                                    FutureBuilder<String>(
                                      future: creatorNameFuture,
                                      builder: (context, snapshot) {
                                        final creatorName = (snapshot.data ?? "").trim();
                                        final displayName = creatorName.isNotEmpty ? creatorName : "-";
                                        return infoLine(
                                          label: "Created By".tr,
                                          value: displayName,
                                        );
                                      },
                                    ),
                                    infoLine(
                                      label: "Branch".tr,
                                      value: req.branch,
                                    ),
                                    infoLine(
                                      label: "payment_method".tr,
                                      value: req.typebank,
                                    ),
                                    infoLine(
                                      label: "status".tr,
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
                                  Text('due_date'.tr, style: labelStyle),
                                  const SizedBox(height: 6),
                                  Text(
                                    dueDateText,
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
