/*
 * Copyright (c) 2015-2019 StoneHui
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

library gesture_zoom_box;

import 'dart:math';

import 'package:flutter/material.dart';

/// 可缩放/平移的盒子小部件
class GestureZoomBox extends StatefulWidget {
  final double maxScale;
  final double doubleTapScale;
  final bool isHorizontal; //左右翻页
  final Widget? child;
  final VoidCallback? onPressed;
  final Duration duration;

  /// 通过最大缩放比例 [maxScale]、双击缩放比例 [doubleTapScale]、子部件 [child]、点击事件 [onPressed] 创建小部件
  const GestureZoomBox({
    Key? key,
    this.maxScale = 5.0,
    this.doubleTapScale = 2.0,
    @required this.child,
    this.onPressed,
    this.duration = const Duration(milliseconds: 200),
    this.isHorizontal = false,
  })  : assert(maxScale >= 1.0),
        assert(doubleTapScale >= 1.0 && doubleTapScale <= maxScale),
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _GestureZoomBoxState();
  }
}

class _GestureZoomBoxState extends State<GestureZoomBox>
    with TickerProviderStateMixin {
  GlobalKey _key = GlobalKey();
  // 缩放动画控制器
  late AnimationController _scaleAnimController;
  //点击的位置
  double downOffsetY = 0;
  double downOffsetX = 0;
  //移动位置
  double upOffsetY = 0;
  double upOffsetX = 0;
  //拖放距离
  double offsetY = 0;
  double offsetX = 0;
  //松手位置
  double letfX = 0;
  double letfY = 0;
  // 偏移动画控制器
  late AnimationController _offsetAnimController;

  // 上次缩放变化数据
  late ScaleUpdateDetails _latestScaleUpdateDetails;

  // 当前缩放值
  double _scale = 1.0;

  // 当前偏移值
  Offset _offset = Offset.zero;

  // 双击缩放的点击位置
  late Offset _doubleTapPosition;

  bool _isScaling = false;
  bool _isDragging = false;

  // 拖动超出边界的最大值
  double _maxDragOver = 100;
  // 检测边界
  detectionBoundary(double x, double y) {
    upOffsetX = x;
    upOffsetY = y;
    offsetX = widget.isHorizontal ? 0 : (downOffsetX - upOffsetX) + letfX;
    offsetY = widget.isHorizontal ? (downOffsetY - upOffsetY) + letfY : 0;
    setState(() {});
  }

  intOffset() {
    //点击的位置
    downOffsetY = 0;
    downOffsetX = 0;
    //移动位置
    upOffsetY = 0;
    upOffsetX = 0;
    //拖放距离
    offsetY = 0;
    offsetX = 0;
    //松手位置
    letfX = 0;
    letfY = 0;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..translate(_offset.dx, _offset.dy)
        ..scale(_scale, _scale),
      child: Listener(
        onPointerUp: _onPointerUp,
        onPointerDown: (PointerDownEvent e) {
          downOffsetX = e.localPosition.dx;
          downOffsetY = e.localPosition.dy;
        },
        // onPointerMove: (PointerMoveEvent e) {
        //   if (_scale > 1) {
        //     //放大后才可以拖动
        //     detectionBoundary(e.localPosition.dx, e.localPosition.dy);
        //   }
        // },
        child: GestureDetector(
            onTap: widget.onPressed,
            // onDoubleTap: _onDoubleTap,
            onScaleStart: _onScaleStart,
            onScaleUpdate: _onScaleUpdate,
            onScaleEnd: _onScaleEnd,
            child: widget.child
            // Transform.translate(
            //   offset: Offset(-offsetX, -offsetY),
            //   child: Container(
            //       width: GVScreenUtil.screenWidth,
            //       height: double.infinity,
            //       key: _key,
            //       child: ),
            // ),
            ),
      ),
    );
  }

  @override
  void dispose() {
    _scaleAnimController.dispose();
    _offsetAnimController.dispose();
    super.dispose();
  }

  /// 处理手指抬起事件 [event]
  _onPointerUp(PointerUpEvent event) {
    // letfX = offsetX;
    // letfY = offsetY;
    _doubleTapPosition = event.localPosition;
    // RenderBox renderBox = _key.currentContext.findRenderObject();
    // Offset offset = renderBox.localToGlobal(Offset(0, 0));
    // //左
    // if (offset.dx >= 0) {
    //   letfX = offsetX - offset.dx;
    //   offsetX = offsetX - offset.dx;
    //   setState(() {});
    // }
    // //右
    // if (offset.dx.abs() + GVScreenUtil.screenWidth >=
    //     renderBox.size.width * _scale) {
    //   letfX = ((renderBox.size.width * _scale) - GVScreenUtil.screenWidth) / 2;
    //   offsetX =
    //       (((renderBox.size.width * _scale) - GVScreenUtil.screenWidth) / 2);
    //   setState(() {});
    // }
    // //上
    // if (offset.dy >= GVScreenUtil.statusBarHeight) {
    //   return;
    // }
    // //下
    // if (offset.dy <=
    //     -(renderBox.size.height * _scale - GVScreenUtil.screenHeight)) {}
  }

  /// 处理双击
  _onDoubleTap() {
    intOffset();
    double targetScale = _scale == 1.0 ? widget.doubleTapScale : 1.0;
    _animationScale(targetScale);
    if (targetScale == 1.0) {
      _animationOffset(Offset.zero);
    }
  }

  _onScaleStart(ScaleStartDetails details) {
    _scaleAnimController.stop();
    _offsetAnimController.stop();
    _isScaling = false;
    _isDragging = false;
    _latestScaleUpdateDetails = null!;
  }

  /// 处理缩放变化 [details]
  _onScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      if (details.scale != 1.0) {
        _scaling(details);
      } else {
        _dragging(details);
      }
    });
  }

  /// 执行缩放
  _scaling(ScaleUpdateDetails details) {
    if (_isDragging) {
      return;
    }
    _isScaling = true;

    // 计算缩放比例
    double scaleIncrement = details.scale - _latestScaleUpdateDetails.scale;
    if (details.scale < 1.0 && _scale > 1.0) {
      scaleIncrement *= _scale;
    }
    if (_scale < 1.0 && scaleIncrement < 0) {
      scaleIncrement *= (_scale - 0.5);
    } else if (_scale > widget.maxScale && scaleIncrement > 0) {
      scaleIncrement *= (2.0 - (_scale - widget.maxScale));
    }
    _scale = max(_scale + scaleIncrement, 0.0);

    // 计算缩放后偏移前（缩放前后的内容中心对齐）的左上角坐标变化
    double scaleOffsetX = context.size!.width * (_scale - 1.0) / 2;
    double scaleOffsetY = context.size!.height * (_scale - 1.0) / 2;
    // 将缩放前的触摸点映射到缩放后的内容上
    double scalePointDX =
        (details.localFocalPoint.dx + scaleOffsetX - _offset.dx) / _scale;
    double scalePointDY =
        (details.localFocalPoint.dy + scaleOffsetY - _offset.dy) / _scale;
    // 计算偏移，使缩放中心在屏幕上的位置保持不变
    _offset += Offset(
      (context.size!.width / 2 - scalePointDX) * scaleIncrement,
      (context.size!.height / 2 - scalePointDY) * scaleIncrement,
    );

    _latestScaleUpdateDetails = details;
  }

  /// 执行拖动
  _dragging(ScaleUpdateDetails details) {
    if (_isScaling) {
      return;
    }
    _isDragging = true;

    // 计算本次拖动增量
    double offsetXIncrement = (details.localFocalPoint.dx -
            _latestScaleUpdateDetails.localFocalPoint.dx) *
        _scale;
    double offsetYIncrement = (details.localFocalPoint.dy -
            _latestScaleUpdateDetails.localFocalPoint.dy) *
        _scale;
    // ���理 X 轴边���
    double scaleOffsetX = context.size!.width * (_scale - 1.0) / 2;
    if (scaleOffsetX <= 0) {
      offsetXIncrement = 0;
    } else if (_offset.dx > scaleOffsetX) {
      offsetXIncrement *=
          (_maxDragOver - (_offset.dx - scaleOffsetX)) / _maxDragOver;
    } else if (_offset.dx < -scaleOffsetX) {
      offsetXIncrement *=
          (_maxDragOver - (-scaleOffsetX - _offset.dx)) / _maxDragOver;
    }
    // 处理 Y 轴边界
    double scaleOffsetY =
        (context.size!.height * _scale - MediaQuery.of(context).size.height) / 2;
    if (scaleOffsetY <= 0) {
      offsetYIncrement = 0;
    } else if (_offset.dy > scaleOffsetY) {
      offsetYIncrement *=
          (_maxDragOver - (_offset.dy - scaleOffsetY)) / _maxDragOver;
    } else if (_offset.dy < -scaleOffsetY) {
      offsetYIncrement *=
          (_maxDragOver - (-scaleOffsetY - _offset.dy)) / _maxDragOver;
    }

    _offset += Offset(offsetXIncrement, offsetYIncrement);

    _latestScaleUpdateDetails = details;
  }

  /// 缩放/���动��束
  _onScaleEnd(ScaleEndDetails details) {
    if (_scale < 1.0) {
      // 缩放值过小，恢复到 1.0
      _animationScale(1.0);
    } else if (_scale > widget.maxScale) {
      // 缩放值过大，恢复到最大值
      _animationScale(widget.maxScale);
    }
    if (_scale <= 1.0) {
      // 缩放值过小，修改偏移值，使内容居中
      _animationOffset(Offset.zero);
    } else if (_isDragging) {
      // 处理拖动超过边界的情况（自动回弹到边界）
      double realScale = _scale > widget.maxScale ? widget.maxScale : _scale;
      double targetOffsetX = _offset.dx, targetOffsetY = _offset.dy;
      // 处理 X 轴边界
      double scaleOffsetX = context.size!.width * (realScale - 1.0) / 2;
      if (scaleOffsetX <= 0) {
        targetOffsetX = 0;
      } else if (_offset.dx > scaleOffsetX) {
        targetOffsetX = scaleOffsetX;
      } else if (_offset.dx < -scaleOffsetX) {
        targetOffsetX = -scaleOffsetX;
      }
      // 处理 Y 轴边界
      double scaleOffsetY = (context.size!.height * realScale -
              MediaQuery.of(context).size.height) /
          2;
      if (scaleOffsetY < 0) {
        targetOffsetY = 0;
      } else if (_offset.dy > scaleOffsetY) {
        targetOffsetY = scaleOffsetY;
      } else if (_offset.dy < -scaleOffsetY) {
        targetOffsetY = -scaleOffsetY;
      }
      if (_offset.dx != targetOffsetX || _offset.dy != targetOffsetY) {
        // 启动越界回弹
        _animationOffset(Offset(targetOffsetX, targetOffsetY));
      } else {
        // 处理 X 轴边界
        double duration =
            (widget.duration.inSeconds + widget.duration.inMilliseconds / 1000);
        Offset targetOffset =
            _offset + details.velocity.pixelsPerSecond * duration;
        targetOffsetX = targetOffset.dx;
        if (targetOffsetX > scaleOffsetX) {
          targetOffsetX = scaleOffsetX;
        } else if (targetOffsetX < -scaleOffsetX) {
          targetOffsetX = -scaleOffsetX;
        }
        // 处理 X 轴边界
        targetOffsetY = targetOffset.dy;
        if (targetOffsetY > scaleOffsetY) {
          targetOffsetY = scaleOffsetY;
        } else if (targetOffsetY < -scaleOffsetY) {
          targetOffsetY = -scaleOffsetY;
        }
        // 启动惯性滚动
        _animationOffset(Offset(targetOffsetX, targetOffsetY));
      }
    }

    _isScaling = false;
    _isDragging = false;
    _latestScaleUpdateDetails = null!;
  }

  /// 执行动画缩放内容到 [targetScale]
  _animationScale(double targetScale) {
    _scaleAnimController.dispose();
    _scaleAnimController =
        AnimationController(vsync: this, duration: widget.duration);
    Animation anim = Tween<double>(begin: _scale, end: targetScale)
        .animate(_scaleAnimController);
    anim.addListener(() {
      setState(() {
        _scaling(ScaleUpdateDetails(
          focalPoint: _doubleTapPosition,
          localFocalPoint: _doubleTapPosition,
          scale: anim.value,
          horizontalScale: anim.value,
          verticalScale: anim.value,
        ));
      });
    });
    anim.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onScaleEnd(ScaleEndDetails());
      }
    });
    _scaleAnimController.forward();
  }

  /// 执行动画偏移内容到 [targetOffset]
  _animationOffset(Offset targetOffset) {
    _offsetAnimController.dispose();
    _offsetAnimController =
        AnimationController(vsync: this, duration: widget.duration);
    Animation anim = _offsetAnimController
        .drive(Tween<Offset>(begin: _offset, end: targetOffset));
    anim.addListener(() {
      setState(() {
        _offset = anim.value;
      });
    });
    _offsetAnimController.fling();
  }
}
