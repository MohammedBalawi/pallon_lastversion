import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pallon_lastversion/Core/Utils/manager_fonts.dart';
import '../../../Core/Utils/app.images.dart';
import '../view/auth_signin_view.dart';
import 'PinkWaveClipper.dart';


class AuthWelcomeWidget extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _AuthWelcomeWidget();
  }

}


class _AuthWelcomeWidget extends State<AuthWelcomeWidget>{
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Transform.translate(
            offset: const Offset(0, 18),
            child: ClipPath(
              clipper: PinkWaveClipper(),
              child: Container(
                height: screenHeight * 0.6,
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
            clipper: PinkWaveClipper(),
            child: SizedBox(
              height: screenHeight * 0.6,
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
                      fit: BoxFit.fill,
                    ),
                  ),
                  Positioned(
                    top: 100,
                    // right: 10,
                    left: 50,
                    child: SizedBox(
                      width: screenWidth * 0.75,
                      child: Image.asset(
                        AppImages.logo_copy,

                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: ClipPath(
              clipper: WhiteWaveClipper(),
              child: Container(
                height: screenHeight * 0.6,
                color: Colors.white,
              ),
            ),
          ),

          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 160.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: screenHeight * 0.35),
                  Text(
                    'Welcome'.tr,
                    style: TextStyle(
                      fontFamily: ManagerFontFamily.fontFamily,

                      fontSize: screenWidth * 0.1,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF000000),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    'Your journey to a better life starts here.'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: ManagerFontFamily.fontFamily,
                      fontSize: screenWidth * 0.045,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.08),
                  Padding(
                    padding: const EdgeInsets.only(top: 50.0),
                    child: GestureDetector(
                      onTap: () {
                        Get.to(AuthSignInView(),transition: Transition.cupertino,duration: Duration(seconds: 1));
                      },
                      child: Container(
                        width: screenWidth * 0.7,
                        height: screenHeight * 0.07,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCE232B),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFCE232B).withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Continue'.tr,
                              style: TextStyle(
                                fontSize: screenWidth * 0.05,
                                color: Colors.white,
                                fontFamily: ManagerFontFamily.fontFamily,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.03),
                            Container(
                              width: screenWidth * 0.085,
                              height: screenWidth * 0.085,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: SvgPicture.asset(AppImages.arrows),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}