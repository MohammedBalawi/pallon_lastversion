import 'dart:convert';

import 'package:flutter/services.dart';

Future<Map<String, Map<String, String>>> loadTranslations() async {
  final enRaw = await rootBundle.loadString('lib/Core/Utils/assets/lang/en.json');
  final arRaw = await rootBundle.loadString('lib/Core/Utils/assets/lang/ar.json');

  final enMap = (jsonDecode(enRaw) as Map).map(
    (k, v) => MapEntry(k.toString(), v.toString()),
  );
  final arMap = (jsonDecode(arRaw) as Map).map(
    (k, v) => MapEntry(k.toString(), v.toString()),
  );

  return {
    'en': enMap,
    'ar': arMap,
  };
}
