import 'dart:async';
import 'dart:io';
import 'package:comic_box/view/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:comic_box/common/toast.dart';
import 'package:comic_box/ftp/ftpconnect.dart';

class DirectoryLoader extends StatelessWidget {
  final ServerConfig config;
  late final FTPConnect _ftpClient;
  const DirectoryLoader({super.key, required this.config});


  Future<List<String>> loadDirectory() async {
    // 连接到FTP服务器
    _ftpClient = FTPConnect(config.host, port: config.port, user: config.user, pass: config.pass);
    await _ftpClient.connect();
    if (kDebugMode) {
      print("==========loadDirectory step 1.");
    }
    List<FTPEntry> listDir = await _ftpClient.listDirectoryContent();

    List<String> filePaths = [];
    // 将域名解析为 IP 地址
    alterShowToast("loadDirectory begin lookup $_host");
    try {
      List<InternetAddress> addresses = await InternetAddress.lookup(_host,
          type: InternetAddressType.any);
      alterShowToast("InternetAddress baidu: $addresses");
      if (addresses.isEmpty) {
        alterShowToast("$_host lookup fail");
        if (kDebugMode) {
          print("$_host lookup fail");
        }
        throw Exception('Failed to resolve host: $_host');
      }
      InternetAddress address = addresses.first;
      _address = address.address;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      alterShowToast(e.toString());
      return [];
    }
    // 连接到FTP服务器
    _ftpClient = FTPConnect(_address, port: _port, user: _user, pass: _pass);
    try {
      bool connected = await _ftpClient.connect();
      if (kDebugMode) {
        print("==========loadDirectory step 1.");
      }
      List<FTPEntry> listDir = await _ftpClient.listDirectoryContent();

      for (FTPEntry dir in listDir) {
        filePaths.add(dir.name);
      }
    } catch (e) {
      alterShowToast(e.toString());
      return [];
    }

    return filePaths;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 处理点击事件，例如导航到特定页面或执行其他操作
        if (kDebugMode) {
          print('Clicked on index');
        }
      },
      child: ListTile(
        title: Text('test'),
      ),
    );
  }
}


// class DirectoryLoader {
//   late final String _host;
//   late final int _port;
//   late final String _user;
//   late final String _pass;
//   late final FTPConnect _ftpClient;
//   late final String _address;
//   DirectoryLoader(String host, int port, String user, String pass):
//    _host = host, _port = port, _user = user, _pass = pass {
//     if (kDebugMode) {
//       print("===========DirectoryLoader init");
//     }
//   }
//   StreamSubscription? _subscription;
//
//   Future<List<String>> loadDirectory(String directoryPath) async {
//     List<String> filePaths = [];
//     // 将域名解析为 IP 地址
//     alterShowToast("loadDirectory begin lookup $_host");
//     try {
//       List<InternetAddress> addresses = await InternetAddress.lookup(_host,
//           type: InternetAddressType.any);
//       alterShowToast("InternetAddress baidu: $addresses");
//       if (addresses.isEmpty) {
//         alterShowToast("$_host lookup fail");
//         if (kDebugMode) {
//           print("$_host lookup fail");
//         }
//         throw Exception('Failed to resolve host: $_host');
//       }
//       InternetAddress address = addresses.first;
//       _address = address.address;
//     } catch (e) {
//       if (kDebugMode) {
//         print(e.toString());
//       }
//       alterShowToast(e.toString());
//       return [];
//     }
//     // 连接到FTP服务器
//     _ftpClient = FTPConnect(_address, port: _port, user: _user, pass: _pass);
//     try {
//       bool connected = await _ftpClient.connect();
//       if (kDebugMode) {
//         print("==========loadDirectory step 1.");
//       }
//       List<FTPEntry> listDir = await _ftpClient.listDirectoryContent();
//
//       for (FTPEntry dir in listDir) {
//         filePaths.add(dir.name);
//       }
//     } catch (e) {
//       alterShowToast(e.toString());
//       return [];
//     }
//
//     return filePaths;
//   }
// }
