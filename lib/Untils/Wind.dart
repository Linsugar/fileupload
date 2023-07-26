import 'dart:io';
import 'package:desktop_window/desktop_window.dart';
import 'package:fileupload/Untils/SqlUse.dart';
import 'package:fileupload/Untils/utils.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../main.dart';


class WindowUtil {
  static void init({required double width, required double height}) async {
    WindowOptions windowOptions = WindowOptions(
      size: Size(width, height),
      minimumSize: Size(width, height),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();

    });
  }

  static void setResizable(bool reSize) {
    windowManager.setResizable(reSize);
  }

  static void StartEXE(String Path) async {
    Directory currentDir = Directory.current;
    String currentPath = currentDir.path;
    logger.d('当前文件夹路径：$currentPath/ServerListen.exe');
    String exePath ="$currentPath/ServerListen.exe";
    logger.d("当前传过来的值：${Path}");
    if (Path=="quit"){
      logger.d("进入到这里开始：杀进程");
      Process.run('taskkill', ['/IM', "ServerListen.exe", '/F']).then((result) {
        logger.d(result.stderr);
      });
      ShowToast.ShowToastText("成功停止");
      return;
    }else{
      if (Platform.isWindows) {
        ProcessResult result = await Process.run(exePath, [Path]);
        if (result.exitCode == 0) {
          logger.d('成功启动可执行文件');

        } else {
          logger.d('启动可执行文件时出错：${result.stderr}');
        }
      } else {
        logger.d('当前平台不支持此操作');
      }

    }





  }




}

Future WindowFunctions() async {
  Size size = await DesktopWindow.getWindowSize();
  print(size);
  await DesktopWindow.setWindowSize(Size(1200,700));

  await DesktopWindow.setMinWindowSize(Size(1200,700));
  await DesktopWindow.setMaxWindowSize(Size(1200,700));
  await DesktopWindow.resetMaxWindowSize();

  //await DesktopWindow.toggleFullScreen();
  //bool isFullScreen = await DesktopWindow.getFullScreen();
  //await DesktopWindow.setFullScreen(true);
  await DesktopWindow.setFullScreen(false);
}