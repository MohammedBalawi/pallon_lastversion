import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../../Core/Utils/app.images.dart';
import '../../../Core/Utils/manager_fonts.dart';
import '../../../Core/Widgets/common_widgets.dart';
import '../../../Core/Widgets/social_media_button.dart';
import '../function/Auth_Functions.dart';
import '../view/auth_signup_view.dart';
import '../view/forget_password_view.dart';
import 'BottomWaveClipper.dart';
import 'PinkWaveClipper.dart';
import 'TopWaveClipper.dart';

class AuthSignInWidget extends StatefulWidget {
  const AuthSignInWidget({Key? key}) : super(key: key);

  @override
  State<AuthSignInWidget> createState() => _AuthSignInWidget();
}

class _AuthSignInWidget extends State<AuthSignInWidget> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _pass = TextEditingController();
  bool _show = false;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _handleEmailLogin() async {
    if (_email.text.isEmpty) {
      ErrorCustom(context, "Please Enter Your Email".tr);
      return;
    }
    if (_pass.text.isEmpty) {
      ErrorCustom(context, "Please Enter Your Password".tr);
      return;
    }

    setState(() => _show = true);
    try {
      await SignInMethod(_email.text.trim(), _pass.text.trim(), context);
    } finally {
      if (mounted) setState(() => _show = false);
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _show = true);
    try {
      await SignInWithGoogle(context);
    } finally {
      if (mounted) setState(() => _show = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isArabic = (Get.locale?.languageCode.toLowerCase() == 'ar');

    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: _show,
        child: Stack(
          children: [
            Transform.translate(
              offset: const Offset(0, 18),
              child: ClipPath(
                clipper: PinkWaveClipper(),
                child: Container(
                  height: screenHeight * 0.45,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFD5F3DF).withOpacity(0.35),
                        const Color(0xFFDFD6D6).withOpacity(0.20),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
            ),
            ClipPath(
              clipper: TopWaveClipper(),
              child: SizedBox(
                height: screenHeight * 0.45,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF07933E),
                            Color(0xFF007530),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    Opacity(
                      opacity: 0.25,
                      child: Image.asset(
                        AppImages.pallen,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            isArabic?
            Positioned(
              top: 130,
              left: 10,
              child: SizedBox(
                width: screenWidth * 0.45,
                child: Image.asset(
                  AppImages.logo_copy,
                  fit: BoxFit.cover,
                ),
              ),
            ):
            Positioned(
              top: 130,
              right: 10,
              child: SizedBox(
                width: screenWidth * 0.45,
                child: Image.asset(
                  AppImages.logo_copy,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: ClipPath(
                clipper: BottomWaveClipper(),
                child: Container(
                  height: screenHeight * 0.65,
                  color: Colors.white,
                ),
              ),
            ),

            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 200),
                    Text(
                      'Sign in'.tr,
                      style: TextStyle(
                        fontFamily: ManagerFontFamily.fontFamily,
                        fontSize: screenWidth * 0.1,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF000000),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.05),

                    Text(
                      'Email'.tr,
                      style: TextStyle(
                        fontFamily: ManagerFontFamily.fontFamily,
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 0,
                          minHeight: 0,
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: SvgPicture.asset(
                              AppImages.email,
                              color: Colors.black,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        hintText: 'demo@email.com',
                        hintStyle: TextStyle(
                          fontFamily: ManagerFontFamily.fontFamily,
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(screenWidth * 0.03),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.018,
                          horizontal: screenWidth * 0.02,
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    Text(
                      'Password'.tr,
                      style: TextStyle(
                        fontFamily: ManagerFontFamily.fontFamily,
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    TextFormField(
                      controller: _pass,
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 0,
                          minHeight: 0,
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: SvgPicture.asset(
                              AppImages.lock,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        hintText: 'enter your password'.tr,
                        hintStyle: TextStyle(
                          fontFamily: ManagerFontFamily.fontFamily,
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(screenWidth * 0.03),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.018,
                          horizontal: screenWidth * 0.02,
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.01),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: true,
                              onChanged: (value) {},
                              fillColor: MaterialStateProperty.all(
                                const Color(0xFFCE232B),
                              ),
                              visualDensity: VisualDensity.compact,
                            ),
                            Text(
                              'Remember Me'.tr,
                              style: TextStyle(
                                fontFamily: ManagerFontFamily.fontFamily,
                                fontSize: screenWidth * 0.035,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            Get.to(
                                  () => ForgetPasswordView(),
                              transition: Transition.fadeIn,
                              duration: const Duration(seconds: 1),
                            );
                          },
                          child: Text(
                            'Forgot Password?'.tr,
                            style: TextStyle(
                              color: const Color(0xFFCE232B),
                              fontSize: screenWidth * 0.035,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.04),

                    SizedBox(
                      width: double.infinity,
                      height: screenHeight * 0.07,
                      child: ElevatedButton(
                        onPressed: _handleEmailLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFCE232B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        child: Text(
                          'Login'.tr,
                          style: TextStyle(
                            fontFamily: ManagerFontFamily.fontFamily,
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.04),

                    SocialMethodButton(
                      socialName: "Google".tr,
                      screenWidth: screenWidth,
                      socialLogo: AppImages.googlePLogo,
                      onTap: _handleGoogleLogin,
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    InkWell(
                      onTap: () {
                        Get.to(
                              () => AuthSignupView(),
                          transition: Transition.cupertino,
                          duration: const Duration(seconds: 1),
                        );
                      },
                      child: Center(
                        child: RichText(
                          text: TextSpan(
                            text: "Don't have an Account? ".tr,
                            style: TextStyle(
                              fontFamily: ManagerFontFamily.fontFamily,
                              color: Colors.grey[600],
                              fontSize: screenWidth * 0.04,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Sign up'.tr,
                                style: TextStyle(
                                  fontFamily: ManagerFontFamily.fontFamily,
                                  color: const Color(0xFFCE232B),
                                  fontWeight: FontWeight.bold,
                                  fontSize: screenWidth * 0.04,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.05),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

