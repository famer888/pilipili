import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pilipili/global.dart';
import 'package:pilipili/utils/api.dart';

class Search with ChangeNotifier {
  List<dynamic> get historyTags => _historyTags;
  late List<dynamic> _historyTags;
  List<String> get hotTags => _hotTags;
  late List<String> _hotTags;

  int get currentPage => _currentPage;
  late int _currentPage;
  int get tabIndex => _tabIndex;
  late int _tabIndex;

  Future<void> init() async {
    _tabIndex = 0;
    _currentPage = 0;
    _historyTags = AppGlobal.appBox!.get('search_history') ?? [];
    var res = await gethotTags();
    if (res['status'] != 0) {
      _hotTags = List<String>.from(res['data'] ?? []);
    }
  }

  void addHistoryTag(String tag) {
    _historyTags.add(tag);
    AppGlobal.appBox!.put('search_history', _historyTags);
    notifyListeners();
  }

  void removeHistoryTag(String tag) {
    _historyTags.remove(tag);
    AppGlobal.appBox!.put('search_history', _historyTags);
    notifyListeners();
  }

  void clearHistoryTag() {
    _historyTags.clear();
    AppGlobal.appBox!.put('search_history', _historyTags);
    notifyListeners();
  }
}
