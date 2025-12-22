import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Core/Widgets/common_widgets.dart';


void SetLanguagr(BuildContext context,String langCode){
  Locale locale;
  try{
    if (langCode == 'ar') {
      locale = const Locale('ar', 'DZ');
    } else {
      locale = const Locale('en', 'US');
    }
    Get.updateLocale(locale).whenComplete((){
      Get.back();
      mesgCustom(context,"Language Updated");
    });
  }
  catch(e){
    ErrorCustom(context, "Filed To Update Language");
  }
}
Future<bool> hasStart() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.containsKey('lang');
}
Future<void> saveStart(String token) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('lang', token);
}
Future<String?> getStart() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('lang');
  return token;
}
Future<void> deleteStart() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('lang');
}