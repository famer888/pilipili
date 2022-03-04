//获取精选顶部导航
import 'package:dio/dio.dart';
import 'package:pilipili/model/construct.dart';
import 'package:pilipili/model/element.dart';
import 'package:pilipili/utils/common.dart';

import 'http.dart';

Future<ElementModel> getFisrtTopNavConfig() async {
  try {
    Response<dynamic> res = await PlatformAwareHttp.post(
        '/api/element/getElementById',
        data: {'id': 7});
    ElementModel result = ElementModel.fromJson(res.data['data']);
    return result;
  } catch (e) {
    return null;
  }
}

//获取精选某个栏目的元容元素
Future<ConstructModel> getConstructById({int id, int page, int limit}) async {
  try {
    Response<dynamic> res = await PlatformAwareHttp.post(
        '/api/element/getConstructById',
        data: {'id': id, 'page': page, 'limit': limit});
    if (res.data['status'] == 0) {
      CommonUtils.showText(res.data['msg']);
    }
    ConstructModel result = ConstructModel.fromJson(res.data['data']);
    CommonUtils.debugPrint(result.toJson());
    return result;
  } catch (e) {
    return null;
  }
}

//获取某个栏目的内容元素
Future<dynamic> getElementById({int id, int page, int limit}) async {
  try {
    Response<dynamic> res = await PlatformAwareHttp.post(
        '/api/element/getElementById',
        data: {'id': id, 'page': page, 'limit': limit});
    dynamic result = res.data;
    return result;
  } catch (e) {
    return null;
  }
}
