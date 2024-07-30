import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert' as convert;
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:pilipili/components/common/images.dart';
import 'package:pilipili/theme/default.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/crypto.dart';
import 'package:pilipili/utils/networkImage.dart';
import 'package:pilipili/utils/pageviewmixin.dart';

class HomePreviewViewPage extends StatefulWidget {
  HomePreviewViewPage({Key key, this.url = ""}) : super(key: key);
  String url;

  @override
  _HomePreviewViewPageState createState() => _HomePreviewViewPageState();
}

class _HomePreviewViewPageState extends State<HomePreviewViewPage> {
  PageController _controller;
  List<GlobalKey> keyList = [];
  List<TransformationController> transformationControllerList = [];
  int _selectedIndex = 0;
  PhotoViewScaleState scaleState = PhotoViewScaleState.initial;
  bool hasPop = false;
  Map mediaMap = {};

  void setupData() {
    if (widget.url.isEmpty) return;
    mediaMap = convert.jsonDecode(pliDecry(widget.url));

    mediaMap['resources'].forEach((item) {
      GlobalKey _key = GlobalKey();
      TransformationController transformationController =
          TransformationController();
      transformationControllerList.add(transformationController);
      keyList.add(_key);
    });
    _controller = PageController(initialPage: mediaMap['index']);
    _selectedIndex = mediaMap['index'];
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    setupData();
    CommonUtils.setStatusBar(isLight: true);
  }

  @override
  void dispose() {
    super.dispose();
    CommonUtils.setStatusBar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: widget.url.isEmpty
          ? Container()
          : Stack(
              children: [
                Stack(
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragUpdate: (e) {},
                      onTap: () {
                        if (scaleState == PhotoViewScaleState.initial) {
                          context.pop();
                        }
                      },
                      onVerticalDragUpdate: (e) {
                        if (scaleState == PhotoViewScaleState.initial) {
                          if (e.delta.dy > 5 && hasPop == false) {
                            hasPop = true;
                            context.pop();
                          }
                        }
                      },
                      child: PhotoViewGallery.builder(
                        scrollPhysics: const BouncingScrollPhysics(),
                        pageController: _controller,
                        itemCount: mediaMap['resources'].length,
                        onPageChanged: (index) {
                          _selectedIndex = index;
                          setState(() {});
                        },
                        scaleStateChangedCallback: (value) {
                          scaleState = value;
                        },
                        builder: (context, index) {
                          var e = mediaMap['resources'][index];
                          Widget tp = PlatformAwareNetworkImage(
                              fit: BoxFit.contain, url: e);
                          return PhotoViewGalleryPageOptions.customChild(
                            initialScale: 1.0,
                            minScale: 1.0,
                            maxScale: 10.0,
                            child: PageViewMixin(
                              child: tp,
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      child: IgnorePointer(
                        child: Container(
                          height: 80.w,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color.fromRGBO(0, 0, 0, 0.6),
                                Color.fromRGBO(0, 0, 0, 0.0)
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                        child: Column(
                      children: [
                        Container(height: ScreenUtil().statusBarHeight),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          height: DefaultStyle.navbarHegiht,
                          child: Stack(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    child: SizedBox(
                                      height: double.infinity,
                                      child: getImage(
                                          "assets/images/2023/icon_close.png",
                                          width: 24.w,
                                          height: 24.w,
                                          fit: BoxFit.fitWidth,
                                          isAssets: true),
                                    ),
                                    onTap: () {
                                      context.pop();
                                    },
                                  ),
                                  Text(
                                    "${_selectedIndex + 1} / ${mediaMap['resources'].length}",
                                    style: DefaultStyle.white16,
                                  )
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ))
                  ],
                ),
              ],
            ),
    );
  }
}

double initScale({
  @required Size imageSize,
  @required Size size,
  double initialScale,
}) {
  final double n1 = imageSize.height / imageSize.width;
  final double n2 = size.height / size.width;
  if (n1 > n2) {
    final FittedSizes fittedSizes =
        applyBoxFit(BoxFit.contain, imageSize, size);
    //final Size sourceSize = fittedSizes.source;
    final Size destinationSize = fittedSizes.destination;
    return size.width / destinationSize.width;
  } else if (n1 / n2 < 1 / 4) {
    final FittedSizes fittedSizes =
        applyBoxFit(BoxFit.contain, imageSize, size);
    //final Size sourceSize = fittedSizes.source;
    final Size destinationSize = fittedSizes.destination;
    return size.height / destinationSize.height;
  }

  return initialScale;
}
