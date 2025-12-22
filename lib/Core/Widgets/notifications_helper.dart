import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../../feature/Requset/functions/req_functions.dart';

Future<String> getAccessToken() async {
  // TODO: Your implementation
  throw UnimplementedError();
}

// Future<void> sendNotification(
//     String token,
//     String title,
//     String body,
//     String screen,
//     )
// async {
//   try {
//     final String accessToken = await getAccessToken();
//
//     const String fcmUrl =
//         'https://fcm.googleapis.com/v1/projects/iconnectv2-49c98/messages:send';
//
//     final response = await http.post(
//       Uri.parse(fcmUrl),
//       headers: <String, String>{
//         'Content-Type': 'application/json; charset=UTF-8',
//         'Authorization': 'Bearer $accessToken',
//       },
//       body: jsonEncode({
//         'message': {
//           'token': token,
//
//           'notification': {'title': title, 'body': body},
//
//           'data': {
//             'screen': screen,
//             'click_action': 'FLUTTER_NOTIFICATION_CLICK',
//           },
//
//           'android': {
//             'priority': 'HIGH',
//             'notification': {
//               'sound': 'default',
//               'click_action': 'FLUTTER_NOTIFICATION_CLICK',
//               'channel_id': 'high_importance_channel',
//             },
//           },
//
//           'apns': {
//             'headers': {'apns-priority': '10'},
//             'payload': {
//               'aps': {
//                 'sound': 'default',
//               },
//             },
//           },
//         },
//       }),
//     );
//
//     if (response.statusCode == 200) {
//       print(' Notification sent successfully');
//     } else {
//       print(' Failed to send notification: ${response.statusCode}');
//       print('Response body: ${response.body}');
//     }
//   } catch (e) {
//     print('Error sending notification: $e');
//   }
// }

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

Future<void> notifyStaffRolesJobOrder({
  required BuildContext context,
  required String title,
  required String body,
  required String notifyType,
  String? excludeUserId,
}) async {
  try {
    const allowedTypes = ["Admin", "Vendor", "Driver", "Designer", "Coordinator"];

    final snap = await _firestore.collection("user").get();

    for (final d in snap.docs) {
      final data = d.data();
      final String uid = d.id;
      final String type = (data["type"] ?? "").toString();
      final String token = (data["token"] ?? "").toString();

      if (excludeUserId != null && uid == excludeUserId) continue;
      if (!allowedTypes.contains(type)) continue;
      if (token.isEmpty) continue;

      await sendNotification(token, title, body, notifyType);
    }
  } catch (e) {
    debugPrint("notifyStaffRolesJobOrder error: $e");
  }
}
