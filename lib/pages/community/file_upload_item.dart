import 'package:flutter/material.dart';

class FileUploadItem extends StatefulWidget {
  const FileUploadItem({Key key, this.index}):super(key: key);
  final int index;

  @override
  State<FileUploadItem> createState() => _FileUploadItemState();
}

class _FileUploadItemState extends State<FileUploadItem> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('${widget.index}*********initState');
  }

  @override
  void dispose() {
    print('${widget.index}*********dispose');
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
    );
  }
}