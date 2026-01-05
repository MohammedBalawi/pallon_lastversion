import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../Core/Widgets/common_widgets.dart';
import '../../../models/order_model.dart';
import '../../../models/req_data_model.dart';
import '../../../models/user_model.dart';
import '../../Requset/functions/req_functions.dart';


final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

String _s(dynamic v) => (v ?? '').toString();

void _safeSnack(
    BuildContext context,
    String message, {
      bool isError = false,
    }) {
  if (!context.mounted) return;

  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFCE232B) : const Color(0xFF07933E),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
}

UserModel _userFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
  final data = doc.data() ?? {};
  final u = UserModel(
    doc: doc.id,
    email: _s(data['email']),
    phone: _s(data['phone']),
    name: _s(data['name']),
    pic: _s(data['pic']),
    type: _s(data['type']),
  );
  u.token = data['token'] == null ? null : _s(data['token']);
  return u;
}

Future<int> _getNextJobOrderNumber() async {
  final counterRef = _firestore.collection('counters').doc('jobOrder');

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

Future<String?> createJobOrder({
  required BuildContext context,
  required ReqDataModel req,
  required UserModel coordinator,
  required UserModel designer,
  required UserModel driver,
  required UserModel vendor,
}) async {
  try {
    final reqDocId = _s(req.doc).trim();
    if (reqDocId.isEmpty) {
      _safeSnack(context, "لا يوجد رقم طلب صالح", isError: true);
      return null;
    }

    final reqRef = _firestore.collection('req').doc(reqDocId);

    final jopRef = reqRef.collection('jop').doc(reqDocId);

    final reqSnap = await reqRef.get();
    final reqData = reqSnap.data() ?? {};
    String _resolveInvoiceNumber() {
      final candidates = [
        _s(reqData['invoiceNumber']),
        _s(reqData['invoice_number']),
        _s(reqData['orderNumber']),
        _s(reqData['ordernumber']),
        _s(req.invoiceNumber),
        _s(req.orderNumber),
      ];
      for (final c in candidates) {
        final trimmed = c.trim();
        if (trimmed.isNotEmpty) return trimmed;
      }
      return "";
    }

    final existingJobOrderNumber = _s(reqData['jobOrderNumber']).trim();
    if (existingJobOrderNumber.isNotEmpty) {
      _safeSnack(context, "أمر التشغيل موجود مسبقًا: $existingJobOrderNumber");
      return existingJobOrderNumber;
    }

    final jopSnap = await jopRef.get();
    if (jopSnap.exists) {
      final jd = (jopSnap.data() as Map<String, dynamic>? ?? {});
      final fromJob = _s(jd['orderNumber']).trim();

      if (fromJob.isNotEmpty) {
        await reqRef.update({
          'jobOrderNumber': fromJob,
          'jobOrderNoInt': jd['orderNoInt'],
        });

        _safeSnack(context, "أمر التشغيل موجود مسبقًا: $fromJob");
        return fromJob;
      }
    }

    final int seq = await _getNextJobOrderNumber();
    final String jobOrderNumber = seq.toString().padLeft(6, '0');
    final String orderNumber = _resolveInvoiceNumber();
    final String notifyNumber = ReqDataModel.formatOrderNumber(
      orderNumber.isNotEmpty ? orderNumber : jobOrderNumber,
    );

    await jopRef.set({
      'Coordinator': coordinator.doc,
      'Designer': designer.doc,
      'Driver': driver.doc,
      'Vendor': vendor.doc,
      'createby': _auth.currentUser?.uid ?? '',
      'createname': _auth.currentUser?.displayName ?? '',
      'orderNumber': jobOrderNumber,
      'orderNoInt': seq,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await reqRef.update({
      'status': 'order',
      'jobOrderNumber': jobOrderNumber,
      'jobOrderNoInt': seq,
      'task': 'desginer',
      'taskstatus': 'progress',
    });

    Future<void> _addTask(UserModel user) async {
      final ref = _firestore.collection('user').doc(user.doc).collection('task').doc(reqDocId);
      final exists = await ref.get();
      if (!exists.exists) {
        await ref.set({'doc': reqDocId, 'createdAt': FieldValue.serverTimestamp()});
      }
    }

    await Future.wait([
      _addTask(coordinator),
      _addTask(designer),
      _addTask(driver),
      _addTask(vendor),
    ]);

    const allowedTypes = {"Admin", "Vendor", "Driver", "Designer", "Coordinator"};
    final usersSnap = await _firestore.collection('user').get();
    final Map<String, String> tokenToUserId = {};

    for (final d in usersSnap.docs) {
      final data = d.data();
      final type = _s(data['type']);
      if (!allowedTypes.contains(type)) continue;

      final tok = _s(data['token']).trim();
      if (tok.isEmpty) continue;

      tokenToUserId[tok] = d.id;
    }

    for (final entry in tokenToUserId.entries) {
      await sendNotification(
        entry.key,
        "New Job Order",
        "تم إنشاء أمر تشغيل رقم: $notifyNumber",
        "5",
        userDocId: entry.value,
        dataExtras: {
          'invoiceNumber': notifyNumber,
          'reqDoc': reqDocId,
        },
      );
    }

    _safeSnack(context, "تم إنشاء أمر التشغيل رقم $notifyNumber");
    return jobOrderNumber;
  } catch (e) {
    showErrorDialog(context, e.toString());
    return null;
  }
}

Future<bool> cheeckJopOrderCreated(ReqDataModel req, BuildContext context) async {
  try {
    final reqDocId = _s(req.doc).trim();
    if (reqDocId.isEmpty) return false;

    final reqSnap = await _firestore.collection('req').doc(reqDocId).get();
    final data = reqSnap.data() ?? {};
    if (_s(data['jobOrderNumber']).trim().isNotEmpty) return true;

    final jobDoc = await _firestore.collection('req').doc(reqDocId).collection('jop').doc(reqDocId).get();
    if (jobDoc.exists) return true;

    final oldSnap = await _firestore.collection('req').doc(reqDocId).collection('jop').limit(1).get();
    return oldSnap.docs.isNotEmpty;
  } catch (_) {
    return false;
  }
}

Future<int> GetConstantNumber() async {
  try {
    final doc = await _firestore.collection('const').doc("qaJdz7K1kwuKQLWlSHdG").get();
    final data = doc.data() ?? {};
    return int.tryParse(_s(data['ordernumber'])) ?? 0;
  } catch (_) {
    return 0;
  }
}

Future<int> GetConstanttax() async {
  try {
    final doc = await _firestore.collection('const').doc("qaJdz7K1kwuKQLWlSHdG").get();
    final data = doc.data() ?? {};
    return int.tryParse(_s(data['tax'])) ?? 0;
  } catch (_) {
    return 0;
  }
}

Future<OrderModel> GetStaffOrder(OrderModel order, BuildContext context) async {
  try {
    final reqDocId = _s(order.req?.doc).trim();
    if (reqDocId.isEmpty) return order;

    DocumentSnapshot<Map<String, dynamic>>? fixedDoc;
    final fixed = await _firestore.collection('req').doc(reqDocId).collection('jop').doc(reqDocId).get();
    if (fixed.exists) fixedDoc = fixed;

    Map<String, dynamic> jopData = {};
    if (fixedDoc != null) {
      jopData = fixedDoc.data() ?? {};
    } else {
      final jopSnap = await _firestore
          .collection('req')
          .doc(reqDocId)
          .collection('jop')
          .limit(1)
          .get();

      if (jopSnap.docs.isEmpty) return order;
      jopData = jopSnap.docs.first.data();
    }

    Future<UserModel> _getUserSafe(String uid) async {
      final uDoc = await _firestore.collection('user').doc(uid).get();
      if (!uDoc.exists) {
        return UserModel(doc: uid, email: '', phone: '', name: '', pic: '', type: '');
      }
      return _userFromDoc(uDoc);
    }

    final coordinatorId = _s(jopData['Coordinator']);
    final designerId = _s(jopData['Designer']);
    final driverId = _s(jopData['Driver']);
    final vendorId = _s(jopData['Vendor']);
    final createById = _s(jopData['createby']);

    if (coordinatorId.isNotEmpty) order.Coordinator = await _getUserSafe(coordinatorId);
    if (designerId.isNotEmpty) order.Designer = await _getUserSafe(designerId);
    if (driverId.isNotEmpty) order.Driver = await _getUserSafe(driverId);
    if (vendorId.isNotEmpty) order.Vendor = await _getUserSafe(vendorId);
    if (createById.isNotEmpty) order.createby = await _getUserSafe(createById);

    return order;
  } catch (e) {
    ErrorCustom(context, e.toString());
    return order;
  }
}

Future<OrderModel> GetTaskStatus(OrderModel order, BuildContext context) async {
  try {
    final value = await _firestore.collection('req').doc(order.req!.doc).get();
    final data = value.data() ?? {};
    order.req!.task = _s(data['task']);
    order.req!.taskstatus = _s(data['taskstatus']);
    return order;
  } catch (e) {
    ErrorCustom(context, e.toString());
    return order;
  }
}

Future<void> UpdateStaffOrder(
    BuildContext context,
    UserModel coor,
    UserModel vendor,
    UserModel driver,
    UserModel des,
    OrderModel order,
    ) async {
  try {
    final reqDocId = _s(order.req?.doc).trim();
    if (reqDocId.isEmpty) {
      _safeSnack(context, "لا يوجد رقم طلب صالح", isError: true);
      return;
    }

    final fixedRef = _firestore.collection('req').doc(reqDocId).collection('jop').doc(reqDocId);
    final fixedSnap = await fixedRef.get();

    DocumentReference<Map<String, dynamic>> targetRef;

    if (fixedSnap.exists) {
      targetRef = fixedRef;
    } else {
      final snap = await _firestore
          .collection('req')
          .doc(reqDocId)
          .collection('jop')
          .limit(1)
          .get();

      if (snap.docs.isEmpty) {
        _safeSnack(context, "لا يوجد Job Order لتحديثه", isError: true);
        return;
      }

      targetRef = _firestore.collection('req').doc(reqDocId).collection('jop').doc(snap.docs.first.id);
    }

    await targetRef.update({
      'Coordinator': coor.doc,
      'Designer': des.doc,
      'Driver': driver.doc,
      'Vendor': vendor.doc,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    Future<void> addTask(UserModel user) async {
      final ref = _firestore.collection('user').doc(user.doc).collection('task').doc(reqDocId);
      final exists = await ref.get();
      if (!exists.exists) {
        await ref.set({'doc': reqDocId, 'createdAt': FieldValue.serverTimestamp()});
      }
    }

    await Future.wait([addTask(coor), addTask(des), addTask(driver), addTask(vendor)]);

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    _safeSnack(context, "تم تحديث الموظفين بنجاح");
  } catch (e) {
    _safeSnack(context, "حدث خطأ أثناء التحديث", isError: true);
  }
}

Future<bool> UpdateOrderDetails({
  required String reqDocId,
  required Map<String, dynamic> data,
}) async {
  final trimmed = reqDocId.trim();
  if (trimmed.isEmpty) return false;

  try {
    final payload = Map<String, dynamic>.from(data);
    payload['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.collection('req').doc(trimmed).update(payload);
    return true;
  } catch (_) {
    return false;
  }
}
