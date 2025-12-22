import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pallon_lastversion/main.dart';

import '../../../Core/Widgets/common_widgets.dart';
import '../../../models/user_model.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
FirebaseMessaging fcm = FirebaseMessaging.instance;
final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();

void setLastSeen(String doc) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  await firestore.collection('user').doc(doc).collection('seen').doc().set({
    'time': DateTime.now().toString(),
  });
}

Future<UserModel?> GetUserData(String uid) async {
  final firestore = FirebaseFirestore.instance;

  try {
    final docSnap = await firestore.collection('user').doc(uid).get();

    if (!docSnap.exists) {
      debugPrint('GetUserData: no user doc found for uid: $uid');
      return null;
    }

    final data = docSnap.data() ?? {};

    return UserModel(
      doc: data['doc'] ?? uid,
      email: data['email'] ?? '',
      phone: (data['phone'] ?? '').toString(),
      name: data['name'] ?? '',
      pic: data['pic'] ?? '',
      type: data['type'] ?? '',
    );
  } catch (e) {
    debugPrint('GetUserData error: $e');
    rethrow;
  }
}

void getPermesion() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  NotificationSettings settings = await fcm.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
  } else {
  }

  if (Get.context != null &&
      Theme.of(Get.context!).platform == TargetPlatform.iOS) {
    String? apnsToken = await fcm.getAPNSToken();
    if (apnsToken == null) return;
  }

  String? token = await fcm.getToken();

  if (token != null && auth.currentUser != null) {
    await firestore.collection('user').doc(auth.currentUser!.uid).update({
      'token': token,
    });
  }

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.notification != null &&
        message.notification!.title != null &&
        message.notification!.body != null) {
      showNotification(
        message.notification!.title!,
        message.notification!.body!,
      );
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  });
}

Future<void> showNotification(String title, String body) async {
  var androidDetails = AndroidNotificationDetails(
    'channelId',
    'channelName',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
  );
  var platformDetails = NotificationDetails(android: androidDetails);
  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    platformDetails,
    payload: 'item x',
  );
}


int _toInt(dynamic v, {int fallback = 0}) {
  if (v == null) return fallback;
  if (v is int) return v;
  if (v is num) return v.toInt();
  final s = v.toString().trim();
  return int.tryParse(s) ?? fallback;
}

double _toDouble(dynamic v, {double fallback = 0.0}) {
  if (v == null) return fallback;
  if (v is double) return v;
  if (v is num) return v.toDouble();
  final s = v.toString().trim().replaceAll(',', '.');
  return double.tryParse(s) ?? fallback;
}

bool _toBool(dynamic v, {bool fallback = false}) {
  if (v == null) return fallback;
  if (v is bool) return v;
  final s = v.toString().trim().toLowerCase();
  if (s == 'true' || s == '1' || s == 'yes') return true;
  if (s == 'false' || s == '0' || s == 'no') return false;
  return fallback;
}

Map<String, int> _parseHourMinute(dynamic v) {
  if (v == null) return {'hour': 0, 'minute': 0};

  if (v is int) return {'hour': v, 'minute': 0};
  if (v is num) return {'hour': v.toInt(), 'minute': 0};

  final s = v.toString().trim();
  final asInt = int.tryParse(s);
  if (asInt != null) return {'hour': asInt, 'minute': 0};

  try {
    final dt = DateFormat('h:mm a').parse(s);
    return {'hour': dt.hour, 'minute': dt.minute};
  } catch (_) {}

  try {
    final dt = DateFormat('H:mm').parse(s);
    return {'hour': dt.hour, 'minute': dt.minute};
  } catch (_) {}

  return {'hour': 0, 'minute': 0};
}
DateTime? _parseDateSlash(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  if (s.isEmpty) return null;

  try {
    return DateFormat('d/M/yyyy').parseStrict(s);
  } catch (_) {
    return null;
  }
}


Future<void> GetTask(UserModel user, BuildContext context) async {
  try {
    final tasksSnap = await _firestore
        .collection('user')
        .doc(user.doc)
        .collection('task')
        .get();

    final taskDocs = <String>[];
    for (final d in tasksSnap.docs) {
      final docId = d.data()['doc'];
      if (docId != null) taskDocs.add(docId.toString());
    }

    for (final reqDocId in taskDocs) {
      final reqSnap = await _firestore.collection('req').doc(reqDocId).get();
      if (!reqSnap.exists) continue;

      final data = reqSnap.data() ?? {};

      final typeOfEvent = (data['typeofevent'] ?? '').toString();
      final nameEvent = "Task Of $typeOfEvent";

      final date = _parseDateSlash(data['date']);
      if (date == null) continue;

      final hm = _parseHourMinute(data['hour']);
      final hour = hm['hour'] ?? 0;
      final minute = hm['minute'] ?? 0;

      await SaveInCalender(
        context,
        nameEvent,
        "Palloncino Task",
        date.year,
        date.month,
        date.day,
        hour,
        minute,
      );
    }
  } catch (e) {
    showErrorDialog(context, e.toString());
  }
}


Future<void> SaveInCalender(
    BuildContext context,
    String title,
    String des,
    int year,
    int month,
    int day,
    int hour,
    int minute,
    ) async {
  try {
    tz.initializeTimeZones();

    var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
    if (permissionsGranted.isSuccess && !(permissionsGranted.data ?? false)) {
      permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
      if (!permissionsGranted.isSuccess || !(permissionsGranted.data ?? false)) {
        return;
      }
    }

    final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
    final calendars = calendarsResult.data;
    if (calendars == null || calendars.isEmpty) {
      print(' No calendars found on the device.');
      return;
    }

    final calendarId = calendars
        .firstWhere((c) => c.isDefault ?? false, orElse: () => calendars.first)
        .id ??
        calendars.first.id;

    if (calendarId == null) {
      print(' Could not determine a valid calendar ID.');
      return;
    }

    final loc = tz.local;

    final start = tz.TZDateTime(loc, year, month, day, hour, minute);
    final end = start.add(const Duration(hours: 1));

    final event = Event(
      calendarId,
      title: title,
      description: des,
      start: start,
      end: end,
      reminders: [
        Reminder(minutes: 10),
        Reminder(minutes: 60),
        Reminder(minutes: 1440),
        Reminder(minutes: 2880),
      ],
    );

    final result = await _deviceCalendarPlugin.createOrUpdateEvent(event);
    if (result != null && result.isSuccess) {
      print(' Event added successfully. Event ID: ${result.data}');
    } else {
      print(' Failed to add event');
    }
  } catch (e) {
    showErrorDialog(context, e.toString());
  }
}

Future<List<String>> GetAdminsToken(BuildContext context) async {
  List<String> docs = [];
  try {
    final snap = await _firestore
        .collection('user')
        .where('type', isEqualTo: "Admin")
        .get();

    for (final d in snap.docs) {
      docs.add(d.id);
    }

    return docs;
  } catch (e) {
    showErrorDialog(context, e.toString());
    return docs;
  }
}

Future<List<String>> GetClinetToken(BuildContext context) async {
  List<String> docs = [];
  try {
    final snap = await _firestore
        .collection('user')
        .where('type', isEqualTo: "client")
        .get();

    for (final d in snap.docs) {
      final token = d.data()['token'];
      if (token != null) docs.add(token.toString());
    }

    return docs;
  } catch (e) {
    showErrorDialog(context, e.toString());
    return docs;
  }
}
