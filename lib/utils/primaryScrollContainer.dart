import 'package:flutter/cupertino.dart';

/// ------------------------------
/// PrimaryScrollContainer
/// ------------------------------
class PrimaryScrollContainer extends StatefulWidget {
  final Widget child;

  PrimaryScrollContainer(
    GlobalKey<PrimaryScrollContainerState> key,
    this.child,
  ) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return PrimaryScrollContainerState();
  }
}

class PrimaryScrollContainerState extends State<PrimaryScrollContainer> {
  late ScrollControllerWrapper _scrollController;

  get scrollController {
    final PrimaryScrollController primaryScrollController =
        context.dependOnInheritedWidgetOfExactType(aspect: PrimaryScrollController)!;

    _scrollController.inner = primaryScrollController.controller!;

    return _scrollController;
  }

  @override
  void initState() {
    _scrollController = ScrollControllerWrapper();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryScrollControllerWrapper(
      child: widget.child,
      scrollController: scrollController,
    );
  }

  void onPageChange(bool show) {
    _scrollController.onAttachChange(show);
  }
}

/// ------------------------------
/// PrimaryScrollControllerWrapper
/// ------------------------------
/// 用来覆盖 PrimaryScrollController
/// 适配 Flutter 3.3.0（无 null-safety）
/// ------------------------------
class PrimaryScrollControllerWrapper extends InheritedWidget implements PrimaryScrollController {
  final ScrollController? scrollController;

  const PrimaryScrollControllerWrapper({
    Key? key,
    required Widget child,
    required this.scrollController,
  }) : super(key: key, child: child);

  /// 让 Flutter 识别为 PrimaryScrollController
  @override
  Type get runtimeType => PrimaryScrollController;

  @override
  ScrollController get controller => scrollController!;

  /// 更新机制
  @override
  bool updateShouldNotify(PrimaryScrollControllerWrapper oldWidget) => controller != oldWidget.controller;

  /// Flutter 3.3.0 必须实现的 getter
  /// 哪些平台会自动继承 PrimaryScrollController
  @override
  Set<TargetPlatform> get automaticallyInheritForPlatforms => const <TargetPlatform>{
        TargetPlatform.android,
        TargetPlatform.fuchsia,
        TargetPlatform.linux,
        TargetPlatform.windows,
      };

  /// 某些 Flutter 版本会访问这个 getter
  @override
  bool get automaticallyApplyForPlatform => true;

  /// scrollDirection 用于判断是否继承滚动控制器
  @override
  Axis get scrollDirection => Axis.vertical;
}

/// ------------------------------
/// ScrollControllerWrapper 代理原逻辑（未改动）
/// ------------------------------
class ScrollControllerWrapper implements ScrollController {
  static int a = 1;

  late ScrollController inner;

  int code = a++;

  late ScrollPosition? interceptedAttachPosition;
  late ScrollPosition? lastPosition;

  bool showing = true;

  @override
  void addListener(listener) => inner.addListener(listener);

  @override
  Future<void> animateTo(double offset, {Duration? duration, Curve? curve}) =>
      inner.animateTo(offset, duration: duration!, curve: curve!);

  @override
  void attach(ScrollPosition? position) {
    if (inner.positions.contains(position)) return;

    if (showing) {
      inner.attach(position!);
      lastPosition = position;
    } else {
      interceptedAttachPosition = position;
    }
  }

  @override
  void detach(ScrollPosition? position, {bool fake = false}) {
    if (inner.positions.contains(position)) {
      inner.detach(position!);
    }

    if (position == interceptedAttachPosition && !fake) {
      interceptedAttachPosition = null;
    }
    if (position == lastPosition && !fake) {
      lastPosition = null;
    }

    if (fake) {
      interceptedAttachPosition = position;
    }
  }

  void onAttachChange(bool b) {
    showing = b;

    if (!showing) {
      detach(lastPosition, fake: true);
    } else {
      attach(interceptedAttachPosition);
    }
  }

  @override
  ScrollControllerCallback? get onAttach => inner.onAttach;

  @override
  ScrollControllerCallback? get onDetach => inner.onDetach;

  @override
  ScrollPosition createScrollPosition(ScrollPhysics physics, ScrollContext context, ScrollPosition? oldPosition) =>
      inner.createScrollPosition(physics, context, oldPosition);

  @override
  void debugFillDescription(List<String> description) => inner.debugFillDescription(description);

  @override
  String get debugLabel => inner.debugLabel!;

  @override
  void dispose() => inner.dispose();

  @override
  bool get hasClients => inner.hasClients;

  @override
  bool get hasListeners => inner.hasListeners;

  @override
  double get initialScrollOffset => inner.initialScrollOffset;

  @override
  void jumpTo(double value) => inner.jumpTo(value);

  @override
  bool get keepScrollOffset => inner.keepScrollOffset;

  @override
  void notifyListeners() => inner.notifyListeners();

  @override
  double get offset => inner.offset;

  @override
  ScrollPosition get position => inner.position;

  @override
  Iterable<ScrollPosition> get positions => inner.positions;

  @override
  void removeListener(listener) => inner.removeListener(listener);

  @override
  int get hashCode => inner.hashCode;

  @override
  bool operator ==(other) => hashCode == (other.hashCode);
}
