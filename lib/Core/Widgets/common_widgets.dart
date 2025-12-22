import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pallon_lastversion/Core/Utils/app.images.dart';

import '../Utils/manager_fonts.dart';


Widget buildProjectCard(BuildContext context,
    {required String title,
      required String status,
      required Color statusColor}) {
  final screenWidth = MediaQuery.of(context).size.width;
  return InkWell(
    // onTap: (){
    //   //Get.to(ProjectView(),transition: Transition.cupertinoDialog,duration: Duration(seconds: 1));
    // },
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(screenWidth * 0.05),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: ManagerFontFamily.fontFamily,

              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF000000),
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                status,
                style: TextStyle(
                  fontFamily: ManagerFontFamily.fontFamily,

                  fontSize: screenWidth * 0.03,
                  fontWeight: FontWeight.w500,
                  color: statusColor,
                ),
              ),
           SvgPicture.asset(AppImages.productShare,color: Color(0xFFCE232B),),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget buildAvatar({bool isMore = false, int count = 0}) {
  return Container(
    width: 25,
    height: 25,
    decoration: BoxDecoration(
      color: isMore ? const Color(0xFFCE232B) : Colors.white,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: 2),
    ),
    child: isMore
        ? Center(
      child: Text(
        '+$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    )
        : null,
  );
}


void ErrorCustom(BuildContext context,String text){
  Get.snackbar('Error'.tr, text,backgroundColor: Colors.red,colorText: Colors.white);

}
void mesgCustom(BuildContext context,String text){
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
      backgroundColor: Colors.green,
    ),
  );
}

void showErrorDialog(BuildContext context , String Error){
  showDialog(
    context: context,
      builder: (BuildContext context){
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          title:  Text(
            'Error'.tr,
            style: TextStyle(
              color: Color(0xFFCE232B),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            Error,
            style: const TextStyle(color: Colors.black87),
          ),
          actions: <Widget>[
            TextButton(
              child:  Text(
                'OK'.tr,
                style: TextStyle(
                  color: Color(0xFF07933E),
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Get.back();
              },
            ),
          ],
        );
      }
  );
}