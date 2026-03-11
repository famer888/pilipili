import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pilipili/utils/networkImage.dart';

typedef ScoreFunction = void Function(int score);

class YuemeiScore extends StatefulWidget {
  YuemeiScore(
      {Key? key,
      this.scoreFunction,
      this.size,
      this.interval,
      this.defaultScore,
      this.isSet = true})
      : super(key: key);
  final ScoreFunction? scoreFunction;
  final num? size; //大小
  final num? interval; //间隔
  final int? defaultScore;
  final bool isSet;
  @override
  _YuemeiScoreState createState() => _YuemeiScoreState();
}

class _YuemeiScoreState extends State<YuemeiScore> {
  int curentScore = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    curentScore = widget.defaultScore!;
    }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) => i).asMap().keys.map((e) {
        return GestureDetector(
          onTap: () {
            if (!widget.isSet) return;
            curentScore = e + 1;
            widget.scoreFunction!(curentScore);
                      setState(() {});
          },
          child: Padding(
            padding: EdgeInsets.only(left: widget.interval?.toDouble() ?? 5.w!),
            child: PlatformAwareAssetImage(
              url: 'assets/images/pili_12/' +
                  (curentScore >= e + 1
                      ? 'icon_rate_heart.png'
                      : 'icon_rate_heart_un.png'),
              width: widget.size?.toDouble() ?? 18.w!,
              fit: BoxFit.fitWidth,
            ),
          ),
        );
      }).toList(),
    );
  }
}
