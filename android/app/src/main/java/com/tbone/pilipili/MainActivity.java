package com.tbone.pilipili;

import android.content.Context;
import android.os.Bundle;
import android.os.Environment;
import android.os.StatFs;
import android.os.StrictMode;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import io.flutter.embedding.android.FlutterActivity;

import java.io.File;
import java.util.HashMap;
import java.util.Map;

public class MainActivity extends FlutterActivity {
    private static final String channel = "nativeApi";
    private Context mContext;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
      super.onCreate(savedInstanceState);
      if (android.os.Build.VERSION.SDK_INT >= 9) {
        StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
        StrictMode.setThreadPolicy(policy);
      }

      new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), channel).setMethodCallHandler(
        new MethodChannel.MethodCallHandler() {
          @Override
          public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
            switch (methodCall.method) {
              case "get_disk_space":
                result.success(getDiskSpace(methodCall.method));
                break;
              default:
                result.notImplemented();
                break;
            }
          }
        }
      );
    }

    public double getDiskSpace(String name) {
      // 获取手机数据文件夹
      File path = Environment.getDataDirectory();
      // 获取磁盘状态对象
      StatFs statFs = new StatFs(path.getPath());
      // 获取一个扇区的大小
      long blockSizes = statFs.getBlockSize();
      // 获取可用扇区数量
      long availableBlocksCount = statFs.getAvailableBlocks();
      // 获取可用存储空间 B字节
      double availableMemory = blockSizes * availableBlocksCount;
      return availableMemory;
    }

}
