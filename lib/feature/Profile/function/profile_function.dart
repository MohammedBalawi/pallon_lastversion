import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Core/Utils/manager_fonts.dart';
import '../../../Core/Widgets/common_widgets.dart';
import '../../splash/views/splash_view.dart';

FirebaseAuth auth = FirebaseAuth.instance;
FirebaseFirestore firestore = FirebaseFirestore.instance;
FirebaseStorage storage = FirebaseStorage.instance;

void updateProfile(String name, String phone, File image, BuildContext context) async {
  try {
    final path = "agent/photos/${auth.currentUser!.uid}-${DateTime.now().toString()}.jpg";
    final ref = FirebaseStorage.instance.ref().child(path);
    final uploadTask = ref.putFile(image);
    final snapshot = await uploadTask.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();

    await firestore.collection('user').doc(auth.currentUser!.uid).update({
      'pic': urlDownload,
      'name': name,
      'phone': phone,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile Updated Successfully!'),
        backgroundColor: Color(0xFF07933E),
      ),
    );
  } catch (e) {
    showErrorDialog(context, e.toString());
  }
}

void updateProfile2(String name, String phone, BuildContext context) async {
  try {
    await firestore.collection('user').doc(auth.currentUser!.uid).update({
      'name': name,
      'phone': phone,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile Updated Successfully!'),
        backgroundColor: Color(0xFF07933E),
      ),
    );
  } catch (e) {
    showErrorDialog(context, e.toString());
  }
}

void confirmRemoveAccountDialog(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.4),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, __, ___) {
      final screenWidth = MediaQuery.of(context).size.width;

      return Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: screenWidth * 0.85,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCE232B).withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_forever_rounded,
                    color: Color(0xFFCE232B),
                    size: 42,
                  ),
                ),
                const SizedBox(height: 14),

                Text(
                  "Confirm Delete Account".tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: ManagerFontFamily.fontFamily,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF222222),
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  "Are you sure you want to delete your account?".tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: ManagerFontFamily.fontFamily,
                    fontSize: 14.5,
                    height: 1.5,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  "This action cannot be undone.".tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: ManagerFontFamily.fontFamily,
                    fontSize: 13.5,
                    height: 1.5,
                    color: const Color(0xFFCE232B),
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 22),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Get.back(),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xFF07933E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          "Cancel".tr,
                          style: TextStyle(
                            fontFamily: ManagerFontFamily.fontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Get.back();
                          await RemoveAccount(context);
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xFFCE232B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          "Delete".tr,
                          style: TextStyle(
                            fontFamily: ManagerFontFamily.fontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
    transitionBuilder: (_, anim, __, child) {
      return Transform.scale(
        scale: 0.9 + (0.1 * anim.value),
        child: Opacity(
          opacity: anim.value,
          child: child,
        ),
      );
    },
  );
}

void logout(BuildContext context) async {
  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.4),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, __, ___) {
      final screenWidth = MediaQuery.of(context).size.width;

      return Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: screenWidth * 0.85,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCE232B).withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Color(0xFFCE232B),
                    size: 40,
                  ),
                ),
                const SizedBox(height: 14),

                Text(
                  "Confirm Logout".tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: ManagerFontFamily.fontFamily,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF222222),
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  "Are you sure you want to logout?".tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: ManagerFontFamily.fontFamily,
                    fontSize: 14.5,
                    height: 1.5,
                    color: Colors.grey[700],
                  ),
                ),

                const SizedBox(height: 22),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Get.back(),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xFF07933E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          "Cancel".tr,
                          style: TextStyle(
                            fontFamily: ManagerFontFamily.fontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Get.back();
                          try {
                            await auth.signOut();
                            Get.offAll(
                                  () => SplashView(),
                              transition: Transition.fadeIn,
                              duration: const Duration(milliseconds: 450),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Can't Logout".tr),
                                backgroundColor: const Color(0xFFCE232B),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xFFCE232B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          "Logout".tr,
                          style: TextStyle(
                            fontFamily: ManagerFontFamily.fontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
    transitionBuilder: (_, anim, __, child) {
      return Transform.scale(
        scale: 0.9 + (0.1 * anim.value),
        child: Opacity(opacity: anim.value, child: child),
      );
    },
  );
}

Future<bool> _reauthDialog(BuildContext context) async {
  final passController = TextEditingController();
  bool success = false;

  await showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.4),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, __, ___) {
      final screenWidth = MediaQuery.of(context).size.width;

      return Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: screenWidth * 0.85,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Re-authentication Required".tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: ManagerFontFamily.fontFamily,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF222222),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Please enter your password to continue.".tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: ManagerFontFamily.fontFamily,
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 14),

                TextField(
                  controller: passController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Password".tr,
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xFF07933E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          "Cancel".tr,
                          style: TextStyle(
                            fontFamily: ManagerFontFamily.fontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            final user = auth.currentUser;
                            final email = user?.email;

                            if (user == null || email == null) {
                              throw Exception("No user email found");
                            }

                            final credential = EmailAuthProvider.credential(
                              email: email,
                              password: passController.text.trim(),
                            );

                            await user.reauthenticateWithCredential(credential);
                            success = true;
                            Get.back();
                          } catch (e) {
                            showErrorDialog(context, e.toString());
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xFFCE232B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          "Confirm".tr,
                          style: TextStyle(
                            fontFamily: ManagerFontFamily.fontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
    transitionBuilder: (_, anim, __, child) {
      return Transform.scale(
        scale: 0.9 + (0.1 * anim.value),
        child: Opacity(opacity: anim.value, child: child),
      );
    },
  );

  return success;
}

Future<void> RemoveAccount(BuildContext context) async {
  try {
    final user = auth.currentUser;
    if (user == null) return;

    await firestore.collection('user').doc(user.uid).delete();

    try {
      await user.delete();
      Get.offAll(() => SplashView());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        final ok = await _reauthDialog(context);
        if (!ok) return;

        await user.delete();
        Get.offAll(() => SplashView());
      } else {
        rethrow;
      }
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Can't Remove Account".tr),
        backgroundColor: const Color(0xFFCE232B),
      ),
    );
  }
}

void UpdatePasswordProfile(TextEditingController pass, BuildContext context) async {
  try {
    await auth.currentUser!.updatePassword(pass.text);
    Get.back();
  } catch (e) {
    showErrorDialog(context, e.toString());
  }
}
