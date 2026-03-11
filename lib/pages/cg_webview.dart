import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:pilipili/components/common/pagetitlebar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/utils/common.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

class CgWebview extends StatefulWidget {
  final String? url;
  final String title;
  CgWebview({Key? key, this.url, this.title = ''}) : super(key: key);

  @override
  _CgWebviewState createState() => _CgWebviewState();
}

class _CgWebviewState extends State<CgWebview> {
  late String activityUrl;

  // 需要外部处理的特殊 scheme（其余都留在 WebView 内部）
  static const Set<String> _externalSchemes = {'tel', 'mailto', 'weixin', 'alipays', 'mqqapi', 'intent'};

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      BotToast.cleanAll();
    }
    activityUrl = Uri.decodeComponent(widget.url ?? '');
  }

  @override
  void dispose() {
    super.dispose();
  }

  void jumpOutLink(String msg) {
    CommonUtils.launchURL(msg);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: ScreenUtil().statusBarHeight,
          ),
          PageTitleBar(title: widget.title ?? ''),
          Expanded(
            child: kIsWeb
                ? WebViewX(
                    height: 1.sh,
                    width: 1.sw,
                    initialSourceType: SourceType.url,
                    initialContent: activityUrl ?? '',
                    navigationDelegate: (NavigationRequest request) {
                      return NavigationDecision.navigate;
                    },
                  )
                : InAppWebView(
                    initialOptions: InAppWebViewGroupOptions(
                      crossPlatform: InAppWebViewOptions(
                        javaScriptEnabled: true,
                        mediaPlaybackRequiresUserGesture: false,
                        clearCache: true,
                        transparentBackground: false,
                      ),
                      android: AndroidInAppWebViewOptions(
                        useHybridComposition: true,
                      ),
                    ),
                    initialUrlRequest: URLRequest(
                      url: WebUri(widget.url ?? ''),
                    ),
                    onWebViewCreated: (controller) {
                      // 需要的话在这里保存 controller
                    },
                    onCreateWindow: (controller, createWindowRequest) async {
                      final url = createWindowRequest.request.url?.toString();
                      if (url != null && url.isNotEmpty) {
                        jumpOutLink(url);
                      }
                      return true;
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
