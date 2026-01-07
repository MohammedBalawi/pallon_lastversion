import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import '../../../Core/Widgets/common_widgets.dart';
import '../../splash/views/splash_view.dart';

Future<void> SignInMethod(
    String email, String password, BuildContext context) async {
  final FirebaseAuth auth = FirebaseAuth.instance;

  try {
    await auth.signInWithEmailAndPassword(email: email, password: password);
    Get.offAll(SplashView());
  } on FirebaseAuthException catch (e) {
    ErrorCustom(context, e.message ?? e.code);
  } catch (e) {
    ErrorCustom(context, e.toString());
  }
}

Future<void> SignUpMethod(
    String name,
    XFile? img,
    String email,
    String password,
    String phone,
    BuildContext context,
    ) async {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  try {
    await auth.createUserWithEmailAndPassword(email: email, password: password);

    await firestore.collection('user').doc(auth.currentUser!.uid).set({
      'doc': auth.currentUser!.uid,
      'phone': phone,
      'email': email,
      'name': name,
      'pic': "",
      'type': 'client',
    });

    Get.offAll(SplashView());
  } on FirebaseAuthException catch (e) {
    ErrorCustom(context, e.message ?? e.code);
  } catch (e) {
    ErrorCustom(context, e.toString());
  }
}

Future<void> SignInWithGoogle(BuildContext context) async {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  try {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) return;

    final GoogleSignInAuthentication googleAuth =
    await googleUser.authentication;

    if (googleAuth.idToken == null && googleAuth.accessToken == null) {
      ErrorCustom(context, 'Google sign-in failed, no tokens received');
      return;
    }

    final OAuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      accessToken: googleAuth.accessToken,
    );

    final UserCredential userCredential =
    await auth.signInWithCredential(credential);

    final String uid = userCredential.user!.uid;

    final DocumentSnapshot userDoc =
    await firestore.collection('user').doc(uid).get();

    if (!userDoc.exists) {
      await firestore.collection('user').doc(uid).set({
        'doc': uid,
        'phone': userCredential.user!.phoneNumber ?? "",
        'email': userCredential.user!.email ?? "",
        'name': userCredential.user!.displayName ?? "",
        'pic': userCredential.user!.photoURL ?? "",
        'type': 'client',
      });
    }

    Get.offAll(SplashView());
  } on FirebaseAuthException catch (e) {
    ErrorCustom(context, e.message ?? e.code);
  } catch (e) {
    ErrorCustom(context, e.toString());
  }
}
