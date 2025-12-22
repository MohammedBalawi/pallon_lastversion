import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../main.dart';

void showAppSnack(String message, {bool error = false}) {
  final messenger = rootMessengerKey.currentState;
  if (messenger == null) return;

  messenger.clearSnackBars();
  messenger.showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: error ? const Color(0xFFCE232B) : const Color(0xFF07933E),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ),
  );
}
