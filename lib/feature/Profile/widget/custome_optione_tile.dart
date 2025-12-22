import 'package:flutter/material.dart';
import 'package:pallon_lastversion/Core/Utils/manager_fonts.dart';

Widget buildOptionTile(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
    ) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      splashColor: const Color(0xFF07933E).withOpacity(0.1),
      highlightColor: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF07933E).withOpacity(0.20),
                    const Color(0xFF07933E).withOpacity(0.10),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF07933E),
                size: 24,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: ManagerFontFamily.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF222222),
                ),
              ),
            ),

            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey.shade500,
              size: 26,
            ),
          ],
        ),
      ),
    ),
  );
}
