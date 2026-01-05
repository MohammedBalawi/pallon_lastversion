import 'dart:convert';

import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:pallon_lastversion/feature/AddStaff/function/add_staff_function.dart';
import 'package:pallon_lastversion/feature/Orders/widget/order_widget.dart';

import '../../../Core/Utils/app.images.dart';
import '../../../Core/Widgets/common_widgets.dart';
import '../../../models/catalog_item_model.dart';
import '../../../models/req_data_model.dart';
import '../../../models/user_model.dart';
import '../../MainScreen/function/main_function.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final FirebaseAuth _auth = FirebaseAuth.instance;

Future<ReqDataModel> GetReqDesign(ReqDataModel req, BuildContext context) async {
  final data = req;
  try {
    final snap =
    await _firestore.collection('req').doc(req.doc).collection('des').get();

    for (final d in snap.docs) {
      final map = d.data();
      final path = map['path']?.toString();
      if (path != null && path.isNotEmpty) {
        data.des.add(path);
      }
    }
    return data;
  } catch (e) {
    showErrorDialog(context, e.toString());
    return data;
  }
}

Future<ReqDataModel> GetReqItem(ReqDataModel req, BuildContext context) async {
  try {
    final snap = await _firestore
        .collection('req')
        .doc(req.doc)
        .collection('item')
        .get();

    req.item.clear();

    for (final d in snap.docs) {
      final map = d.data();

      final cat = CatalogItemModel(
        doc: d.id,
        name: map['name']?.toString() ?? '',
        path: map['path']?.toString() ?? '',
        des: map['notes']?.toString() ?? '',
        price: map['price']?.toString() ?? '0',
      );

      final countStr = map['count']?.toString() ?? '0';
      cat.count = int.tryParse(countStr) ?? 0;

      req.item.add(cat);
    }

    return req;
  } catch (e) {
    showErrorDialog(context, e.toString());
    return req;
  }
}

Future<void> RejectRequset(ReqDataModel req, BuildContext context) async {
  try {
    await _firestore.collection('req').doc(req.doc).update({'status': 'reject'});
    mesgCustom(context, "Update Complete");
  } catch (e) {
    showErrorDialog(context, e.toString());
  }
}

Future<List<UserModel>> GetStuff(String type, BuildContext context) async {
  try {
    List<UserModel> users = [];
    final snap =
    await _firestore.collection('user').where('type', isEqualTo: type).get();

    for (final doc in snap.docs) {
      final data = doc.data();

      final user = UserModel(
        doc: doc.id,
        email: (data['email'] ?? '').toString(),
        phone: (data['phone'] ?? '').toString(),
        name: (data['name'] ?? '').toString(),
        pic: (data['pic'] ?? '').toString(),
        type: type,
      );

      final token = data.containsKey('token') ? data['token'] : null;
      user.token = (token == null) ? null : token.toString();

      users.add(user);
    }

    return users;
  } catch (e) {
    showErrorDialog(context, e.toString());
    return [];
  }
}

Future<String> getAccessToken() async {
  try {
    final jsonString = await rootBundle.loadString(AppImages.files);
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);

    final accountCredentials = auth.ServiceAccountCredentials.fromJson(jsonMap);
    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

    final client =
    await auth.clientViaServiceAccount(accountCredentials, scopes);

    final token = client.credentials.accessToken.data;
    client.close();

    return token;
  } catch (e) {
    print(' Error getting access token: $e');
    rethrow;
  }
}

Future<void> sendNotification(
    String token,
    String title,
    String body,
    String screen, {
      String? userDocId,
      Map<String, String>? dataExtras,
    }) async {
  try {
    final t = token.trim();
    if (t.isEmpty) {
      print(' Token is empty, skipping notification.');
      return;
    }

    final String accessToken = await getAccessToken();

    const String projectId = 'iconnectv2-49c98';
    final Uri fcmUrl = Uri.parse(
      'https://fcm.googleapis.com/v1/projects/$projectId/messages:send',
    );

    final data = <String, String>{
      'screen': screen,
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      ...?dataExtras,
    };

    final payload = {
      'message': {
        'token': t,
        'notification': {'title': title, 'body': body},
        'data': data,
        'android': {
          'priority': 'HIGH',
          'notification': {
            'channel_id': 'high_importance_channel',
            'sound': 'default',
          },
        },
        'apns': {
          'payload': {
            'aps': {
              'sound': 'default',
              'content-available': 1,
            },
          },
        },
      },
    };

    final response = await http.post(
      fcmUrl,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      print(' Notification sent successfully');
      return;
    }

    print(' Failed to send notification: ${response.statusCode}');
    print('Response body: ${response.body}');

    bool unregistered = false;
    try {
      final bodyMap = jsonDecode(response.body);
      final details = bodyMap['error']?['details'];
      if (details is List) {
        unregistered = details.any((d) =>
        d is Map &&
            d['@type'] ==
                'type.googleapis.com/google.firebase.fcm.v1.FcmError' &&
            d['errorCode'] == 'UNREGISTERED');
      }
    } catch (_) {}

    if (unregistered) {
      print(' Token is UNREGISTERED (expired/removed).');
      if (userDocId != null && userDocId.trim().isNotEmpty) {
        await _firestore.collection('user').doc(userDocId).update({
          'token': FieldValue.delete(),
        });
        print(' Removed invalid token from user/$userDocId');
      } else {
        print(' userDocId not provided, cannot delete token from Firestore.');
      }
    }
  } catch (e) {
    print(' Error sending notification: $e');
  }
}

Future<void> CreateJopOrder(
    BuildContext context,
    ReqDataModel req,
    UserModel selectedCoordinator,
    UserModel selectedDesigner,
    UserModel selectedDriver,
    UserModel selectedVendor,
    String ordernumber,
    ) async {
  try {
    final resolvedInvoiceNumber = (req.invoiceNumber ?? "").toString().trim();
    final rawNotifyNumber = resolvedInvoiceNumber.isNotEmpty
        ? resolvedInvoiceNumber
        : ordernumber.toString().trim();
    final notifyNumber = ReqDataModel.formatOrderNumber(rawNotifyNumber);
    final staff = await GetAllStaff();

    final sentTokens = <String>{};
    final sentUserIds = <String>{};

    Future<void> safeSendToUser(
        UserModel user,
        String title,
        String body,
        String screen,
        ) async {
      final uid = user.doc.trim();
      final tok = (user.token ?? '').trim();

      if (uid.isNotEmpty && sentUserIds.contains(uid)) return;

      if (tok.isNotEmpty && sentTokens.contains(tok)) return;

      if (uid.isNotEmpty) sentUserIds.add(uid);
      if (tok.isNotEmpty) sentTokens.add(tok);

      if (tok.isEmpty) return;

      await sendNotification(
        tok,
        title,
        body,
        screen,
        userDocId: uid.isEmpty ? null : uid,
        dataExtras: {
          'invoiceNumber': notifyNumber,
          'reqDoc': req.doc,
        },
      );
    }

    final jopRef =
    _firestore.collection('req').doc(req.doc).collection('jop').doc();
    await jopRef.set({
      'createby': _auth.currentUser!.uid,
      'createname': _auth.currentUser!.displayName,
      'Coordinator': selectedCoordinator.doc,
      'Designer': selectedDesigner.doc,
      'Driver': selectedDriver.doc,
      'Vendor': selectedVendor.doc,
    });

    Future<void> addTaskAndNotify(UserModel user) async {
      await _firestore.collection('user').doc(user.doc).collection('task').add({
        'doc': req.doc,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _firestore
          .collection('user')
          .doc(user.doc)
          .collection('Notification')
          .add({
        'title': "New Task",
        'body': "تم إنشاء أمر تنفيذ رقم $notifyNumber",
        'doc': req.doc,
        'invoiceNumber': notifyNumber,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await safeSendToUser(
        user,
        "New Task",
        "تم إنشاء أمر تنفيذ رقم $notifyNumber",
        "4",
      );
    }

    await addTaskAndNotify(selectedCoordinator);
    await addTaskAndNotify(selectedDesigner);
    await addTaskAndNotify(selectedDriver);
    await addTaskAndNotify(selectedVendor);

    await _firestore.collection('req').doc(req.doc).update({
      'status': 'order',
      'orderNumber': notifyNumber,
      'ordernumber': notifyNumber,
      'invoiceNumber': notifyNumber,
      'task': 'desginer',
      'taskstatus': 'progress',
    });

    int x = int.tryParse(notifyNumber) ?? 0;
    x++;
    await _firestore.collection('const').doc("qaJdz7K1kwuKQLWlSHdG").update({
      "ordernumber": x.toString(),
    });

    final adminTokensList = await GetAdminsToken(context);
    final adminTokens = <String>{};

    for (final t in adminTokensList) {
      final tok = (t ?? '').toString().trim();
      if (tok.isEmpty) continue;

      if (!adminTokens.add(tok)) continue;
      if (sentTokens.contains(tok)) continue;

      sentTokens.add(tok);

      await sendNotification(
        tok,
        "New Order",
        "تم إنشاء أمر تنفيذ رقم $notifyNumber",
        "4",
        dataExtras: {
          'invoiceNumber': notifyNumber,
          'reqDoc': req.doc,
        },
      );
    }

    for (final u in staff) {
      await safeSendToUser(
        u,
        "New Order",
        "تم إنشاء أمر تنفيذ رقم $notifyNumber",
        "4",
      );
    }

    Get.back();
    Get.to(() => OrderWidget());
  } catch (e) {
    showErrorDialog(context, e.toString());
  }
}
