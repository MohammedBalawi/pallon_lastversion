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
import 'BottomWaveClipper.dart';
import 'PinkWaveClipper.dart';
import 'TopWaveClipper.dart';

class AuthSignupWidget extends StatefulWidget {
  const AuthSignupWidget({Key? key}) : super(key: key);

  @override
  State<AuthSignupWidget> createState() => _AuthSignupWidgetState();
}

class _AuthSignupWidgetState extends State<AuthSignupWidget> {
  File? _image;

  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _pass = TextEditingController();
  final TextEditingController _conPass = TextEditingController();
  final TextEditingController _phone = TextEditingController();

  bool _show = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    _conPass.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignup() async {
    setState(() => _show = true);
    try {
      await SignInWithGoogle(context);
    } finally {
      if (mounted) setState(() => _show = false);
    }
  }

  Future<void> _handleEmailSignup() async {
    if (_image == null) {
      ErrorCustom(context, "Please Choose Your Image Profile".tr);
      return;
    }
    if (_name.text.trim().isEmpty) {
      ErrorCustom(context, "Please Enter Your Name".tr);
      return;
    }
    if (_email.text.trim().isEmpty) {
      ErrorCustom(context, "Please Enter Your Email".tr);
      return;
    }
    if (_phone.text.trim().isEmpty) {
      ErrorCustom(context, "Please Enter Your Phone".tr);
      return;
    }
    if (_pass.text.isEmpty || _pass.text != _conPass.text) {
      ErrorCustom(context, "Password Not Match".tr);
      return;
    }

    setState(() => _show = true);
    try {
      await SignUpMethod(
        _name.text.trim(),
        _image!,
        _email.text.trim(),
        _pass.text.trim(),
        _phone.text.trim(),
        context,
      );
    } finally {
      if (mounted) setState(() => _show = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile =
    await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  InputDecoration _fieldDecoration({
    required double screenHeight,
    required double screenWidth,
    required Widget prefix,
    required String hint,
  }) {
    return InputDecoration(
      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      prefixIcon: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: SizedBox(width: 20, height: 20, child: prefix),
      ),
      hintText: hint,
      hintStyle: TextStyle(
        fontFamily: ManagerFontFamily.fontFamily,
        fontSize: 14,
        color: Colors.grey,
      ),
      filled: true,
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        borderSide: BorderSide.none,
      ),
      contentPadding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.018,
        horizontal: screenWidth * 0.02,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final isRtl = Directionality.of(context) == TextDirection.rtl;

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
                          colors: [Color(0xFF07933E), Color(0xFF007530)],
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

            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              top: 130,
              left: isRtl ? 10 : null,
              right: isRtl ? null : 10,
              child: SizedBox(
                width: screenWidth * 0.45,
                child: Image.asset(AppImages.logo_copy, fit: BoxFit.cover),
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
                      'Sign up'.tr,
                      style: TextStyle(
                        fontFamily: ManagerFontFamily.fontFamily,
                        fontSize: screenWidth * 0.1,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF000000),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),

                    Center(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF007530).withOpacity(0.6),
                                    blurRadius: 20,
                                    spreadRadius: 3,
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: screenWidth * 0.15,
                                backgroundColor: Colors.white,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: screenWidth * 0.14,
                                      backgroundColor: const Color(0xFF007530),
                                      backgroundImage:
                                      _image != null ? FileImage(_image!) : null,
                                      child: _image == null
                                          ? Icon(
                                        Icons.person,
                                        size: screenWidth * 0.15,
                                        color: Colors.grey[300],
                                      )
                                          : null,
                                    ),

                                    Positioned(
                                      bottom: 8,
                                      right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFCE232B),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.camera_alt,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.015),

                          Text(
                            'Click the picture'.tr,
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),


                    Text(
                      'Name'.tr,
                      style: TextStyle(
                        fontFamily: ManagerFontFamily.fontFamily,
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    TextFormField(
                      style: TextStyle(
                        fontFamily: ManagerFontFamily.fontFamily,

                      ),
                      controller: _name,
                      decoration: _fieldDecoration(
                        screenHeight: screenHeight,
                        screenWidth: screenWidth,
                        prefix: const Icon(Icons.person, size: 20),
                        hint: 'UserName'.tr,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.025),

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
                      style: TextStyle(
                        fontFamily: ManagerFontFamily.fontFamily,

                      ),
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _fieldDecoration(
                        screenHeight: screenHeight,
                        screenWidth: screenWidth,
                        prefix: const Icon(Icons.email_outlined, size: 20),
                        hint: 'demo@email.com',
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.025),

                    Text(
                      'Phone no'.tr,
                      style: TextStyle(
                        fontFamily: ManagerFontFamily.fontFamily,
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    TextFormField(
                      style: TextStyle(
                        fontFamily: ManagerFontFamily.fontFamily,

                      ),
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      decoration: _fieldDecoration(
                        screenHeight: screenHeight,
                        screenWidth: screenWidth,
                        prefix: const Icon(Icons.phone_outlined, size: 20),
                        hint: '+00 000-0000-000',
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.025),

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
                      style: TextStyle(
                        fontFamily: ManagerFontFamily.fontFamily,

                      ),
                      controller: _pass,
                      obscureText: true,
                      decoration: _fieldDecoration(
                        screenHeight: screenHeight,
                        screenWidth: screenWidth,
                        prefix: const Icon(Icons.lock_outline, size: 20),
                        hint: 'enter your password'.tr,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.025),

                    Text(
                      'Confirm Password'.tr,
                      style: TextStyle(
                        fontFamily: ManagerFontFamily.fontFamily,
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    TextFormField(
                      style: TextStyle(
                        fontFamily: ManagerFontFamily.fontFamily,

                      ),
                      controller: _conPass,
                      obscureText: true,
                      decoration: _fieldDecoration(
                        screenHeight: screenHeight,
                        screenWidth: screenWidth,
                        prefix: const Icon(Icons.lock_outline, size: 20),
                        hint: 'confirm your password'.tr,
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.035),

                    SocialMethodButton(
                      socialName: "Google".tr,
                      screenWidth: screenWidth,
                      socialLogo: AppImages.googlePLogo,
                      onTap: _handleGoogleSignup,
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    SizedBox(
                      width: double.infinity,
                      height: screenHeight * 0.07,
                      child: ElevatedButton(
                        onPressed: _handleEmailSignup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFCE232B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        child: Text(
                          'Create Account'.tr,
                          style: TextStyle(
                            fontFamily: ManagerFontFamily.fontFamily,
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    InkWell(
                      onTap: () => Get.back(),
                      child: Center(
                        child: RichText(
                          text: TextSpan(
                            text: "Already have an Account? ".tr,
                            style: TextStyle(
                              fontFamily: ManagerFontFamily.fontFamily,
                              color: Colors.grey[600],
                              fontSize: screenWidth * 0.04,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Login'.tr,
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
