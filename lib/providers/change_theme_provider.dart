import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChangeTheme with ChangeNotifier {
  bool _isdarktheme = false;

  bool get isdarktheme => _isdarktheme;

  void darktheme() {
    _isdarktheme = !_isdarktheme;
    notifyListeners();
  }
}
