import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_html/shims/dart_ui_real.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:pilipili/utils/common.dart';

class PlatformAwareAssetImage extends StatefulWidget {
  PlatformAwareAssetImage(
      {Key key,
      this.url,
      this.width,
      this.height,
      this.fit = BoxFit.fill,
      this.clipBehavior = Clip.hardEdge,
      this.filterQuality = FilterQuality.none,
      this.alignment = Alignment.center})
      : super(key: key);
  final String url;
  final double width;
  final double height;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final Clip clipBehavior;
  final FilterQuality filterQuality;

  @override
  _PlatformAwareAssetImageState createState() =>
      _PlatformAwareAssetImageState();
}

class _PlatformAwareAssetImageState extends State<PlatformAwareAssetImage> {
  dynamic _url;
  bool isAnimated = true;
  bool isLoad = false;

  @override
  void didUpdateWidget(covariant PlatformAwareAssetImage oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      CommonUtils.getRealImage(
          url: widget.url,
          imgUrl: _url,
          setUrl: (e) {
            Future.delayed(new Duration(milliseconds: 200), () {
              if (mounted) {
                setState(() {
                  _url = e;
                });
              }
            });
          });
    }
  }

  @override
  void initState() {
    super.initState();
    CommonUtils.getRealImage(
        url: widget.url,
        imgUrl: _url,
        setUrl: (e) {
          Future.delayed(new Duration(milliseconds: 200), () {
            if (mounted) {
              setState(() {
                _url = e;
              });
            }
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return _url != null
        ? Image.memory(
            _url,
            width: widget.width,
            height: widget.height,
            alignment: widget.alignment,
            fit: widget.fit,
            filterQuality: widget.filterQuality,
          )
        : Container(
            width: widget.width,
            height: widget.height,
          );
  }
}

class PlatformAwareNetworkImage extends StatefulWidget {
  PlatformAwareNetworkImage(
      {Key key,
      this.url,
      this.width,
      this.height,
      this.fit = BoxFit.fill,
      this.isVideoThumb = false,
      this.noVisibilityDetector = false,
      this.borderRadius,
      this.clipBehavior = Clip.hardEdge,
      this.filterQuality = FilterQuality.none,
      this.alignment = Alignment.center,
      this.nothumb = false,
      this.background = const Color(0xffFFDFE9)})
      : super(key: key);
  final dynamic url;
  final BoxFit fit;
  final bool isVideoThumb;
  final AlignmentGeometry alignment;
  final bool noVisibilityDetector;
  final BorderRadius borderRadius;
  final Clip clipBehavior;
  final FilterQuality filterQuality;
  final Color background;
  final double width;
  final double height;
  final bool nothumb;
  @override
  _PlatformAwareNetworkImageState createState() =>
      _PlatformAwareNetworkImageState();
}

class _PlatformAwareNetworkImageState extends State<PlatformAwareNetworkImage> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return AwareNetworkImage(
          url: widget.url,
          fit: widget.fit,
          nothumb: widget.nothumb,
          height: constraints.maxHeight,
          width: constraints.maxWidth,
          isVideoThumb: widget.isVideoThumb,
          noVisibilityDetector: widget.noVisibilityDetector,
          borderRadius: widget.borderRadius,
          clipBehavior: widget.clipBehavior,
          filterQuality: widget.filterQuality,
          alignment: widget.alignment,
          background: widget.background);
    });
  }
}

class AwareNetworkImage extends StatefulWidget {
  AwareNetworkImage(
      {Key key,
      this.url,
      this.nothumb,
      this.width,
      this.height,
      this.fit = BoxFit.fill,
      this.isVideoThumb = false,
      this.noVisibilityDetector = false,
      this.borderRadius,
      this.clipBehavior = Clip.hardEdge,
      this.filterQuality = FilterQuality.none,
      this.alignment = Alignment.center,
      this.background})
      : super(key: key);
  final dynamic url;
  final BoxFit fit;
  final bool isVideoThumb;
  final AlignmentGeometry alignment;
  final bool noVisibilityDetector;
  final BorderRadius borderRadius;
  final Clip clipBehavior;
  final FilterQuality filterQuality;
  final Color background;
  final double width;
  final double height;
  final bool nothumb;
  @override
  _AwareNetworkImageState createState() => _AwareNetworkImageState();
}

class _AwareNetworkImageState extends State<AwareNetworkImage> {
  dynamic _url;
  GlobalKey _key = GlobalKey();
  bool isAnimated = true;
  int isLoad = 0;
  Timer delayload;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.noVisibilityDetector) {
      setImgUrl();
    }
  }

  void setImgUrl() {
    if (widget.url == '' || widget.url == null) return;
    if (isLoad != 0) return;
    if (widget.isVideoThumb) return;
    var thumbUrl = '';
    if (widget.width != null && widget.height != null && !widget.nothumb) {
      int idx = widget.url.toString().lastIndexOf('.');
      String prev = widget.url.toString().substring(0, idx);
      String sufix = widget.url.toString().substring(idx);
      double realWidth = widget.width * (window.devicePixelRatio ?? 1);
      if (realWidth < 180) {
        thumbUrl = '$prev!180x0$sufix';
      }
      if (realWidth >= 180 && realWidth < 360) {
        thumbUrl = '$prev!360x0$sufix';
      }
      if (realWidth >= 360 && realWidth < 720) {
        thumbUrl = '$prev!720x0$sufix';
      }
    }
    isLoad = 1;
    CommonUtils.getRealImage(
        url: thumbUrl != '' ? thumbUrl : widget.url,
        imgUrl: _url,
        setUrl: (e) {
          Future.delayed(new Duration(milliseconds: 200), () {
            if (mounted) {
              setState(() {
                _url = e;
                isLoad = 2;
              });
            }
          });
        },
        retryHandler: () {
          CommonUtils.getRealImage(
              url: widget.url,
              imgUrl: _url,
              setUrl: (e) {
                Future.delayed(new Duration(milliseconds: 200), () {
                  if (mounted) {
                    setState(() {
                      _url = e;
                      isLoad = 2;
                    });
                  }
                });
              },
              retryHandler: () {
                if (mounted) {
                  setState(() {
                    isLoad = 0;
                  });
                }
              });
        });
  }

  @override
  void didUpdateWidget(AwareNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.url != oldWidget.url) {
      isLoad = 0;
      setImgUrl();
    }
  }

  void _handleVisibilityChanged(VisibilityInfo info) {
    if (_key == info.key) {
      var visiblePercentage = info.visibleFraction * 100;
      if (visiblePercentage == 0) {
        delayload?.cancel();
        delayload = null;
      } else {
        if (delayload == null) {
          delayload = Timer(new Duration(milliseconds: 500), () {
            setImgUrl();
          });
        }
      }
    }
  }

  Widget imageWidget() {
    bool isShow = (widget.isVideoThumb ? widget.url != null : _url != null);
    return Container(
      width: widget.width,
      height: widget.height,
      clipBehavior: widget.clipBehavior,
      decoration: BoxDecoration(
          color: isShow ? Colors.transparent : widget.background,
          borderRadius: widget.borderRadius ?? null),
      child: Stack(
        children: [
          _url == null
              ? Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: widget.width * 0.7,
                    fit: BoxFit.fitWidth,
                  ),
                )
              : Container(),
          Positioned(
            top: 0,
            right: 0,
            bottom: 0,
            left: 0,
            child: Container(
              alignment: Alignment.center,
              child: !isAnimated || widget.noVisibilityDetector
                  ? (isShow
                      ? Image.memory(
                          widget.isVideoThumb ? widget.url : _url,
                          alignment: widget.alignment,
                          fit: widget.fit,
                          filterQuality: widget.filterQuality,
                        )
                      : Container())
                  : AnimatedContainer(
                      curve: Curves.easeIn,
                      width: isShow ? widget.width : 0,
                      height: isShow ? widget.height : 0,
                      child: isShow
                          ? Image.memory(
                              widget.isVideoThumb ? widget.url : _url,
                              fit: widget.fit,
                              alignment: widget.alignment,
                              filterQuality: widget.filterQuality,
                            )
                          : Container(),
                      duration: Duration(milliseconds: 200)),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.isVideoThumb
        ? imageWidget()
        : VisibilityDetector(
            key: _key,
            onVisibilityChanged: _handleVisibilityChanged,
            child: imageWidget());
  }
}
