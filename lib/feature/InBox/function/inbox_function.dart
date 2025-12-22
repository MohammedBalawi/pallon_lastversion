import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Core/Widgets/common_widgets.dart';
import '../../../models/inbox_model.dart';
import '../../MainScreen/function/main_function.dart';
import '../../Requset/functions/req_functions.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

Future<void> AddNewInBox(
    BuildContext context,
    TextEditingController title,
    TextEditingController body,
    ) async {
  try {
    await _firestore.collection('inbox').doc().set({
      'title': title.text.trim(),
      'body': body.text.trim(),
      'time': DateTime.now().toIso8601String(),
    });

    final List<String> clientTokens = await GetClinetToken(context);

    for (final token in clientTokens) {
      try {
        await sendNotification(
          token,
          title.text.trim(),
          body.text.trim(),
          "3",
        );
      } catch (e) {
        debugPrint('Notification error: $e');
      }
    }

    Get.back();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Inbox added successfully'.tr),
        backgroundColor: const Color(0xFF07933E),
      ),
    );
  } catch (e) {
    showErrorDialog(context, e.toString());
  }
}

Future<void> DeleteInBox(BuildContext context, InBoxModel inbox) async {
  try {
    await _firestore.collection('inbox').doc(inbox.doc).delete();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Inbox deleted successfully'.tr),
        backgroundColor: const Color(0xFF07933E),
      ),
    );
  } catch (e) {
    showErrorDialog(context, e.toString());
  }
}
