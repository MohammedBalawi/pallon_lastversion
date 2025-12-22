import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pallon_lastversion/Core/Utils/manager_fonts.dart';

class TermOfUseWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TermOfUseWidget();
  }
}

class _TermOfUseWidget extends State<TermOfUseWidget> {
  final String termsOfUseText = """
Terms of Use

Last Updated: November 2025

Welcome to [Your App Name]! By using our app, you agree to comply with the following terms:

1. Acceptance of Terms
By using the app, you agree to these Terms.

2. Use of the App
• The app is for personal and non-commercial use.  
• You agree not to misuse, damage, or attempt to disrupt the app or its services.

3. User Accounts
• You must provide accurate and up-to-date personal information.  
• You are responsible for keeping your login credentials secure and confidential.

4. Calendar and Notifications
• The app may access your device calendar to add events or tasks.  
• The app may send notifications related to your orders, tasks, or updates.

5. Data Privacy
All data collection and usage follow our Privacy Policy.  
Please review the Privacy Policy for more information.

6. Intellectual Property
All content, logos, design, and features in this app are owned by [Your Company/You].  
You agree not to copy, modify, distribute, or use any content without written permission.

7. Limitation of Liability
The app is provided “as is,” without warranties of any kind.  
We are not responsible for any direct or indirect damages resulting from the use of the app.

8. Modifications
We may update or modify these Terms or the app features at any time.  
Continued use of the app after updates means you accept the new Terms.

9. Governing Law
These Terms are governed by the laws of [Your Country].  
Any disputes will be handled by the competent courts in that jurisdiction.

10. Contact Us
For questions about these Terms, contact us at: [Your Email]
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
                      'Terms of Use'.tr,
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
                        termsOfUseText,
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
