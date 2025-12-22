import 'package:flutter/material.dart';

Widget CustomTitle(String text,screenWidth){
  return Text(
    text,
    style: TextStyle(
      fontSize: screenWidth * 0.045,
      fontWeight: FontWeight.w600,
    ),
  );
}
Widget CustomData(String text,screenWidth){
  return Text(
    text,
    style: TextStyle(
      fontSize: screenWidth * 0.045,
      fontWeight: FontWeight.w600,
      color: Colors.grey
    ),
  );
}