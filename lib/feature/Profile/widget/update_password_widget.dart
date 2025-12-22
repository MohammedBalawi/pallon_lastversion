import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pallon_lastversion/Core/Utils/manager_fonts.dart';

import '../../../Core/Widgets/common_widgets.dart';
import '../function/profile_function.dart';
import 'custom_text_field.dart';

class UpdatePassword extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _UpdatePassword();
  }
}

class _UpdatePassword extends State<UpdatePassword> {
  bool showPass = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _newPassword = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenWidth  = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: screenHeight * 0.12,
                bottom: screenHeight * 0.03,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF07933E),
                    Color(0xFF007530),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [



                      Expanded(
                        child: Text(
                          'Update Password'.tr,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: ManagerFontFamily.fontFamily,
                            fontSize: screenWidth * 0.06,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Keep your account secure by updating your password regularly."
                        .tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: ManagerFontFamily.fontFamily,
                      fontSize: screenWidth * 0.032,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                color: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18.0,
                    vertical: 20.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF07933E).withOpacity(0.18),
                                  const Color(0xFF07933E).withOpacity(0.10),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.lock_reset_rounded,
                              color: Color(0xFF07933E),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Change Your Password".tr,
                              style: TextStyle(
                                fontFamily: ManagerFontFamily.fontFamily,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF202020),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      buildTextField(
                        context,
                        label: "Enter New Password".tr,
                        icon: Icons.password_rounded,
                        controller: _newPassword,
                        show: !showPass,
                      ),

                      SizedBox(height: screenHeight * 0.02),

                      buildTextField(
                        context,
                        label: "Confirm New Password".tr,
                        icon: Icons.password_rounded,
                        controller: _confirmPassword,
                        show: !showPass,
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 18,
                            color: Color(0xFF888888),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "Password must be at least 6 characters."
                                  .tr,
                              style: TextStyle(
                                fontFamily: ManagerFontFamily.fontFamily,
                                fontSize: 12,
                                color: const Color(0xFF777777),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: screenHeight * 0.065,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_newPassword.text.isNotEmpty) {
                              if (_confirmPassword.text.isNotEmpty) {
                                if (_newPassword.text ==
                                    _confirmPassword.text) {
                                  UpdatePasswordProfile(
                                      _newPassword, context);
                                } else {
                                  showErrorDialog(
                                    context,
                                    "Passwords Not match".tr,
                                  );
                                }
                              } else {
                                showErrorDialog(
                                  context,
                                  "Please Confirm New Password".tr,
                                );
                              }
                            } else {
                              showErrorDialog(
                                context,
                                "Please Enter New Password".tr,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF07933E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                screenWidth * 0.05,
                              ),
                            ),
                            elevation: 6,
                          ),
                          child: Text(
                            'Update Your Password'.tr,
                            style: TextStyle(
                              fontFamily: ManagerFontFamily.fontFamily,
                              fontSize: screenWidth * 0.047,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
