import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../Core/Widgets/common_widgets.dart';
import '../../../models/catalog_item_model.dart';
import '../../../models/catalog_model.dart';
import '../../../models/req_data_model.dart';
import '../../../models/req_model.dart';
import '../../../models/sub_cat_model.dart';
import '../../../models/sub_sub_cat.dart';
import '../../../models/user_model.dart';
import '../../Catalog/models/sub3_cat_model.dart';
import '../../MainScreen/function/main_function.dart';
import '../../Orders/widget/create_order_widget.dart';
import '../../Requset/functions/req_functions.dart';


final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final FirebaseAuth _auth = FirebaseAuth.instance;

Future<String?> _uploadLocalImage(String path) async {
  final p = path.trim();
  if (p.isEmpty) return null;

  final user = _auth.currentUser;
  if (user == null) return null;

  final file = File(p);
  if (!file.existsSync()) return null;

  final storagePath = "user/photos/${user.uid}-${DateTime.now().millisecondsSinceEpoch}.jpg";
  final ref = FirebaseStorage.instance.ref().child(storagePath);

  final snap = await ref.putFile(file);
  return await snap.ref.getDownloadURL();
}

Future<int> _getNextReqNumber() async {
  final counterRef = _firestore.collection('counters').doc('req');

  return _firestore.runTransaction<int>((tx) async {
    final snap = await tx.get(counterRef);

    int next;
    if (!snap.exists) {
      next = 1;
      tx.set(counterRef, {'next': 2});
    } else {
      final data = snap.data() as Map<String, dynamic>;
      next = (data['next'] ?? 1) as int;
      tx.update(counterRef, {'next': next + 1});
    }
    return next;
  });
}

Future<void> resetReqOrderCounter({
  int next = 0,
  bool resetLegacyConst = false,
}) async {
  if (kReleaseMode) return;
  final counterRef = _firestore.collection('counters').doc('req');
  await counterRef.set({'next': next}, SetOptions(merge: true));

  if (resetLegacyConst) {
    await _firestore.collection('const').doc("qaJdz7K1kwuKQLWlSHdG").update({
      "ordernumber": (next - 1).toString(),
    });
  }
}

Future<List<CatalogItemModel>> _ensureItemsHaveUrls(List<CatalogItemModel> items) async {
  final results = <CatalogItemModel>[];

  for (final it in items) {
    String url = (it.path).trim();

    if (url.isNotEmpty && url.startsWith("http")) {
      results.add(it);
      continue;
    }

    final uploaded = await _uploadLocalImage(url);
    final newUrl = uploaded ?? "";

    final updated = CatalogItemModel(
      doc: it.doc,
      name: it.name,
      path: newUrl,
      des: it.des,
      price: it.price,
    )..count = it.count;

    results.add(updated);
  }

  return results;
}

ReqDataModel _reqDataFromSnap(DocumentSnapshot<Map<String, dynamic>> value) {
  final data = value.data() ?? {};

  final reqq = ReqDataModel(
    doc: value.id,
    name: (data['name'] ?? "").toString(),
    fees: (data['fees'] ?? "").toString(),
    total: (data['total'] ?? "").toString(),
    des: [],
    item: [],
    float: (data['float'] ?? "").toString(),
    address: (data['address'] ?? "").toString(),
    date: ReqDataModel.normalizeDate(data['date']),
    hour: (data['hour'] ?? "").toString(),
    phone: (data['phone'] ?? "").toString(),
    createby: (data['createby'] ?? "").toString(),
    createname: (data['createname'] ?? "").toString().trim().isEmpty
        ? null
        : (data['createname'] ?? "").toString(),
    deposite: (data['deposit'] ?? data['deposite'] ?? "").toString(),
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

  reqq.orderNumber = (data['ordernumber'] ?? data['orderNumber'] ?? "").toString();
  reqq.task = (data['task'] ?? "").toString();

  reqq.jobOrderNumber = (data['jobOrderNumber'] ?? "").toString().trim().isEmpty
      ? null
      : (data['jobOrderNumber'] ?? "").toString();

  reqq.jobNoInt = data['jobNoInt'] is int
      ? data['jobNoInt'] as int
      : int.tryParse("${data['jobNoInt']}");

  return reqq;
}

Future<List<Catalog>> GetFullCatalogTree() async {
  final catsSnap = await _firestore.collection('Catalog').get();
  final cats = <Catalog>[];

  for (final cDoc in catsSnap.docs) {
    final cData = cDoc.data();
    final cat = Catalog(
      doc: cDoc.id,
      cat: (cData['cat'] ?? '').toString(),
      pic: (cData['pic'] ?? '').toString(),
    );

    final subSnap = await _firestore.collection('Catalog').doc(cat.doc).collection('sub').get();
    cat.sub = subSnap.docs.map((sDoc) {
      final sData = sDoc.data();
      return SubCatModel(
        doc: sDoc.id,
        sub: (sData['sub'] ?? '').toString(),
        pic: (sData['pic'] ?? '').toString(),
      );
    }).toList();

    for (final sub in cat.sub) {
      final subSubSnap = await _firestore
          .collection('Catalog')
          .doc(cat.doc)
          .collection('sub')
          .doc(sub.doc)
          .collection('subsub')
          .get();

      sub.subsub = subSubSnap.docs.map((ssDoc) {
        final ssData = ssDoc.data();
        return SubSubCatModel(
          doc: ssDoc.id,
          subsub: (ssData['subsub'] ?? '').toString(),
          pic: (ssData['pic'] ?? '').toString(),
        );
      }).toList();

      for (final subsub in sub.subsub) {
        final subSubItemsSnap = await _firestore
            .collection('Catalog')
            .doc(cat.doc)
            .collection('sub')
            .doc(sub.doc)
            .collection('subsub')
            .doc(subsub.doc)
            .collection('item')
            .get();

        subsub.items = subSubItemsSnap.docs.map((d) {
          final data = d.data();
          return CatalogItemModel(
            doc: d.id,
            name: (data['name'] ?? '').toString(),
            path: (data['path'] ?? '').toString(),
            des: (data['des'] ?? data['notes'] ?? '').toString(),
            price: (data['price'] ?? '0').toString(),
          );
        }).toList();

        final sub3Snap = await _firestore
            .collection('Catalog')
            .doc(cat.doc)
            .collection('sub')
            .doc(sub.doc)
            .collection('subsub')
            .doc(subsub.doc)
            .collection('sub3')
            .get();

        subsub.sub3 = sub3Snap.docs.map((s3Doc) {
          final data = s3Doc.data();
          return Sub3CatModel(
            doc: s3Doc.id,
            name: (data['name'] ?? '').toString(),
            pic: (data['pic'] ?? '').toString(),
          );
        }).toList();

        for (final s3 in subsub.sub3) {
          final sub3ItemsSnap = await _firestore
              .collection('Catalog')
              .doc(cat.doc)
              .collection('sub')
              .doc(sub.doc)
              .collection('subsub')
              .doc(subsub.doc)
              .collection('sub3')
              .doc(s3.doc)
              .collection('item')
              .get();

          s3.items = sub3ItemsSnap.docs.map((d) {
            final data = d.data();
            return CatalogItemModel(
              doc: d.id,
              name: (data['name'] ?? '').toString(),
              path: (data['path'] ?? '').toString(),
              des: (data['des'] ?? data['notes'] ?? '').toString(),
              price: (data['price'] ?? '0').toString(),
            );
          }).toList();

          final sub4Snap = await _firestore
              .collection('Catalog')
              .doc(cat.doc)
              .collection('sub')
              .doc(sub.doc)
              .collection('subsub')
              .doc(subsub.doc)
              .collection('sub3')
              .doc(s3.doc)
              .collection('sub4')
              .get();

          s3.sub4 = sub4Snap.docs.map((s4Doc) {
            final data = s4Doc.data();
            return Sub4CatModel(
              doc: s4Doc.id,
              name: (data['name'] ?? '').toString(),
              pic: (data['pic'] ?? '').toString(),
            );
          }).toList();

          for (final s4 in s3.sub4) {
            final sub4ItemsSnap = await _firestore
                .collection('Catalog')
                .doc(cat.doc)
                .collection('sub')
                .doc(sub.doc)
                .collection('subsub')
                .doc(subsub.doc)
                .collection('sub3')
                .doc(s3.doc)
                .collection('sub4')
                .doc(s4.doc)
                .collection('item')
                .get();

            s4.items = sub4ItemsSnap.docs.map((d) {
              final data = d.data();
              return CatalogItemModel(
                doc: d.id,
                name: (data['name'] ?? '').toString(),
                path: (data['path'] ?? '').toString(),
                des: (data['des'] ?? data['notes'] ?? '').toString(),
                price: (data['price'] ?? '0').toString(),
              );
            }).toList();
          }
        }
      }
    }

    cats.add(cat);
  }

  return cats;
}

Future<void> Submit(
    BuildContext context,
    UserModel user,
    bool des,
    ReqModel req,
    List<CatalogItemModel> items,
    String notes,
    double deposit,
    double fees,
    double total,
    String branch,
    String bank,
    ) async {
  try {
    const String status = "order";

    final int reqNumber = await _getNextReqNumber();
    final String orderNumber = reqNumber.toString().padLeft(6, '0');
    final String docId = "REQ-$orderNumber";

    final fixedItems = await _ensureItemsHaveUrls(items);

    await _firestore.collection('req').doc(docId).set({
      'orderNumber': orderNumber,
      'ordernumber': orderNumber,
      'invoiceNumber': orderNumber,
      'orderNoInt': reqNumber,
      'createdAt': FieldValue.serverTimestamp(),

      'createDoc': _auth.currentUser?.uid ?? '',
      'createby': _auth.currentUser?.uid ?? '',
      'createname': user.name,
      'typeCreate': user.type,

      'status': status,

      'name': req.Name,
      'phone': req.Phone,
      'typeofevent': req.TypeOfEvent,
      'ownerofevent': req.OwnerOfEvent,
      'hour': req.Hour,
      'date': req.Date,
      'address': req.Address,
      'typeofbuilding': req.TypeOfBuilding,
      'float': req.Float,

      'desgin': des.toString(),
      'deposit': deposit.toString(),
      'total': total.toString(),
      'fees': fees.toString(),
      'notes': notes,
      'banktype': bank,
      'branch': branch,

      'task': 'designer',
      'taskstatus': '',
    });

    for (final it in fixedItems) {
      final docRef = _firestore.collection('req').doc(docId).collection('item').doc();
      await docRef.set({
        'doc': docRef.id,
        'name': it.name,
        'price': it.price.toString(),
        'notes': it.des,
        'path': it.path,
        'count': it.count.toString(),
      });
    }

    if (user.type == "client") {
      final admintoken = await GetAdminsToken(context);
      for (int j = 0; j < admintoken.length; j++) {
        sendNotification(admintoken[j], "New Req", "You Have New Req Created", "4");
      }
      Get.back();
      return;
    }

    final value = await _firestore.collection('req').doc(docId).get();
    final reqq = _reqDataFromSnap(value);

    Get.back();
    Get.to(
          () => CreateOrderWidget(reqq),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 500),
    );
  } catch (e) {
    showErrorDialog(context, e.toString());
  }
}

Future<void> Submit2(
    BuildContext context,
    UserModel user,
    bool des,
    ReqModel req,
    List<File> images,
    List<CatalogItemModel> items,
    String notes,
    double deposit,
    double fees,
    double total,
    String branch,
    String bank,
    ) async {
  try {
    const String status = "order";

    final urlImages = <String>[];
    final currentUser = _auth.currentUser;

    if (currentUser != null) {
      for (final file in images) {
        if (!file.existsSync()) continue;

        final path = "user/photos/${currentUser.uid}-${DateTime.now().millisecondsSinceEpoch}.jpg";
        final ref = FirebaseStorage.instance.ref().child(path);
        final snap = await ref.putFile(file);
        urlImages.add(await snap.ref.getDownloadURL());
      }
    }

    final int reqNumber = await _getNextReqNumber();
    final String orderNumber = reqNumber.toString().padLeft(6, '0');
    final String docId = "REQ-$orderNumber";

    final fixedItems = await _ensureItemsHaveUrls(items);

    await _firestore.collection('req').doc(docId).set({
      'orderNumber': orderNumber,
      'ordernumber': orderNumber,
      'invoiceNumber': orderNumber,
      'orderNoInt': reqNumber,
      'createdAt': FieldValue.serverTimestamp(),

      'status': status,
      'createDoc': currentUser?.uid ?? '',
      'createby': currentUser?.uid ?? '',
      'createname': user.name,
      'typeCreate': user.type,

      'name': req.Name,
      'phone': req.Phone,
      'typeofevent': req.TypeOfEvent,
      'ownerofevent': req.OwnerOfEvent,
      'hour': req.Hour,
      'date': req.Date,
      'address': req.Address,
      'typeofbuilding': req.TypeOfBuilding,
      'float': req.Float,

      'desgin': des.toString(),
      'deposit': deposit.toString(),
      'total': total.toString(),
      'fees': fees.toString(),
      'notes': notes,
      'banktype': bank,
      'branch': branch,

      'task': 'designer',
      'taskstatus': '',
    });

    for (final it in fixedItems) {
      final docRef = _firestore.collection('req').doc(docId).collection('item').doc();
      await docRef.set({
        'doc': docRef.id,
        'name': it.name,
        'price': it.price.toString(),
        'notes': it.des,
        'path': it.path,
        'count': it.count.toString(),
      });
    }

    for (final url in urlImages) {
      final dRef = _firestore.collection('req').doc(docId).collection('des').doc();
      await dRef.set({
        'doc': dRef.id,
        'path': url,
      });
    }

    if (user.type == "Client") {
      final admintoken = await GetAdminsToken(context);
      for (int j = 0; j < admintoken.length; j++) {
        sendNotification(admintoken[j], "New Req", "You Have New Req Created", "4");
      }
      Get.back();
      return;
    }

    final value = await _firestore.collection('req').doc(docId).get();
    final reqq = _reqDataFromSnap(value);

    Get.back();
    Get.to(
          () => CreateOrderWidget(reqq),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 500),
    );
  } catch (e) {
    showErrorDialog(context, e.toString());
  }
}
