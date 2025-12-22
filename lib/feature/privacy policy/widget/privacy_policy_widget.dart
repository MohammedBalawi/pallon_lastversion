import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pallon_lastversion/Core/Utils/manager_fonts.dart';

class PrivacyPolicyWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PrivacyPolicyWidget();
  }
}

class _PrivacyPolicyWidget extends State<PrivacyPolicyWidget> {
  final String privacyPolicyText = """
Privacy Policy

Last Updated: November 2025

Your privacy is important to us. This Privacy Policy explains how we collect, use, and protect your personal information when using our application.

1. Information We Collect:
• Name  
• Phone number  
• Address  
• Profile picture  
• Login credentials  

In addition, we may access your mobile calendar for adding reminders and tasks.

2. How We Use Your Information:
• Maintain your login session  
• Add tasks to your device calendar  
• Send notifications  
• Save and manage pre-orders  
• Improve app performance  

3. Data Sharing:
We do NOT sell your personal information. Data may be shared only with trusted service providers or legal authorities when required.

4. Data Security:
Your data is securely stored using Firebase technologies with appropriate safeguards.

5. User Rights:
Users may request access, correction, or deletion of their data.

6. Updates to the Policy:
Any changes will be updated inside the app.

7. Contact:
For any questions, contact us at: [Your Email]
""";

  @override
  Widget build(BuildContext context) {
    final screenWidth  = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        top: false,
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
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Privacy Policy'.tr,
                      textAlign: TextAlign.center,
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
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 3,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: SingleChildScrollView(
                      child: Text(
                        privacyPolicyText,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontFamily: ManagerFontFamily.fontFamily,
                          fontSize: 15,
                          color: const Color(0xFF333333),
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
