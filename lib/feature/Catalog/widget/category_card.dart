import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pallon_lastversion/Core/Utils/app.images.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final bool isAdmin;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CategoryCard({
    Key? key,
    required this.title,
    required this.imageUrl,
    required this.isAdmin,
    this.onTap,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth  = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    const Color mainColor   = Color(0xFF0B5674);
    const Color borderColor = Color(0xFFCE232B);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenHeight * 0.012,
            ),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Row(
                children: [
                  Container(
                    width: screenHeight * 0.08,
                    height: screenHeight * 0.08,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: borderColor,
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.white,
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                          ),
                        ),
                      )
                          : Container(
                        color: Colors.white,
                        child: const Icon(
                          Icons.image,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: screenWidth * 0.04),

                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                        color: mainColor,
                      ),
                    ),
                  ),

                  if (isAdmin) ...[
                    SizedBox(width: screenWidth * 0.02),
                    GestureDetector(
                      onTap: onEdit,
                      child: SvgPicture.asset(
                        AppImages.pans,
                        height: 26,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    GestureDetector(
                      onTap: onDelete,
                      child: SvgPicture.asset(
                        AppImages.iconDeleteAccount,
                        height: 26,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
