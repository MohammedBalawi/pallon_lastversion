import 'package:flutter/material.dart';
import 'package:pallon_lastversion/Core/Utils/manager_fonts.dart';

Widget buildTextField(
    BuildContext context, {
      required bool show,
      required String label,
      required IconData icon,
      required TextEditingController controller,
    }) {
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontFamily: ManagerFontFamily.fontFamily,
          fontSize: screenWidth * 0.045,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF07933E),
        ),
      ),

      SizedBox(height: screenHeight * 0.01),

      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextFormField(
          controller: controller,
          obscureText: show,
          style: TextStyle(
            fontFamily: ManagerFontFamily.fontFamily,
            fontSize: screenWidth * 0.04,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            prefixIcon: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF07933E).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF07933E),
              ),
            ),
            hintText: label,
            hintStyle: TextStyle(
              fontFamily: ManagerFontFamily.fontFamily,
              fontSize: screenWidth * 0.04,
              color: Colors.grey,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(screenWidth * 0.04),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.02,
              horizontal: screenWidth * 0.04,
            ),
          ),
        ),
      ),
    ],
  );
}
