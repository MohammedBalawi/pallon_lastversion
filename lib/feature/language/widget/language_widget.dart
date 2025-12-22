import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pallon_lastversion/Core/Utils/manager_fonts.dart';

import '../function/language_function.dart';

class LanguageWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LanguageWidget();
  }
}

class _LanguageWidget extends State<LanguageWidget> {
  String? _selectedLang;

  @override
  void initState() {
    super.initState();
    _loadCurrentLang();
  }

  Future<void> _loadCurrentLang() async {
    if (await hasStart()) {
      String? lang = await getStart();
      setState(() {
        _selectedLang = lang;
      });
    }
  }

  void _changeLanguage(String langCode) {
    saveStart(langCode);
    SetLanguagr(context, langCode);
    setState(() {
      _selectedLang = langCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth  = MediaQuery.of(context).size.width;

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "Language".tr,
                      style: TextStyle(
                        fontFamily: ManagerFontFamily.fontFamily,
                        fontSize: screenWidth * 0.06,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      "Choose the language".tr,
                      style: TextStyle(
                        fontFamily: ManagerFontFamily.fontFamily,
                        fontSize: screenWidth * 0.038,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildLanguageCard(
                      context,
                      title: "English".tr,
                      subtitle: "Click here to Choose".tr,
                      flagUrl: "https://flagcdn.com/w40/us.png",
                      langCode: "en",
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    _buildLanguageCard(
                      context,
                      title: "Arabic".tr,
                      subtitle: "Click here to Choose".tr,
                      flagUrl: "https://flagcdn.com/w40/sa.png",
                      langCode: "ar",
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required String flagUrl,
        required String langCode,
      }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSelected = _selectedLang == langCode;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _changeLanguage(langCode),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? const Color(0xFF07933E) : Colors.grey.shade200,
            width: isSelected ? 1.6 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 27,
              backgroundImage: NetworkImage(flagUrl),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: ManagerFontFamily.fontFamily,
                      fontSize: screenWidth * 0.048,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF222222),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: ManagerFontFamily.fontFamily,
                      fontSize: screenWidth * 0.037,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? const Color(0xFF07933E)
                    : Colors.grey.shade200,
              ),
              child: Icon(
                isSelected ? Icons.check : Icons.language,
                size: 16,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
