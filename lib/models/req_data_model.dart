import 'package:cloud_firestore/cloud_firestore.dart';
import 'catalog_item_model.dart';

class ReqDataModel {
  String doc;
  String address;
  String createby;
  String? createname;
  String date;
  String deposite;
  String design;
  String fees;
  String float;
  String hour;
  String name;
  String notes;
  String ownerOfevent;
  String? orderNumber;
  String? invoiceNumber;
  String? eventName;
  String? requestDate;
  String? createdAt;
  String phone;
  String status;
  String total;
  String typeby;
  String typeOfBuilding;
  String typeOfEvent;
  String typebank;
  String branch;

  List<String> des;
  List<CatalogItemModel> item;

  String? task;
  String? taskstatus;

  String? jobOrderNumber;
  int? jobNoInt;

  ReqDataModel({
    required this.doc,
    required this.name,
    required this.fees,
    required this.total,
    required this.des,
    required this.item,
    required this.float,
    required this.address,
    required this.date,
    required this.hour,
    required this.phone,
    required this.createby,
    this.createname,
    required this.deposite,
    required this.design,
    required this.notes,
    required this.ownerOfevent,
    required this.status,
    required this.typeby,
    required this.typeOfBuilding,
    required this.typeOfEvent,
    required this.branch,
    required this.typebank,
    this.orderNumber,
    this.invoiceNumber,
    this.eventName,
    this.requestDate,
    this.createdAt,
    this.task,
    this.taskstatus,
    this.jobOrderNumber,
    this.jobNoInt,
  });

  static String _s(dynamic v, {String def = ""}) {
    if (v == null) return def;
    return v.toString();
  }

  static String formatOrderNumber(dynamic raw) {
    final value = raw?.toString().trim() ?? "";
    if (value.isEmpty) return "";
    final parsed = int.tryParse(value);
    if (parsed == null) return value;
    return parsed.toString().padLeft(6, '0');
  }

  String canonicalOrderNumber() {
    final invoice = (invoiceNumber ?? "").trim();
    if (invoice.isNotEmpty) return formatOrderNumber(invoice);
    return formatOrderNumber(orderNumber ?? "");
  }

  String get canonicalNumber => canonicalOrderNumber();

  String displayTitleName({String fallback = "-"}) {
    final clientName = name.trim();
    return clientName.isNotEmpty ? clientName : fallback;
  }

  static String normalizeDate(dynamic v) {
    if (v == null) return "";
    if (v is Timestamp) return v.toDate().toIso8601String();
    if (v is DateTime) return v.toIso8601String();
    if (v is num) return DateTime.fromMillisecondsSinceEpoch(v.toInt()).toIso8601String();
    return v.toString();
  }

  static String _numStr(dynamic v, {String def = "0"}) {
    if (v == null) return def;
    if (v is num) return v.toString();
    final s = v.toString().trim();
    return (num.tryParse(s) ?? 0).toString();
  }

  static int? _int(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString().trim());
  }

  static String? _nullableStr(dynamic v) {
    final s = _s(v, def: "").trim();
    return s.isEmpty ? null : s;
  }

  factory ReqDataModel.fromMap({
    required String docId,
    required Map<String, dynamic> data,
  }) {
    String deposit = "0";
    if (data.containsKey('deposit')) deposit = _numStr(data['deposit']);
    if ((deposit == "0" || deposit.isEmpty) && data.containsKey('deposite')) {
      deposit = _numStr(data['deposite']);
    }

    String design = "";
    if (data.containsKey('design')) design = _s(data['design']);
    if (design.isEmpty && data.containsKey('desgin')) design = _s(data['desgin']);

    final desList = <String>[];
    final rawDes = data['des'];
    if (rawDes is List) {
      for (final v in rawDes) {
        final s = _s(v).trim();
        if (s.isNotEmpty) desList.add(s);
      }
    }

    final items = <CatalogItemModel>[];
    final rawItems = data['item'];
    if (rawItems is List) {
      for (final v in rawItems) {
        if (v is Map<String, dynamic>) {
          try {
            final it = CatalogItemModel(
              doc: _s(v['doc']),
              name: _s(v['name']),
              path: _s(v['path']),
              des: _s(v['notes']),
              price: _s(v['price'], def: "0"),
            );
            it.count = _int(v['count']) ?? 0;
            items.add(it);
          } catch (_) {}
        }
      }
    }

    final orderNumber = _nullableStr(data['orderNumber']) ??
        _nullableStr(data['ordernumber']) ??
        _nullableStr(data['order_number']);

    final invoiceNumber = _nullableStr(data['invoiceNumber']) ?? _nullableStr(data['invoice_number']);

    final requestDate = _nullableStr(normalizeDate(data['requestDate'])) ??
        _nullableStr(normalizeDate(data['request_date']));
    final eventName = _nullableStr(data['eventName']) ?? _nullableStr(data['event_name']);
    final createdAt = _nullableStr(normalizeDate(data['createdAt']));

    final jobOrderNumber = _nullableStr(data['jobOrderNumber']);

    final jobNoInt = _int(data['jobNoInt']);

    return ReqDataModel(
      doc: docId,
      name: _s(data['name']),
      fees: _numStr(data['fees']),
      total: _numStr(data['total']),
      des: desList,
      item: items,
      float: _numStr(data['float']),
      address: _s(data['address']),
      date: normalizeDate(data['date']),
      hour: _s(data['hour']),
      phone: _s(data['phone']),
      createby: _s(data['createby']),
      createname: _nullableStr(data['createname']),
      deposite: deposit,
      design: design,
      notes: _s(data['notes']),
      ownerOfevent: _s(data['ownerofevent']),
      status: _s(data['status']),
      typeby: _s(data['typeCreate']),
      typeOfBuilding: _s(data['typeofbuilding']),
      typeOfEvent: _s(data['typeofevent']),
      branch: _s(data['branch']),
      typebank: _s(data['banktype']),
      orderNumber: orderNumber,
      invoiceNumber: invoiceNumber,
      eventName: eventName,
      requestDate: requestDate,
      createdAt: createdAt,
      task: _nullableStr(data['task']),
      taskstatus: _nullableStr(data['taskstatus']),
      jobOrderNumber: jobOrderNumber,
      jobNoInt: jobNoInt,
    );
  }

  factory ReqDataModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return ReqDataModel.fromMap(
      docId: doc.id,
      data: doc.data() ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'fees': fees,
      'total': total,
      'float': float,
      'address': address,
      'date': date,
      'hour': hour,
      'phone': phone,

      'createby': createby,
      'createname': createname,

      'deposit': deposite,
      'desgin': design,
      'notes': notes,
      'ownerofevent': ownerOfevent,

      'status': status,
      'typeCreate': typeby,
      'typeofbuilding': typeOfBuilding,
      'typeofevent': typeOfEvent,
      'branch': branch,
      'banktype': typebank,

      'orderNumber': orderNumber,
      'invoiceNumber': invoiceNumber,
      'eventName': eventName,
      'requestDate': requestDate,
      'createdAt': createdAt,

      'task': task,
      'taskstatus': taskstatus,

      'ordernumber': jobOrderNumber,
      'jobNoInt': jobNoInt,

      // اختياري
      'des': des,
    };
  }

  ReqDataModel copyWith({
    String? doc,
    String? address,
    String? createby,
    String? createname,
    String? date,
    String? deposite,
    String? design,
    String? fees,
    String? float,
    String? hour,
    String? name,
    String? notes,
    String? ownerOfevent,
    String? orderNumber,
    String? invoiceNumber,
    String? eventName,
    String? requestDate,
    String? createdAt,
    String? phone,
    String? status,
    String? total,
    String? typeby,
    String? typeOfBuilding,
    String? typeOfEvent,
    List<String>? des,
    List<CatalogItemModel>? item,
    String? typebank,
    String? branch,
    String? task,
    String? taskstatus,
    String? jobOrderNumber,
    int? jobNoInt,
  }) {
    return ReqDataModel(
      doc: doc ?? this.doc,
      name: name ?? this.name,
      fees: fees ?? this.fees,
      total: total ?? this.total,
      des: des ?? List<String>.from(this.des),
      item: item ?? List<CatalogItemModel>.from(this.item),
      float: float ?? this.float,
      address: address ?? this.address,
      date: date ?? this.date,
      hour: hour ?? this.hour,
      phone: phone ?? this.phone,
      createby: createby ?? this.createby,
      createname: createname ?? this.createname,
      deposite: deposite ?? this.deposite,
      design: design ?? this.design,
      notes: notes ?? this.notes,
      ownerOfevent: ownerOfevent ?? this.ownerOfevent,
      status: status ?? this.status,
      typeby: typeby ?? this.typeby,
      typeOfBuilding: typeOfBuilding ?? this.typeOfBuilding,
      typeOfEvent: typeOfEvent ?? this.typeOfEvent,
      branch: branch ?? this.branch,
      typebank: typebank ?? this.typebank,
      orderNumber: orderNumber ?? this.orderNumber,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      eventName: eventName ?? this.eventName,
      requestDate: requestDate ?? this.requestDate,
      createdAt: createdAt ?? this.createdAt,
      task: task ?? this.task,
      taskstatus: taskstatus ?? this.taskstatus,
      jobOrderNumber: jobOrderNumber ?? this.jobOrderNumber,
      jobNoInt: jobNoInt ?? this.jobNoInt,
    );
  }
}
