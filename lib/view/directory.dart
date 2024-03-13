import 'dart:async';
import 'package:comic_box/ftp/ftpconnect.dart';
import 'package:flutter/foundation.dart';

class DirectoryLoader {
  late final String _host;
  late final int _port;
  late final String _user;
  late final String _pass;
  late final FTPConnect _ftpClient;
  DirectoryLoader(String host, int port, String user, String pass):
  _host = host, _port = port, _user = user, _pass = pass {
    if (kDebugMode) {
      print("===========DirectoryLoader init");
    }
  }
  StreamSubscription? _subscription;

  Future<List<String>> loadDirectory(String directoryPath) async {
    // final FTPConnect ftpClient = FTPConnect("113.110.167.133",
    //     port: 21000, user: "alisonjoe", pass: "Homeisu&me");
    // if (kDebugMode) {
    //   print("========loadDirectory begin...");
    // }
    // 连接到FTP服务器
    _ftpClient = FTPConnect(_host, port: _port, user: _user, pass: _pass);
    await _ftpClient.connect();
    if (kDebugMode) {
      print("==========loadDirectory step 1.");
    }
    List<FTPEntry> listDir = await _ftpClient.listDirectoryContent();

    List<String> filePaths = [];
    for (FTPEntry dir in listDir) {
      filePaths.add(dir.name);
    }

    return filePaths;
  }
}
