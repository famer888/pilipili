import 'package:flutter/foundation.dart';

class GlobleValue with ChangeNotifier, DiagnosticableTreeMixin {
  String _yplocation = '全国';
  String get yplocation => _yplocation;
  void setYpLocation(String location) {
    _yplocation = location;
    notifyListeners();
  }
}
