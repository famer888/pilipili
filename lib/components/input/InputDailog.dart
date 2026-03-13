import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pilipili/components/input/InputWidget.dart';

class InputDialog {
  static Future<Future<String?>> show(BuildContext context, String tips,
      {int? limitingText,
      TextInputType? boardType,
      String? btnText,
      String? value}) async {
    return Navigator.of(context).push(InputOverlay(
        value: value,
        tips: tips,
        limitingText: limitingText,
        boardType: boardType,
        btnText: btnText));
  }
}

class InputOverlay extends ModalRoute<String> {
  final String? tips;
  final int? limitingText;
  final TextInputType? boardType;
  final String? btnText;
  final String? value;
  InputOverlay(
      {this.tips,
      this.value,
      @required this.limitingText,
      @required this.boardType,
      this.btnText});

  @override
  Duration get transitionDuration => Duration(milliseconds: 200);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => true;

  @override
  Color get barrierColor => const Color(0x01000000);

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return InputWidget(
        tips: tips,
        limitingText: limitingText!,
        boardType: boardType!,
        value: value,
        btnText: btnText);
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      ),
      child: child,
    );
  }
}
