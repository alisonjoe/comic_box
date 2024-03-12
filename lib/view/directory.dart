import 'dart:async';
import 'dart:developer';
import 'package:comic_box/ftp/ftp_client.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:io';

class DirectoryLoader {
  // String ipStr = "113.118.46.75";
  // String userName = "alisonjoe";
  // String passWord = "Homeisu&me";
  final FTPClient _ftpClient = new FTPClient("113.118.46.75",
      port: 21000, user: "alisonjoe", pass: "Homeisu&me");
  StreamSubscription? _subscription;


  Future<List<String>> loadDirectory(String directoryPath) async {
    if (kDebugMode) {
      print("========loadDirectory begin...");
    }
    // 连接到FTP服务器
    await _ftpClient.connect();
    if (kDebugMode) {
      print("==========loadDirectory step 1.");
    }
    return [];
  }
}
