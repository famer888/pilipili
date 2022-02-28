/*
 * @Author: Tom
 * @Date: 2021-12-21 11:51:44
 * @LastEditTime: 2021-12-27 15:15:12
 * @LastEditors: Tom
 * @Description: 
 * @FilePath: /flutter2021/lib/components/PiliCiyuan.dart
 */
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:youyutv/theme/default.dart';

class PiliCiyuan extends StatefulWidget {
  PiliCiyuan({Key key, this.isShow = false}) : super(key: key);
  final bool isShow;
  @override
  _PiliCiyuanState createState() => _PiliCiyuanState();
}

class _PiliCiyuanState extends State<PiliCiyuan> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
      child: Text(
        'Pili次元',
        style: DefaultStyle.black18bold,
      ),
    ));
  }
}
