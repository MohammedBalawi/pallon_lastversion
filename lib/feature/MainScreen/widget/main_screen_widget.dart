import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/user_model.dart';
import '../../Auth/widget/auth_signin_widget.dart';
import '../../Client/view/client_main_view.dart';
import '../../Staff/view/staff_view.dart';
import '../../language/function/language_function.dart';
import '../function/main_function.dart';

class MainScreenWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MainScreenWidget();
  }
}

class _MainScreenWidget extends State<MainScreenWidget> {
  UserModel userModel = UserModel(
    doc: "doc",
    email: "email",
    phone: "phone",
    name: "name",
    pic: "pic",
    type: "type",
  );

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DateTime? lastPressed;

  @override
  void initState() {
    super.initState();
    GetUserType();
    getPermesion();
    SetLangApp();
  }

  void SetLangApp() async {
    if (await hasStart()) {
      String? lang = await getStart();
      if (lang != null) {
        SetLanguagr(context, lang);
      }
    }
  }

  void GetUserType() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      Get.offAll(() => AuthSignInWidget());
      return;
    }

    setLastSeen(currentUser.uid);

    try {
      final user = await GetUserData(currentUser.uid);

      if (!mounted) return;

      if (user == null) {
        await _auth.signOut();

        Get.snackbar(
          'ملاحظة',
          'لم يتم العثور على بيانات حسابك، يرجى تسجيل الدخول مرة أخرى.',
          snackPosition: SnackPosition.BOTTOM,
        );

        Get.offAll(() => AuthSignInWidget());
        return;
      }

      setState(() {
        userModel = user;
      });

      GetTask(user, context);
    } catch (e) {
      if (!mounted) return;
      Get.snackbar(
        'خطأ',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final now = DateTime.now();

        if (lastPressed == null ||
            now.difference(lastPressed!) > const Duration(seconds: 2)) {
          lastPressed = now;
          Get.snackbar(
            "Exit App",
            "Press back again to exit",
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2),
          );

          return false;
        }

        return true;
      },
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('user')
            .where('doc', isEqualTo: _auth.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                backgroundColor: Color(0xFF07933E),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No items found.'.tr),
            );
          }

          String type = "";
          final messages = snapshot.data!.docs;
          for (var message in messages.reversed) {
            type = message.get('type');
          }

          if (type == "client") {
            return ClientMainView();
          } else {
            return StaffView();
          }
        },
      ),
    );
  }
}
