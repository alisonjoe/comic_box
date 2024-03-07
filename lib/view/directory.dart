import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:ftpconnect/ftpconnect.dart';

class DirectoryLoader {
  final FTPConnect _ftpConnect = FTPConnect(
    "alisonjoe.tpddns.cn",
    user: "alisonjoe",
    pass: "Homeisu&me",
    showLog: true,
  );

  ///an auxiliary function that manage showed log to UI
  Future<void> _log(String log) async {
    if (kDebugMode) {
      print(log);
    }
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<List<String>> loadDirectory(String directoryPath) async {
    try {
      await _log('Connecting to FTP ...');
      await _ftpConnect.connect();

      // 切换到指定目录
      await _log('Changing directory to $directoryPath ...');
      await _ftpConnect.changeDirectory(directoryPath);

      // 列出目录内容
      await _log('Listing directory content ...');
      List<FTPEntry> ftpEntries = await _ftpConnect.listDirectoryContent();

      // 将 FTPEntry 对象转换为文件名的列表
      List<String> directoryContents = ftpEntries.map((entry) => entry.name).toList();

      await _log('Directory listing received');
      return directoryContents;
    } catch (e) {
      await _log('Error: ${e.toString()}');
      return [];
    } finally {
      // 关闭连接
      await _log('Disconnecting from FTP ...');
      await _ftpConnect.disconnect();
    }
  }
}
