import 'dart:async';
import 'dart:io';
import 'package:comic_box/view/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:comic_box/common/toast.dart';
import 'package:comic_box/ftp/ftpconnect.dart';

class DirectoryLoader {
  final ServerConfig config;
  late FTPConnect _ftpClient;
  String? _address;

  DirectoryLoader({required this.config}) {
    _ftpClient = FTPConnect(config.host, port: config.port, user: config.user, pass: config.pass);
  }

  Future<List<String>> loadDirectory([String directoryPath = '']) async {
    List<String> filePaths = [];

    try {
      // 将域名解析为 IP 地址
      alterShowToast("loadDirectory begin lookup ${config.host}");
      List<InternetAddress> addresses = await InternetAddress.lookup(config.host, type: InternetAddressType.any);
      alterShowToast("InternetAddress baidu: $addresses");
      if (addresses.isEmpty) {
        alterShowToast("${config.host} lookup fail");
        if (kDebugMode) {
          print("${config.host} lookup fail");
        }
        throw Exception('Failed to resolve host: ${config.host}');
      }
      InternetAddress address = addresses.first;
      _address = address.address;

      // 连接到FTP服务器，使用解析到的IP地址
      _ftpClient = FTPConnect(_address!, port: config.port, user: config.user, pass: config.pass);
      await _ftpClient.connect();
      if (kDebugMode) {
        print("==========loadDirectory step 2.");
      }

      // 切换到指定目录
      if (directoryPath.isNotEmpty) {
        await _ftpClient.changeDirectory(directoryPath);
      }

      List<FTPEntry> listDir = await _ftpClient.listDirectoryContent();

      for (FTPEntry dir in listDir) {
        filePaths.add(dir.name);
      }

      return filePaths;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      alterShowToast(e.toString());
      return [];
    }
  }
}
