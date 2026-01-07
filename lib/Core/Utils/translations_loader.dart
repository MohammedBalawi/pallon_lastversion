import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const _enPath = 'lib/Core/Utils/assets/lang/en.json';
const _arPath = 'lib/Core/Utils/assets/lang/ar.json';
const _fallbackTranslations = {'translation_error': 'Translations unavailable'};
Map<String, Map<String, String>>? _cachedTranslations;

Future<Map<String, Map<String, String>>> loadTranslations() async {
  if (_cachedTranslations != null) {
    return _cachedTranslations!;
  }

  final arMap = await _loadLanguage(_arPath, fallback: _fallbackTranslations);
  final enMap = await _loadLanguage(
    _enPath,
    fallback: arMap.isNotEmpty ? arMap : _fallbackTranslations,
  );

  _cachedTranslations = {
    'en': enMap,
    'ar': arMap,
  };

  return _cachedTranslations!;
}

Future<Map<String, String>> _loadLanguage(
  String path, {
  required Map<String, String> fallback,
}) async {
  try {
    final raw = await rootBundle.loadString(path);
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      debugPrint('Translation file has invalid JSON structure: $path');
      return fallback;
    }
    return decoded.map(
      (k, v) => MapEntry(k.toString(), v.toString()),
    );
  } catch (e) {
    debugPrint('Failed to load translations from $path: $e');
    return fallback;
  }
}
