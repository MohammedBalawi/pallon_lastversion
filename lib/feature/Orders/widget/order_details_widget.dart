import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Core/Utils/app_snack.dart';
import '../../../Core/Widgets/image_view.dart';
import '../../../models/catalog_item_model.dart';
import '../../../models/order_model.dart';
import '../../../models/user_model.dart';
import '../../AddRequest/widget/add_req_widget.dart';
import '../../MainScreen/function/main_function.dart';
import '../../Requset/functions/req_functions.dart';
import '../../Staff/widget/staff_widget.dart';
import '../view/show_task_order_view.dart';
import '../widget/edit_employee_jop_order_widget.dart';
import '../function/order_function.dart';

class OrderDetailsWidget extends StatefulWidget {
  final OrderModel orderModel;
  const OrderDetailsWidget(this.orderModel, {super.key});

  @override
  State<OrderDetailsWidget> createState() => _OrderDetailsWidgetState();
}

class _OrderDetailsWidgetState extends State<OrderDetailsWidget> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late OrderModel _orderModel;
  bool _loading = true;
  bool _deleting = false;

  String hourForm = "AM";
  int hour = 0;

  UserModel userModel = UserModel(
    doc: "doc",
    email: "email",
    phone: "phone",
    name: "name",
    pic: "pic",
    type: "type",
  );

  List<CatalogItemModel> get _items => _orderModel.req?.item ?? [];

  double _tryDouble(String? s) => double.tryParse((s ?? "").trim()) ?? 0.0;

  @override
  void initState() {
    super.initState();
    _orderModel = widget.orderModel;

    _computeHourFromDocSafe();
    _getUserType();
    _loadStaffAndReqData();
  }

  void _safeSet(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
  }

  void _safeBack() {
    if (Get.isBottomSheetOpen ?? false) {
      Get.back();
      return;
    }
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Get.back();
    }
  }

  Future<String?> _resolveItemDocId(CatalogItemModel item) async {
    try {
      final reqDoc = _orderModel.req?.doc ?? "";
      if (reqDoc.isEmpty) return null;

      final snap = await _firestore
          .collection('req')
          .doc(reqDoc)
          .collection('item')
          .get();

      if (snap.docs.isEmpty) return null;

      for (final d in snap.docs) {
        final data = d.data();
        final name = (data['name'] ?? '').toString();
        final path = (data['path'] ?? '').toString();
        final notes = (data['notes'] ?? '').toString();
        final count = (data['count'] ?? '').toString();

        final sameName = name.trim() == (item.name).trim();
        final samePath = path.trim() == (item.path ?? '').trim();
        final sameNotes = notes.trim() == (item.des ?? '').trim();
        final sameCount = count.trim() == item.count.toString().trim();

        if (sameName && (samePath || sameNotes || sameCount)) {
          return d.id;
        }
      }

      for (final d in snap.docs) {
        final data = d.data();
        final name = (data['name'] ?? '').toString();
        if (name.trim() == item.name.trim()) return d.id;
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _updateItemPriceSafely(CatalogItemModel item, double newPrice) async {
    final reqDoc = _orderModel.req?.doc ?? "";
    if (reqDoc.isEmpty) {
      showAppSnack("لا يوجد رقم طلب صالح".tr, error: true);
      return;
    }

    String docId = item.doc;

    if (docId.trim().isEmpty) {
      final resolved = await _resolveItemDocId(item);
      if (resolved == null || resolved.isEmpty) {
        showAppSnack("تعذر تحديد عنصر المنتج لتحديثه".tr, error: true);
        return;
      }
      docId = resolved;
      item.doc = resolved;
    }

    await _firestore
        .collection('req')
        .doc(reqDoc)
        .collection('item')
        .doc(docId)
        .update({'price': newPrice.toString()});
  }

  Future<void> _recalcTotalsAndUpdateReq() async {
    double total = 0;
    for (final it in _items) {
      total += (_tryDouble(it.price)) * it.count;
    }

    final deposit = _tryDouble(_orderModel.req?.deposite);
    final fees = total - deposit;

    await _firestore.collection('req').doc(_orderModel.req!.doc).update({
      'total': total.toString(),
      'fees': fees.toString(),
    });

    _safeSet(() {
      _orderModel.req!.total = total.toString();
      _orderModel.req!.fees = fees.toString();
    });
  }

  void _computeHourFromDocSafe() {
    try {
      final raw = _orderModel.req?.doc ?? "";
      if (!raw.contains("Doc")) return;

      final dtString = raw.split('Doc').last;
      final dt = DateTime.tryParse(dtString);
      if (dt == null) return;

      if (dt.hour > 12) {
        hour = dt.hour - 12;
        hourForm = "PM";
      } else {
        hour = max(dt.hour, 1);
        hourForm = "AM";
      }
    } catch (_) {}
  }

  Future<void> _getUserType() async {
    try {
      if (_auth.currentUser == null) return;
      final user = await GetUserData(_auth.currentUser!.uid);
      if (!mounted) return;
      if (user != null) _safeSet(() => userModel = user);
    } catch (_) {}
  }

  Future<void> _loadStaffAndReqData() async {
    _safeSet(() => _loading = true);

    try {
      OrderModel orderModel = await GetStaffOrder(_orderModel, context);

      orderModel.req!.des = [];
      orderModel.req!.item = [];

      orderModel.req = await GetReqDesign(orderModel.req!, context);
      orderModel.req = await GetReqItem(orderModel.req!, context);

      final total = _tryDouble(orderModel.req!.total);
      final dep = _tryDouble(orderModel.req!.deposite);
      orderModel.req!.fees = (total - dep).toString();

      _safeSet(() {
        _orderModel = orderModel;
        _loading = false;
      });
    } catch (_) {
      _safeSet(() => _loading = false);
      showAppSnack("حدث خطأ أثناء تحميل بيانات الطلب".tr, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final req = _orderModel.req;

    if (req == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF07933E),
          title: Text("Order Details".tr, style: const TextStyle(color: Colors.white)),
        ),
        body: Center(child: Text("No order data".tr)),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF07933E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Get.offAll(
                  () =>  StaffWidget(),
              transition: Transition.fadeIn,
              duration: const Duration(milliseconds: 300),
            );
          },
        ),
        title: Text(
          "Order Details".tr,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: (_loading || _deleting)
                  ? null
                  : () => _confirmDelete(context),
              icon: Icon(
                Icons.delete,
                color: (_loading || _deleting) ? Colors.grey : Colors.red,
              ),
            ),
          ),
        ],
      ),

        body: _loading
          ? const Center(
        child: CircularProgressIndicator(backgroundColor: Color(0xFF07933E)),
      )
          : Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeaderSummary(context),
              SizedBox(height: screenHeight * 0.015),

              _buildInfoCard(
                context,
                title: "Client & Request Details".tr,
                icon: Icons.person,
                data: {
                  'Request Date'.tr: _safeReqDateText(),
                  'Client Name'.tr: req.name,
                  'Client Phone'.tr: req.phone,
                  'Owner Of Event'.tr: req.ownerOfevent,
                  'Order Number'.tr: (req.orderNumber ?? "").toString(),
                  'Job Order Number'.tr: (req.task == "order"
                      ? ((req as dynamic).jobOrderNumber?.toString() ?? "-")
                      : "-"),
                },
              ),
              SizedBox(height: screenHeight * 0.015),

              _buildInfoCard(
                context,
                title: "Event & Location".tr,
                icon: Icons.location_on,
                data: {
                  'Event Type'.tr: req.typeOfEvent,
                  'Event Owner'.tr: req.ownerOfevent,
                  'Receiving'.tr: req.branch,
                  'Address'.tr: "${req.address} - ${req.typeOfBuilding} - ${req.float}",
                },
              ),
              SizedBox(height: screenHeight * 0.015),

              _buildInfoCard(
                context,
                title: "Payment Summary".tr,
                icon: Icons.payments,
                data: {
                  'Payment Method'.tr: req.typebank,
                  'Total Price'.tr: "${req.total} SAR",
                  'Deposit'.tr: "${req.deposite} SAR",
                  'Remaining Fees'.tr: "${req.fees} SAR",
                },
              ),
              SizedBox(height: screenHeight * 0.015),

              if (_orderModel.Coordinator != null) _buildStaffCard(context),
              SizedBox(height: screenHeight * 0.015),

              if (_items.isNotEmpty) _buildItemsCard(context, screenWidth),
              if (_items.isNotEmpty) SizedBox(height: screenHeight * 0.015),

              if (req.des.isNotEmpty) _buildDesignCard(context, screenWidth),
              if (req.des.isNotEmpty) SizedBox(height: screenHeight * 0.015),

              Padding(
                padding: const EdgeInsets.all(10),
                child: SizedBox(
                  width: double.infinity,
                  height: screenWidth * 0.15,
                  child: ElevatedButton(
                    onPressed: _loading
                        ? null
                        : () {
                      Get.to(
                            () => ShowTaskOrderView(_orderModel),
                        duration: const Duration(milliseconds: 450),
                        transition: Transition.cupertino,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFCE232B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.05),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      "Show Tasks".tr,
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: (userModel.type == "Admin" && !_loading)
          ? FloatingActionButton(
        onPressed: () {
          Get.bottomSheet(
            SafeArea(child: EditEmployeeJopOrderWidget(_orderModel)),
            isScrollControlled: true,
          );
        },
        backgroundColor: Colors.white,
        child: const Icon(Icons.edit, color: Colors.black),
      )
          : null,
    );
  }

  Widget _buildHeaderSummary(BuildContext context) {
    final req = _orderModel.req!;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
        children: [
          Container(
            width: 6,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF07933E),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  req.typeOfEvent,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  "${"Branch".tr}: ${req.branch} • ${"Payment Method".tr}: ${req.typebank}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _safeReqDateText() {
    try {
      final raw = _orderModel.req!.doc;
      if (!raw.contains("Doc")) return "-";
      final dt = DateTime.tryParse(raw.split("Doc").last);
      if (dt == null) return "-";
      final h = hour == 0 ? dt.hour : hour;
      return "${dt.year}/${dt.month}/${dt.day}\n $h $hourForm";
    } catch (_) {
      return "-";
    }
  }

  Widget _buildStaffCard(BuildContext context) {
    final req = _orderModel.req!;
    final isDelivery = req.branch == "توصيل" ||
        req.branch == "توصيل و تركيب" ||
        req.branch == "شحن خارج جدة";

    final hasDesign = req.des.isNotEmpty;

    final Map<String, String> data = {
      'Coordinator'.tr: (_orderModel.Coordinator?.name ?? "-"),
      if (hasDesign) 'Designer'.tr: (_orderModel.Designer?.name ?? "-"),
      if (isDelivery) 'Driver'.tr: (_orderModel.Driver?.name ?? "-"),
      'Vendor'.tr: (_orderModel.Vendor?.name ?? "-"),
      'createby'.tr: (_orderModel.createby?.name ?? "-"),
    };

    return _buildInfoCard(context, title: "Staff".tr, icon: Icons.badge, data: data);
  }

  Widget _buildInfoCard(
      BuildContext context, {
        required String title,
        required IconData icon,
        required Map<String, String> data,
      }) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFFCE232B)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: screenWidth * 0.048,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFCE232B),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Divider(color: Colors.grey.withOpacity(0.2), height: 1),
            const SizedBox(height: 10),
            ...data.entries.map((e) => _buildInfoRow(context, title: e.key, data: e.value)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, {required String title, required String data}) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: screenWidth * 0.38,
            child: Text(
              "$title:",
              style: TextStyle(
                fontSize: screenWidth * 0.038,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              data,
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: screenWidth * 0.038,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsCard(BuildContext context, double screenWidth) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.list_alt, color: Color(0xFFCE232B)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Requested Items".tr,
                    style: TextStyle(
                      fontSize: screenWidth * 0.048,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFCE232B),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Divider(color: Colors.grey.withOpacity(0.2), height: 1),
            const SizedBox(height: 10),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: screenWidth * 0.06,
                horizontalMargin: 0,
                showBottomBorder: true,
                dataRowHeight: 64,
                headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
                columns: [
                  DataColumn(label: Text('Image'.tr, style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Name'.tr, style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Price'.tr, style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Count'.tr, style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Total'.tr, style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Notes'.tr, style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Edit'.tr, style: const TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: _items.map((item) {
                  final price = _tryDouble(item.price);
                  final total = price * item.count;

                  return DataRow(
                    cells: [
                      DataCell(_itemImageCell(item, 46)),
                      DataCell(
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: screenWidth * 0.35),
                          child: Text(item.name, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                      DataCell(Text(
                        "${item.price} SAR",
                        style: const TextStyle(color: Color(0xFF07933E), fontWeight: FontWeight.w600),
                      )),
                      DataCell(Text(
                        "${item.count}",
                        style: const TextStyle(color: Color(0xFF07933E), fontWeight: FontWeight.w600),
                      )),
                      DataCell(Text(
                        "${total.toStringAsFixed(2)} SAR",
                        style: const TextStyle(color: Color(0xFF07933E), fontWeight: FontWeight.w600),
                      )),
                      DataCell(
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: screenWidth * 0.35),
                          child: Text(item.des ?? "", overflow: TextOverflow.ellipsis),
                        ),
                      ),
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: _loading
                              ? null
                              : () => Get.bottomSheet(
                            SafeArea(child: _editPrice(item)),
                            isScrollControlled: true,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),

          ],
        ),
      ),
    );
  }
  Widget _itemImageCell(CatalogItemModel item, double size) {
    final p = (item.path ?? "").trim();

    if (p.isEmpty) {
      return Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.image_not_supported, size: 20, color: Colors.grey),
      );
    }

    final isNet = p.startsWith("http");

    return InkWell(
      onTap: () {
        if (isNet) {
          Get.to(() => ViewImage(p), transition: Transition.fadeIn, duration: const Duration(milliseconds: 250));
        } else {
          // Get.to(() => LocalImageView(p));
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: size,
          height: size,
          color: Colors.grey[200],
          child: isNet
              ? Image.network(
            p,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Center(
              child: Icon(Icons.broken_image, size: 22, color: Colors.grey),
            ),
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const Center(
                child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
              );
            },
          )
              : Image.file(
            File(p),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Center(
              child: Icon(Icons.broken_image, size: 22, color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  }

  Widget _editPrice(CatalogItemModel item) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final priceCtrl = TextEditingController(text: item.price);

    bool saving = false;

    return StatefulBuilder(
      builder: (ctx, setLocal) {
        void setSaving(bool v) => setLocal(() => saving = v);

        void closeSheet() {
          if (Navigator.of(ctx).canPop()) {
            Navigator.of(ctx).pop();
          }
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Edit Price".tr,
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: saving ? null : closeSheet,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              TextFormField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Price".tr,
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: screenHeight * 0.06,
                child: ElevatedButton(
                  onPressed: saving
                      ? null
                      : () async {
                    try {
                      final newPrice = double.tryParse(priceCtrl.text.trim()) ?? 0;
                      if (newPrice <= 0) {
                        showAppSnack("الرجاء إدخال سعر صحيح".tr, error: true);
                        return;
                      }

                      setSaving(true);

                      await _updateItemPriceSafely(item, newPrice);

                      final idx = _items.indexOf(item);
                      if (idx != -1) {
                        _safeSet(() => _items[idx].price = newPrice.toString());
                      }

                      await _recalcTotalsAndUpdateReq();

                      closeSheet();

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        showAppSnack("تم حفظ السعر بنجاح".tr);
                      });
                    } catch (e) {
                      showAppSnack("حدث خطأ أثناء حفظ السعر".tr, error: true);
                    } finally {
                      setSaving(false);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCE232B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: saving
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : Text(
                    "Save".tr,
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }


  Widget _buildDesignCard(BuildContext context, double screenWidth) {
    final req = _orderModel.req!;
    final hasDesign = req.des.isNotEmpty;

    final statusText = hasDesign ? "Design Attached".tr : "No Design Provided".tr;
    final statusColor = hasDesign ? const Color(0xFF07933E) : const Color(0xFFCE232B);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 6)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.palette, color: Color(0xFFCE232B)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Special Design".tr,
                    style: TextStyle(fontSize: screenWidth * 0.048, fontWeight: FontWeight.bold, color: const Color(0xFFCE232B)),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(10)),
                  child: Text(statusText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Divider(color: Colors.grey.withOpacity(0.2), height: 1),
            const SizedBox(height: 10),

            if (hasDesign)
              SizedBox(
                height: screenWidth * 0.32,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: req.des.length,
                  itemBuilder: (context, index) {
                    final url = req.des[index];
                    return InkWell(
                      onTap: () {
                        Get.to(
                              () => ViewImage(url),
                          duration: const Duration(milliseconds: 350),
                          transition: Transition.fadeIn,
                        );
                      },
                      child: Container(
                        width: screenWidth * 0.28,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 6, offset: const Offset(0, 3)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 12),
            Text(
              "${"Notes".tr}: ${req.notes}",
              style: TextStyle(fontSize: screenWidth * 0.038, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text('Note'.tr, style: const TextStyle(color: Color(0xFFCE232B), fontWeight: FontWeight.bold)),
          content: Text("Are You Sure Delete This Order".tr),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Cancel".tr)),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text("Delete".tr, style: const TextStyle(color: Color(0xFF07933E), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );

    if (ok != true) return;

    try {
      _safeSet(() => _deleting = true);

      await _firestore.collection('req').doc(_orderModel.req!.doc).update({"status": "reject"});

      showAppSnack("تم حذف الطلب".tr);

      if (mounted) _safeBack();
    } catch (_) {
      showAppSnack("فشل حذف الطلب".tr, error: true);
    } finally {
      _safeSet(() => _deleting = false);
    }
  }
}
