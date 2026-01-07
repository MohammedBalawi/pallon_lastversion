import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../Core/Utils/app_snack.dart';
import '../../../Core/Utils/manager_fonts.dart';
import '../../../Core/Utils/local_image_provider.dart';
import '../../../Core/Widgets/image_view.dart';
import '../../../models/catalog_item_model.dart';
import '../../../models/order_model.dart';
import '../../../models/req_data_model.dart';
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
  bool _isEditing = false;
  bool _saving = false;

  static final Map<String, String> _creatorNameCache = {};
  String? _creatorNameOverride;

  String hourForm = "AM";
  int hour = 0;

  DateTime? _requestDateValue;
  DateTime? _dueDateValue;

  late TextEditingController _eventNameCtrl;
  late TextEditingController _clientNameCtrl;
  late TextEditingController _clientPhoneCtrl;
  late TextEditingController _ownerEventCtrl;
  late TextEditingController _orderNumberCtrl;
  late TextEditingController _invoiceNumberCtrl;
  late TextEditingController _requestDateCtrl;
  late TextEditingController _dueDateCtrl;
  late TextEditingController _eventTypeCtrl;
  late TextEditingController _receivingCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _typeOfBuildingCtrl;
  late TextEditingController _floatCtrl;
  late TextEditingController _paymentMethodCtrl;
  late TextEditingController _statusCtrl;
  late TextEditingController _totalCtrl;
  late TextEditingController _depositCtrl;
  late TextEditingController _feesCtrl;

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
    _initControllers();
    _loadCreatorName();

    _computeHourFromDocSafe();
    _getUserType();
    _loadStaffAndReqData();
  }

  @override
  void dispose() {
    _eventNameCtrl.dispose();
    _clientNameCtrl.dispose();
    _clientPhoneCtrl.dispose();
    _ownerEventCtrl.dispose();
    _orderNumberCtrl.dispose();
    _invoiceNumberCtrl.dispose();
    _requestDateCtrl.dispose();
    _dueDateCtrl.dispose();
    _eventTypeCtrl.dispose();
    _receivingCtrl.dispose();
    _addressCtrl.dispose();
    _typeOfBuildingCtrl.dispose();
    _floatCtrl.dispose();
    _paymentMethodCtrl.dispose();
    _statusCtrl.dispose();
    _totalCtrl.dispose();
    _depositCtrl.dispose();
    _feesCtrl.dispose();
    super.dispose();
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

  String _resolveCreatorNameFallback() {
    final req = _orderModel.req;
    if (req == null) return "-";
    final fromReq = (req.createname ?? "").trim();
    if (fromReq.isNotEmpty) return fromReq;
    final fromOverride = (_creatorNameOverride ?? "").trim();
    if (fromOverride.isNotEmpty) return fromOverride;
    final fromUser = _orderModel.createby?.name ?? "";
    if (fromUser.trim().isNotEmpty) return fromUser.trim();
    return "-";
  }

  String _resolveEventNameDisplay() {
    final req = _orderModel.req;
    if (req == null) return "-";
    final eventName = (req.eventName ?? "").trim();
    if (eventName.isNotEmpty) return eventName;
    return _resolveCreatorNameFallback();
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

  DateTime? _resolveRequestDateValue() {
    final req = _orderModel.req;
    if (req == null) return null;

    final fromField = _parseDateValue(req.requestDate);
    if (fromField != null) return fromField;

    final fromCreatedAt = _parseDateValue(req.createdAt);
    if (fromCreatedAt != null) return fromCreatedAt;

    final raw = req.doc;
    if (raw.contains("Doc")) {
      final dt = DateTime.tryParse(raw.split("Doc").last);
      if (dt != null) return dt;
    }

    return null;
  }

  String _formatDate(DateTime? value) {
    if (value == null) return "-";
    final locale = Get.locale?.languageCode ?? Intl.getCurrentLocale();
    return DateFormat.yMMMd(locale).format(value);
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) return "-";
    final locale = Get.locale?.languageCode ?? Intl.getCurrentLocale();
    final date = DateFormat.yMMMd(locale).format(value);
    final time = DateFormat.jm(locale).format(value);
    return "$date • $time";
  }

  String _formatCurrency(String? raw) {
    final value = double.tryParse((raw ?? "").trim()) ?? 0;
    final locale = Get.locale?.languageCode ?? Intl.getCurrentLocale();
    return NumberFormat.currency(locale: locale, symbol: "SAR").format(value);
  }

  void _initControllers() {
    final req = _orderModel.req;
    if (req == null) {
      _eventNameCtrl = TextEditingController();
      _clientNameCtrl = TextEditingController();
      _clientPhoneCtrl = TextEditingController();
      _ownerEventCtrl = TextEditingController();
      _orderNumberCtrl = TextEditingController();
      _invoiceNumberCtrl = TextEditingController();
      _requestDateCtrl = TextEditingController();
      _dueDateCtrl = TextEditingController();
      _eventTypeCtrl = TextEditingController();
      _receivingCtrl = TextEditingController();
      _addressCtrl = TextEditingController();
      _typeOfBuildingCtrl = TextEditingController();
      _floatCtrl = TextEditingController();
      _paymentMethodCtrl = TextEditingController();
      _statusCtrl = TextEditingController();
      _totalCtrl = TextEditingController();
      _depositCtrl = TextEditingController();
      _feesCtrl = TextEditingController();
      return;
    }

    _requestDateValue = _resolveRequestDateValue();
    _dueDateValue = _parseDateValue(req.date);

    final eventName = (req.eventName ?? "").trim();
    final canonicalOrderNumber = req.canonicalOrderNumber();

    _eventNameCtrl = TextEditingController(text: eventName);
    _clientNameCtrl = TextEditingController(text: req.name);
    _clientPhoneCtrl = TextEditingController(text: req.phone);
    _ownerEventCtrl = TextEditingController(text: req.ownerOfevent);
    _orderNumberCtrl = TextEditingController(text: canonicalOrderNumber);
    _invoiceNumberCtrl = TextEditingController(text: canonicalOrderNumber);
    final requestDateText =
        _requestDateValue != null ? _formatDateTime(_requestDateValue) : (req.requestDate ?? "-");
    final dueDateText = _dueDateValue != null ? _formatDate(_dueDateValue) : (req.date.isEmpty ? "-" : req.date);

    _requestDateCtrl = TextEditingController(text: requestDateText);
    _dueDateCtrl = TextEditingController(text: dueDateText);
    _eventTypeCtrl = TextEditingController(text: req.typeOfEvent);
    _receivingCtrl = TextEditingController(text: req.branch);
    _addressCtrl = TextEditingController(text: req.address);
    _typeOfBuildingCtrl = TextEditingController(text: req.typeOfBuilding);
    _floatCtrl = TextEditingController(text: req.float);
    _paymentMethodCtrl = TextEditingController(text: req.typebank);
    _statusCtrl = TextEditingController(text: req.status);
    _totalCtrl = TextEditingController(text: req.total);
    _depositCtrl = TextEditingController(text: req.deposite);
    _feesCtrl = TextEditingController(text: req.fees);
  }

  void _syncControllersFromModel() {
    if (_isEditing) return;
    final req = _orderModel.req;
    if (req == null) return;

    _requestDateValue = _resolveRequestDateValue();
    _dueDateValue = _parseDateValue(req.date);

    final eventName = (req.eventName ?? "").trim();
    final canonicalOrderNumber = req.canonicalOrderNumber();

    _eventNameCtrl.text = eventName;
    _clientNameCtrl.text = req.name;
    _clientPhoneCtrl.text = req.phone;
    _ownerEventCtrl.text = req.ownerOfevent;
    _orderNumberCtrl.text = canonicalOrderNumber;
    _invoiceNumberCtrl.text = canonicalOrderNumber;
    _requestDateCtrl.text =
        _requestDateValue != null ? _formatDateTime(_requestDateValue) : (req.requestDate ?? "-");
    _dueDateCtrl.text = _dueDateValue != null ? _formatDate(_dueDateValue) : (req.date.isEmpty ? "-" : req.date);
    _eventTypeCtrl.text = req.typeOfEvent;
    _receivingCtrl.text = req.branch;
    _addressCtrl.text = req.address;
    _typeOfBuildingCtrl.text = req.typeOfBuilding;
    _floatCtrl.text = req.float;
    _paymentMethodCtrl.text = req.typebank;
    _statusCtrl.text = req.status;
    _totalCtrl.text = req.total;
    _depositCtrl.text = req.deposite;
    _feesCtrl.text = req.fees;
  }

  Future<void> _loadCreatorName() async {
    final req = _orderModel.req;
    if (req == null) return;
    final uid = req.createby.trim();
    if (uid.isEmpty) return;
    if ((req.createname ?? "").trim().isNotEmpty) return;

    final cached = _creatorNameCache[uid];
    if (cached != null && cached.trim().isNotEmpty) {
      _safeSet(() => _creatorNameOverride = cached);
      return;
    }

    try {
      final doc = await _firestore.collection('user').doc(uid).get();
      final data = doc.data() ?? {};
      final name = (data['name'] ?? '').toString().trim();
      if (name.isEmpty) return;
      _creatorNameCache[uid] = name;
      _safeSet(() => _creatorNameOverride = name);
    } catch (_) {}
  }

  Future<void> _pickDate({
    required TextEditingController controller,
    required DateTime? current,
    required ValueChanged<DateTime> onPicked,
  }) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: Get.locale,
    );

    if (picked == null) return;
    onPicked(picked);
    controller.text = _formatDate(picked);
  }

  Future<void> _saveEdits() async {
    if (_saving) return;

    final req = _orderModel.req;
    if (req == null) return;

    final reqDocId = req.doc.trim();
    if (reqDocId.isEmpty) {
      showAppSnack("update_failed".tr, error: true);
      return;
    }

    _safeSet(() => _saving = true);

    final requestDateValue = _requestDateValue?.toIso8601String() ?? _requestDateCtrl.text.trim();
    final dueDateValue = _dueDateValue?.toIso8601String() ?? _dueDateCtrl.text.trim();
    final orderNumberInput = _orderNumberCtrl.text.trim();
    final invoiceNumberInput = _invoiceNumberCtrl.text.trim();
    final canonicalInput = invoiceNumberInput.isNotEmpty ? invoiceNumberInput : orderNumberInput;
    final canonicalNumber = ReqDataModel.formatOrderNumber(canonicalInput);

    final updates = <String, dynamic>{
      'eventName': _eventNameCtrl.text.trim(),
      'name': _clientNameCtrl.text.trim(),
      'phone': _clientPhoneCtrl.text.trim(),
      'ownerofevent': _ownerEventCtrl.text.trim(),
      'orderNumber': canonicalNumber,
      'ordernumber': canonicalNumber,
      'invoiceNumber': canonicalNumber,
      'requestDate': requestDateValue,
      'date': dueDateValue,
      'branch': _receivingCtrl.text.trim(),
      'address': _addressCtrl.text.trim(),
      'typeofbuilding': _typeOfBuildingCtrl.text.trim(),
      'float': _floatCtrl.text.trim(),
      'typeofevent': _eventTypeCtrl.text.trim(),
      'banktype': _paymentMethodCtrl.text.trim(),
      'status': _statusCtrl.text.trim(),
      'total': _totalCtrl.text.trim(),
      'deposite': _depositCtrl.text.trim(),
      'deposit': _depositCtrl.text.trim(),
      'fees': _feesCtrl.text.trim(),
    };

    final ok = await UpdateOrderDetails(reqDocId: reqDocId, data: updates);

    if (ok) {
      _safeSet(() {
        req.eventName = _eventNameCtrl.text.trim();
        req.name = _clientNameCtrl.text.trim();
        req.phone = _clientPhoneCtrl.text.trim();
        req.ownerOfevent = _ownerEventCtrl.text.trim();
        req.orderNumber = canonicalNumber;
        req.invoiceNumber = canonicalNumber;
        req.requestDate = requestDateValue;
        req.date = dueDateValue;
        req.branch = _receivingCtrl.text.trim();
        req.address = _addressCtrl.text.trim();
        req.typeOfBuilding = _typeOfBuildingCtrl.text.trim();
        req.float = _floatCtrl.text.trim();
        req.typeOfEvent = _eventTypeCtrl.text.trim();
        req.typebank = _paymentMethodCtrl.text.trim();
        req.status = _statusCtrl.text.trim();
        req.total = _totalCtrl.text.trim();
        req.deposite = _depositCtrl.text.trim();
        req.fees = _feesCtrl.text.trim();
        _orderNumberCtrl.text = canonicalNumber;
        _invoiceNumberCtrl.text = canonicalNumber;
        _isEditing = false;
      });
      showAppSnack("update_success".tr);
    } else {
      showAppSnack("update_failed".tr, error: true);
    }

    _safeSet(() => _saving = false);
  }

  void _cancelEdits() {
    _syncControllersFromModel();
    _safeSet(() => _isEditing = false);
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
      _syncControllersFromModel();
      _loadCreatorName();
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
    final canonicalOrderNumber = req.canonicalOrderNumber();
    final invoiceDisplay = canonicalOrderNumber.trim().isEmpty ? "-" : canonicalOrderNumber;
    final dueDateDisplay = _safeDueDateText(req.date);

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

              _buildEditActions(context),
              SizedBox(height: screenHeight * 0.015),

              _isEditing
                  ? _buildEditableCard(
                      context,
                      title: "client_request_details".tr,
                      icon: Icons.person,
                      children: [
                        _buildEditableRow(
                          label: "request_date".tr,
                          controller: _requestDateCtrl,
                          readOnly: true,
                          onTap: () => _pickDate(
                            controller: _requestDateCtrl,
                            current: _requestDateValue,
                            onPicked: (v) => _requestDateValue = v,
                          ),
                        ),
                        _buildEditableRow(
                          label: "event_name".tr,
                          controller: _eventNameCtrl,
                        ),
                        _buildEditableRow(
                          label: "client_actual".tr,
                          controller: _clientNameCtrl,
                        ),
                        _buildEditableRow(
                          label: "client_phone".tr,
                          controller: _clientPhoneCtrl,
                          keyboardType: TextInputType.phone,
                        ),
                        _buildEditableRow(
                          label: "owner_of_event".tr,
                          controller: _ownerEventCtrl,
                        ),
                        _buildEditableRow(
                          label: "order_number".tr,
                          controller: _orderNumberCtrl,
                        ),
                        _buildEditableRow(
                          label: "invoice_number".tr,
                          controller: _invoiceNumberCtrl,
                        ),
                        _buildEditableRow(
                          label: "status".tr,
                          controller: _statusCtrl,
                        ),
                      ],
                    )
                  : _buildInfoCard(
                      context,
                      title: "client_request_details".tr,
                      icon: Icons.person,
                      data: {
                        'request_date'.tr: _safeReqDateText(),
                        'event_name'.tr: _resolveEventNameDisplay(),
                        'client_actual'.tr: req.name,
                        'client_phone'.tr: req.phone,
                        'owner_of_event'.tr: req.ownerOfevent,
                        'order_number'.tr: invoiceDisplay,
                        'invoice_number'.tr: invoiceDisplay,
                        'status'.tr: req.status,
                      },
                    ),
              SizedBox(height: screenHeight * 0.015),

              _isEditing
                  ? _buildEditableCard(
                      context,
                      title: "event_location".tr,
                      icon: Icons.location_on,
                      children: [
                        _buildEditableRow(
                          label: "Event Type".tr,
                          controller: _eventTypeCtrl,
                        ),
                        _buildEditableRow(
                          label: "owner_of_event".tr,
                          controller: _ownerEventCtrl,
                        ),
                        _buildEditableRow(
                          label: "receiving".tr,
                          controller: _receivingCtrl,
                        ),
                        _buildEditableRow(
                          label: "due_date".tr,
                          controller: _dueDateCtrl,
                          readOnly: true,
                          onTap: () => _pickDate(
                            controller: _dueDateCtrl,
                            current: _dueDateValue,
                            onPicked: (v) => _dueDateValue = v,
                          ),
                        ),
                        _buildEditableRow(
                          label: "address".tr,
                          controller: _addressCtrl,
                          maxLines: 2,
                        ),
                        _buildEditableRow(
                          label: "Type Of Building".tr,
                          controller: _typeOfBuildingCtrl,
                        ),
                        _buildEditableRow(
                          label: "Float".tr,
                          controller: _floatCtrl,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    )
                  : _buildInfoCard(
                      context,
                      title: "event_location".tr,
                      icon: Icons.location_on,
                      data: {
                        'Event Type'.tr: req.typeOfEvent,
                        'owner_of_event'.tr: req.ownerOfevent,
                        'receiving'.tr: req.branch,
                        'due_date'.tr: dueDateDisplay,
                        'address'.tr: req.address,
                        'Type Of Building'.tr: req.typeOfBuilding,
                        'Float'.tr: req.float,
                      },
                    ),
              SizedBox(height: screenHeight * 0.015),

              _isEditing
                  ? _buildEditableCard(
                      context,
                      title: "payment_summary".tr,
                      icon: Icons.payments,
                      children: [
                        _buildEditableRow(
                          label: "payment_method".tr,
                          controller: _paymentMethodCtrl,
                        ),
                        _buildEditableRow(
                          label: "Total Price".tr,
                          controller: _totalCtrl,
                          keyboardType: TextInputType.number,
                        ),
                        _buildEditableRow(
                          label: "Deposit".tr,
                          controller: _depositCtrl,
                          keyboardType: TextInputType.number,
                        ),
                        _buildEditableRow(
                          label: "Remaining Fees".tr,
                          controller: _feesCtrl,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    )
                  : _buildInfoCard(
                      context,
                      title: "payment_summary".tr,
                      icon: Icons.payments,
                      data: {
                        'payment_method'.tr: req.typebank,
                        'Total Price'.tr: _formatCurrency(req.total),
                        'Deposit'.tr: _formatCurrency(req.deposite),
                        'Remaining Fees'.tr: _formatCurrency(req.fees),
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

      floatingActionButton: (userModel.type == "Admin" && !_loading && !_isEditing)
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
    final headerTitle = req.displayTitleName(fallback: "no_name".tr);

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
                  headerTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  "${"receiving".tr}: ${req.branch} • ${"payment_method".tr}: ${req.typebank}",
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
    final value = _requestDateValue ?? _resolveRequestDateValue();
    if (value != null) return _formatDateTime(value);
    final raw = _orderModel.req?.requestDate ?? "";
    if (raw.trim().isEmpty) {
      final created = _orderModel.req?.createdAt ?? "";
      return created.trim().isEmpty ? "-" : created.trim();
    }
    return raw.trim().isEmpty ? "-" : raw.trim();
  }

  String _safeDueDateText(String raw) {
    final parsed = _parseDateValue(raw);
    if (parsed != null) return _formatDate(parsed);
    return raw.trim().isEmpty ? "-" : raw.trim();
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

  Widget _buildEditableCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
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
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildEditableRow({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: screenWidth * 0.38,
            child: Text(
              "$label:",
              style: TextStyle(
                fontSize: screenWidth * 0.038,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              maxLines: maxLines,
              readOnly: readOnly,
              onTap: onTap,
              textAlign: TextAlign.end,
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditActions(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (!_isEditing) {
      return SizedBox(
        width: double.infinity,
        height: screenWidth * 0.12,
        child: ElevatedButton.icon(
          onPressed: _loading ? null : () => _safeSet(() => _isEditing = true),
          icon: const Icon(Icons.edit_outlined, color: Colors.white),
          label: Text(
            "edit".tr,
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF07933E),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: screenWidth * 0.12,
            child: ElevatedButton(
              onPressed: (_saving || _loading) ? null : _saveEdits,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF07933E),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _saving
                  ?  SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text("save".tr,style: TextStyle(
                color: Colors.white,
                fontFamily: ManagerFontFamily.fontFamily

              ),),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: screenWidth * 0.12,
            child: OutlinedButton(
              onPressed: (_saving || _loading) ? null : _cancelEdits,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFCE232B)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                "cancel".tr,
                style: const TextStyle(color: Color(0xFFCE232B)),
              ),
            ),
          ),
        ),
      ],
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
                        _formatCurrency(item.price),
                        style: const TextStyle(color: Color(0xFF07933E), fontWeight: FontWeight.w600),
                      )),
                      DataCell(Text(
                        "${item.count}",
                        style: const TextStyle(color: Color(0xFF07933E), fontWeight: FontWeight.w600),
                      )),
                      DataCell(Text(
                        _formatCurrency(total.toStringAsFixed(2)),
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
              : Image(
            image: localImageProvider(p),
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
