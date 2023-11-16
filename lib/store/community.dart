import 'package:flutter/foundation.dart';

class CommunityStore with ChangeNotifier, DiagnosticableTreeMixin {
  Map<int, bool> _followData = {};
  Map<int, bool> _likeData = {};

  Map get followData => _followData;
  Map get likeData => _likeData;

  void setFollowData(int aff, bool status) {
    _followData = {..._followData, aff: status};
    notifyListeners();
  }

  void setLikeData(int aff, bool status) {
    _likeData = {..._likeData, aff: status};
    notifyListeners();
  }
}
