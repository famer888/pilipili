# pilipili

# 项目须知
1. flutter版本2.5.3，使用fvm确保自己的版本OK
2. 基于chrome调试，由于chrome最小字号是12像素，可能会有一定的显示偏差，如果是要看准确效果，可以build之后，使用http-server生成本地静态站点用safari访问。
3. App端没有 dart:html,只有web端才有，所以在用到 html 的地方需使用 universal_html 兼容。
运行调试命令：fvm flutter run -d chrome --web-renderer html --web-port=9999
构建release命令：fvm flutter build web --web-renderer html --release（输出路径在build/web目录下面）
fvm flutter build web --web-renderer canvaskit --release
http-server --cors -p 8888 -o

4. web端打包完记得把项目中的 waiting.html 放进去
# 目录结构和重要文件说明
utils 基础组件目录
- common.dart 提供一些公共的函数方法
- networkImage.dart 用于展示网络图片
- video.dart 用于展示视频，封装视频解密逻辑等
pages 页面级组件（需注册路由）
components 局部组件
- card 卡片类组件
- common 常用公共组件
- widget 模块化容器组件
mixin - 类混入（用于抽离组件的公共特性，减少代码维护量）
theme/default.dart - 全局样式
global.dart App的全局变量及单例存放类（唯一）
routes.dart 路由（精简了之前的代码，handler融到一个文件了）

打包后html中需加上css 隐藏部分机型的视频控制器
 <style>
  *::-webkit-media-controls-panel {
    display: none !important;
    -webkit-appearance: none;
  }
  *::-webkit-media-controls-play-button {
    display: none !important;
    -webkit-appearance: none;
  }
  *::-webkit-media-controls-start-playback-button {
    display: none !important;
    -webkit-appearance: none;
  }
</style>

## 解决web端全屏问题
cd ~/.pub-cache/hosted/pub.dartlang.org/video_player_web_hls-0.1.11+3/lib  
(video_player_web.dart所在目录，运行命令即可，然后运行命令“open .”打开该目录)

在_VideoPlayer类中添加
void requestFullScreen() {
  videoElement.enterFullscreen();
}
void exitFullScreen() {
  videoElement.exitFullscreen();
}
在VideoPlayerPlugin类中添加
@override
void requestFullScreen(int textureId) {
  _videoPlayers[textureId]!.requestFullScreen();
}
@override
void exitFullScreen(int textureId) {
  _videoPlayers[textureId]!.exitFullScreen();
}
2. video_player_platform_interface.dart的VideoPlayerPlatform类中添加以下代码：
void requestFullScreen(int textureId) {
  throw UnimplementedError('requestFullScreen() has not been implemented.');
}
void exitFullScreen(int textureId) {
  throw UnimplementedError('exitFullScreen() has not been implemented.');
}
3. video_player.dart的VideoPlayerController类中添加以下代码: 
void requestFullScreen() async {
  _videoPlayerPlatform.requestFullScreen(_textureId);
}
void exitFullScreen() async {
  _videoPlayerPlatform.exitFullScreen(_textureId);
}
4. video_player_web_hls.dart
void changeVideo(String newUri) {
  uri = newUri;
  if (isSupported() &&
      (uri.toString().contains("m3u8") || await _testIfM3u8())) {
        _hls.loadSource(uri.toString())
  } else {
    videoElement.src = uri.toString();
    videoElement.load();
  }
}

搜索yifan modify还有一些我都不细写了

# go_router 底层修改
1. pop方法需要添加result
2. push方法增加replace属性，实现路由的replace
void _push(String location, {Object? extra, bool replace = false}) {
    final matches = _getLocRouteMatchesWithRedirects(location, extra: extra);
    assert(matches.isNotEmpty);
    final top = matches.last;

    // remap the pageKey so allow any number of the same page on the stack
    final fullpath = top.fullpath;
    final count = (_pushCounts[fullpath] ?? 0) + 1;
    _pushCounts[fullpath] = count;
    final pageKey = ValueKey('$fullpath-p$count');
    final match = GoRouteMatch(
      route: top.route,
      subloc: top.subloc,
      fullpath: top.fullpath,
      encodedParams: top.encodedParams,
      queryParams: top.queryParams,
      extra: extra,
      pageKey: pageKey,
    );

    // add a new match onto the stack of matches
    assert(matches.isNotEmpty);
    if(replace) {
      _matches.replaceRange(_matches.length - 1, _matches.length, [match]);
    } else {
      _matches.add(match);
    }
  }
3. 解决多手指点击路由同时触发
go_router.dart文件 
顶部引入  import 'dart:async';
GoRouterHelper类的外层定义变量：
bool isClick = true;
GoRouterHelper中的push方法改为

  void push(String location, {Object? extra, bool replace = false}) {
    if (isClick) {
      isClick = false;
      Timer(Duration(milliseconds: 500), () {
        isClick = true;
      });
      return GoRouter.of(this).push(location, extra: extra, replace: replace);
    }
  }

# 对底层java的修改
flutter库video_player exoplayer hls getSegmentEncryptionIV

# 值得一提的第三方库
shelf iOS端用于架设代理服务器访问视频资源，从而实现加解密的处理
flutter_screenutil 屏幕尺寸适配组件
visibility_detector 判定元素是否进入视口的库，后期用于实现图片懒加载
（另外第三方库不一定适用web端，有的虽然写了支持web但实际运行不支持，需要调试做兼容处理）

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## project command
fvm flutter run -d chrome --web-renderer html
fvm flutter build web --web-renderer html --release 打包web
adb devices
fvm flutter build apk --target-platform  android-arm --split-per-abi --no-tree-shake-icons 打包安卓
fvm flutter build ios-framework --output=build/framework --no-tree-shake-icons --no-debug --no-profile --obfuscate --split-debug-info=./symbols 打包iOSSDK

# android key
/usr/libexec/java_home -V
17.0.1, x86_64:     "OpenJDK 17.0.1"        /Users/mac/Library/Java/JavaVirtualMachines/openjdk-17.0.1/Contents/Home
1.8.0_312, x86_64:  "Amazon Corretto 8"     /Users/mac/Library/Java/JavaVirtualMachines/corretto-1.8.0_312/Contents/Home
1.8.0_171, x86_64:  "Java SE 8"     /Library/Java/JavaVirtualMachines/jdk1.8.0_171.jdk/Contents/Home

/Library/Java/JavaVirtualMachines/jdk1.8.0_171.jdk/Contents/Home/bin/keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload


'cover_original_vertical', 封面 原图 竖
'cover_thumb_vertical', 封面 小 竖
'cover_zip_vertical', 封面 中 竖
'cover_original_horizontal', 封面 原图 横
'cover_thumb_horizontal', 封面 小 横
'cover_zip_horizontal', 封面 中 横