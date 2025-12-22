import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

Future<String> getAccessToken() async {
  // TODO: keep your current implementation
  throw UnimplementedError();
}

class NotificationTarget {
  final String userId;
  final String token;
  NotificationTarget({required this.userId, required this.token});
}

Future<List<NotificationTarget>> getUsersTokensByTypes(List<String> types) async {
  final snap = await FirebaseFirestore.instance
      .collection('user')
      .where('type', whereIn: types)
      .get();

  final List<NotificationTarget> result = [];

  for (final doc in snap.docs) {
    final data = doc.data();
    final token = data['token']?.toString();

    if (token == null || token.trim().isEmpty) {
      continue;
    }

    result.add(NotificationTarget(userId: doc.id, token: token.trim()));
  }

  return result;
}

Future<void> sendNotification({
  required String token,
  required String title,
  required String body,
  required String screen,
  String? userDocId,
}) async {
  try {
    final t = token.trim();
    if (t.isEmpty) {
      print(' Token empty, skip.');
      return;
    }

    final accessToken = await getAccessToken();
    const projectId = 'iconnectv2-49c98';
    final fcmUrl = Uri.parse('https://fcm.googleapis.com/v1/projects/$projectId/messages:send');

    final payload = {
      'message': {
        'token': t,
        'notification': {
          'title': title,
          'body': body,
        },

        'data': {
          'screen': screen,
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        },

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
            }
          }
        }
      }
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
            d['@type'] == 'type.googleapis.com/google.firebase.fcm.v1.FcmError' &&
            d['errorCode'] == 'UNREGISTERED');
      }
    } catch (_) {}

    if (unregistered) {
      print(' Token UNREGISTERED.');
      if (userDocId != null && userDocId.trim().isNotEmpty) {
        await FirebaseFirestore.instance.collection('user').doc(userDocId).update({
          'token': FieldValue.delete(),
        });
        print(' Token deleted from user/$userDocId');
      } else {
        print(' userDocId not provided, cannot delete token.');
      }
    }
  } catch (e) {
    print(' Error sending notification: $e');
  }
}
