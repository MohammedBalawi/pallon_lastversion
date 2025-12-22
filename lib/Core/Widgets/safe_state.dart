import 'package:flutter/material.dart';

mixin SafeState<T extends StatefulWidget> on State<T> {
  void safeSetState(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
  }
}
