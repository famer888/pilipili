/*
 * @Author: Tom
 * @Date: 2021-12-28 09:46:10
 * @LastEditTime: 2021-12-28 10:01:36
 * @LastEditors: Tom
 * @Description: 
 * @FilePath: /flutter2021/lib/utils/download_comics.dart
 */
import 'package:isolated_worker/isolated_worker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:pilipili/utils/crypto.dart';
import 'package:hive/hive.dart';
import 'package:pilipili/utils/common.dart';
import 'package:pilipili/utils/index.dart';
import 'package:pilipili/utils/logUtilS.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pilipili/model/comicReading.dart';
import 'package:pilipili/utils/api.dart';
import 'package:pilipili/utils/http.dart';
import 'dart:convert';

Dio dio = Dio();

class DownloadComics {
  static List downloadTasks = []; // 下载任务队列
  static bool downloading = false; // 是否存在下载任务
  static int finishCount = 0; // 当前下载完成的章节数量
  static bool creating = false; // 防止连点
  static bool currentRemove = false; // 当前下载任务是否被删除

  static removeTask(int deteleId) {
    if (downloadTasks.length == 0) {
      return;
    }
    bool haveCurrent = deteleId == downloadTasks[0]["taskInfo"]["id"];
    downloadTasks.removeWhere((e) => e["taskInfo"]["id"] == deteleId);
    if (haveCurrent) {
      downloading = false;
      currentRemove = true;
      startNext();
    }
  }

  // 获取地址
  static Future<String> getPath(String folderName) async {
    var documents;
    if (Platform.isAndroid) {
      documents = await getExternalStorageDirectory();
    } else {
      documents = await getApplicationDocumentsDirectory();
    }
    String _getApplicationDocumentsDirectory = documents.path;
    String _cachePath =
        _getApplicationDocumentsDirectory + '/comics/' + folderName + '/';
    Directory directory = Directory(_cachePath);
    bool isExists = await directory.exists();
    if (!isExists) {
      await directory.create(recursive: true);
    }
    return _cachePath;
  }

  // 初始化下载状态
  static initStatus(int finishNum) {
    downloading = true;
    currentRemove = false;
    finishCount = finishNum;
  }

  // 请求权限
  static Future<bool> getPermission() async {
    PermissionStatus storageStatus = await Permission.storage.status;
    if (storageStatus == PermissionStatus.denied) {
      storageStatus = await Permission.storage.request();
      if (storageStatus == PermissionStatus.denied ||
          storageStatus == PermissionStatus.permanentlyDenied) {
        CommonUtils.showText(
          '您拒绝了存储权限，请前往设置中打开权限',
        );
        return false;
      }
      return true;
    } else if (storageStatus == PermissionStatus.permanentlyDenied) {
      CommonUtils.showText(
        '无法创建下载任务，你关闭了存储权限，请前往设置中打开权限',
      );
      return false;
    }
    return true;
  }

  static createDownloadTask(Map taskInfo) async {
    if (creating) {
      CommonUtils.showText('您点的太快了，请稍后再试');
      return;
    }
    bool havePermission = await getPermission();
    if (havePermission) {
      creating = true;
    } else {
      return;
    }
    try {
      // ComicReading res = await getComicReading(id: taskInfo["id"], episode: 1);
      // LogUtil.d('第一集数据${res.toJson()}');
      Box box = await Hive.openBox('HiveBox');
      // box.delete('download_comics_tasks');
      // downloading = false;
      List tasks = box.get('download_comics_tasks') ?? [];
      int existTaskIndex = tasks.indexWhere((e) => e["id"] == taskInfo["id"]);
      int existDownloadTaskIndex = downloadTasks
          .indexWhere((e) => e["taskInfo"]["id"] == taskInfo["id"]);
      // 存在下载任务
      if (tasks.isNotEmpty && existTaskIndex != -1) {
        if (tasks[existTaskIndex]["downloading"] ||
            tasks[existTaskIndex]["progress"] == taskInfo["allEpisode"] ||
            existDownloadTaskIndex != -1) {
          CommonUtils.showText('已存在下载任务，请不要重复下载');
        } else if (downloading) {
          CommonUtils.showText('已添加下载队列');
          downloadTasks.add({"taskInfo": tasks[existTaskIndex]});
          tasks[existTaskIndex]["isWaiting"] = true;
          box.put("download_comics_tasks", tasks);
        } else {
          CommonUtils.showText('开始继续下载');
          downloadTasks.add({"taskInfo": tasks[existTaskIndex]});
          downloadContent(tasks[existTaskIndex], box);
          tasks[existTaskIndex]["downloading"] = true;
          tasks[existTaskIndex]["isWaiting"] = false;
          box.put("download_comics_tasks", tasks);
        }
        creating = false;
        return;
      }
      CommonUtils.showText('已添加下载任务，请在我的-下载缓存中查看');
      // 获取储存地址
      String saveDirectory =
          await getPath('${DateTime.now().millisecondsSinceEpoch}');
      taskInfo["url"] = saveDirectory;
      // 储存下载任务信息
      taskInfo["progress"] = 0;
      tasks.insert(0, taskInfo);
      box.put("download_comics_tasks", tasks);
      // 添加下载队列
      downloadTasks.add({"taskInfo": taskInfo});
      if (!downloading) {
        taskInfo["downloading"] = true;
        taskInfo["isWaiting"] = false;
        downloadContent(taskInfo, box);
      }
      creating = false;
    } catch (e) {
      LogUtilS.d('创建下载任务失败----${e}');
      CommonUtils.showText('创建下载任务失败');
      creating = false;
    }
  }

  static Future<Map> getTask(int id) async {
    int taskNum;
    List tasks;
    Box box = await Hive.openBox('HiveBox');
    tasks = box.get('download_comics_tasks') ?? [];
    taskNum = tasks.indexWhere((e) => e["id"] == id);
    return {"tasks": tasks, "taskNum": taskNum};
  }

  // 开始下个任务
  static startNext() async {
    LogUtilS.d('开始下个任务----${downloadTasks}');
    if (downloadTasks.length > 0) {
      // LogUtil.d("${downloadTasks[0]["taskInfo"]["title"]}");
      Box box = await Hive.openBox('HiveBox');
      List tasks = box.get('download_comics_tasks') ?? [];
      downloadTasks[0]["taskInfo"]["downloading"] = true;
      int taskNum = tasks
          .indexWhere((e) => e["id"] == downloadTasks[0]["taskInfo"]["id"]);
      // LogUtil.d("${tasks[taskNum]["title"]}");
      tasks[taskNum]["downloading"] = true;
      tasks[taskNum]["isWaiting"] = false;
      box.put("download_comics_tasks", tasks);
      downloadContent(tasks[taskNum], box);
    } else {
      downloading = false;
    }
  }

  static Future<void> downloadContent(Map taskInfo, Box box) async {
    initStatus(taskInfo["progress"]);
    Future start() async {
      // 删除任务中断下载
      if (currentRemove) {
        return;
      }
      try {
        ComicReading res =
            await getComicReading(id: taskInfo["id"], episode: finishCount + 1);
        // LogUtil.d('第${finishCount + 1}集数据${res.toJson()}');

        Map taskBox_1 = await getTask(taskInfo["id"]);
        List tasks_1 = taskBox_1["tasks"];
        int taskNum_1 = taskBox_1["taskNum"];
        // 处理
        int currentImg = 0;
        if (tasks_1[taskNum_1]["sets"].length < finishCount + 1) {
          tasks_1[taskNum_1]["sets"].add([]);
          box.put("download_comics_tasks", tasks_1);
        } else {
          currentImg = tasks_1[taskNum_1]["sets"][finishCount].length;
        }
        // 发送下载初始信息
        EventBus()
            .emit('DOWNLOADCOMICS_PROGRESS_' + taskInfo["id"].toString(), {
          "id": taskInfo["id"],
          "progress": finishCount,
          'currentImg': tasks_1[taskNum_1]["sets"][finishCount].length + 1,
          'imgTotal': res.data.length
        });
        // 创建单集下载文件夹
        String setUrl =
            taskInfo["url"].toString() + (finishCount + 1).toString() + "/";
        Directory directory = Directory(setUrl);
        bool isExists = await directory.exists();
        if (!isExists) {
          await directory.create(recursive: true);
        }
        int _index =
            await downloadItem(res, setUrl, taskInfo["id"], box, currentImg);
        if (currentRemove) {
          return;
        }
        if (_index >= taskInfo["allEpisode"]) {
          // 完成所有章节
          // 存储完成后的下载任务信息
          Map taskBox = await getTask(taskInfo["id"]);
          List tasks = taskBox["tasks"];
          int taskNum = taskBox["taskNum"];
          tasks[taskNum]["downloading"] = false;
          box.put("download_comics_tasks", tasks);
          downloadTasks.removeAt(0);
          startNext();
        } else {
          start();
        }
      } catch (e) {
        LogUtilS.d("下载集报错----${e}");
        // 下载失败，开始下个任务
        Map taskBox = await getTask(taskInfo["id"]);
        List tasks = taskBox["tasks"];
        int taskNum = taskBox["taskNum"];
        tasks[taskNum]["downloading"] = false;
        box.put("download_comics_tasks", tasks);
        downloadTasks.removeAt(0);
        startNext();
        EventBus().emit(
            'DOWNLOADCOMICS_PROGRESS_' + taskInfo["id"].toString(), {
          "id": taskInfo["id"],
          "downloading": false,
          "downloadError": true
        });
      }
    }

    start();
  }

  // 单集下载方法
  static Future<int> downloadItem(ComicReading dataList, String savePath,
      int id, Box box, int current) async {
    int errlimit = 0;
    // 当前完成的图片参数
    int currentImgIndex = current;
    // 单张图片下载
    Future<int> start() async {
      if (currentRemove) {
        return finishCount;
      }
      itemFinish(String url) async {
        Map taskBox1 = await getTask(id);
        List tasks1 = taskBox1["tasks"];
        int taskNum1 = taskBox1["taskNum"];
        tasks1[taskNum1]['sets'][finishCount].add({
          'short': dataList.data[currentImgIndex].short,
          'imgUrl': url,
          'imgWidth': dataList.data[currentImgIndex].imgWidth,
          'imgHeight': dataList.data[currentImgIndex].imgHeight,
        });
        currentImgIndex++;
        if (url != '') {
          // LogUtil.d(
          //     "下载完成----当前图片：${currentImgIndex}/${dataList.data.length}--------当前章节：${finishCount + 1}");
        } else {
          LogUtilS.d("图片为空");
        }
        errlimit = 0;
        if (currentImgIndex >= dataList.data.length) {
          finishCount++;
          tasks1[taskNum1]["progress"] = finishCount;
          box.put("download_comics_tasks", tasks1);
          EventBus().emit('DOWNLOADCOMICS_PROGRESS_' + id.toString(), {
            "id": id,
            "progress": finishCount,
            'currentImg': currentImgIndex,
            'imgTotal': dataList.data.length
          });
          return finishCount;
        } else {
          EventBus().emit('DOWNLOADCOMICS_PROGRESS_' + id.toString(), {
            "id": id,
            "progress": finishCount,
            'currentImg': currentImgIndex + 1,
            'imgTotal': dataList.data.length
          });
          box.put("download_comics_tasks", tasks1);
          return start();
        }
        // LogUtil.d("下载完成----任务列表：$tasks1");
      }

      try {
        // LogUtil.d(
        //     "开始下载----第${currentImgIndex + 1}张图---共${dataList.data.length}张图---当前章节：${finishCount + 1}");
        String data = await PlatformAwareHttp.getImage(
            dataList.data[currentImgIndex].imgUrl);
        if (data != '') {
          dynamic decrypted = await IsolatedWorker()
              .run(PlatformAwareCrypto.decryptImage, data);
          if (decrypted != '' && decrypted != null) {
            decrypted = base64Decode(decrypted);
            File file =
                File(savePath + (currentImgIndex + 1).toString() + ".png");
            await file.writeAsBytes(decrypted);
            //
            return itemFinish(
                savePath + (currentImgIndex + 1).toString() + ".png");
          } else {
            LogUtilS.d("图片解密出错");
            if (errlimit < 5) {
              errlimit++;
              return start();
            }
            return itemFinish('');
          }
        } else {
          LogUtilS.d("获取图片地址出错");
          if (errlimit < 5) {
            errlimit++;
            return start();
          }
          return itemFinish('');
        }
        // IsolatedWorker().run(item, "${savePath}${currentImgIndex + 1}.png");
        // await dio.download(urlPath, savePath,
        //     onReceiveProgress: (int count, int total) {
        //   if (count >= total) {
        //     // 储存下载进度
        //     finishCount++;
        //     List tasks = box.get('download_comics_tasks') ?? [];
        //     int taskNum = tasks.indexWhere((e) => e["id"] == id);
        //     tasks[taskNum]["progress"] = finishCount / tsTotal;
        //     tasks[taskNum]["downloading"] = true;
        //     tasks[taskNum]["tsListsFinished"].add(urlPath);
        //     box.put("download_comics_tasks", tasks);
        //     // LogUtil.d("完成单个任务id---------${id}");
        //     // 发送进度数据
        //     EventBus().emit('DOWNLOADVIDEO_PROGRESS_${id}',
        //         {"id": id, "progress": finishCount / tsTotal});
        //   }
        // });
      } catch (e) {
        LogUtilS.d("下载单图报错-------$e");
        if (errlimit < 5) {
          errlimit++;
          return start();
        }
        return itemFinish('');
      }
    }

    int a = await start();
    return a;
  }
}
