import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pilipili/theme/default.dart';

class Manhua extends StatefulWidget {
  Manhua({Key key, this.isShow = false}) : super(key: key);
  final bool isShow;
  @override
  _ManhuaState createState() => _ManhuaState();
}

class _ManhuaState extends State<Manhua> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
      child: Text(
        '漫画',
        style: DefaultStyle.black18bold,
      ),
    ));
  }
}
