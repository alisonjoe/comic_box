import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'dart:convert';
import 'dart:io';

class DirectoryLoader {
  final FTPConnect _ftpConnect = FTPConnect(
    "113.90.237.103",
    port: 21000,
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



// 发送FTP命令
  void sendCommand(Socket socket, String command) {
    socket.writeln(command);
  }

  // 读取并解析服务器响应
  Future<String> readResponse(Socket socket) async {
    String response = '';
    await for (List<int> bytes in socket) {
      response += utf8.decode(bytes);
      if (response.endsWith('\n')) {
        break;
      }
    }
    return response;
  }



  Future<List<String>> loadDirectory(String directoryPath) async {
    // 连接到FTP服务器
    Socket socket = await Socket.connect('113.90.237.103', 21000);

    // 读取并解析服务器响应
    String response = await readResponse(socket);
    print('Connected: $response');

    // 发送用户名和密码
    sendCommand(socket, 'USER alsionjoe');
    sendCommand(socket, 'PASS Homeisu&me');

    // 读取并解析服务器响应
    response = await readResponse(socket);
    print('Authentication response: $response');

    // 发送其他FTP命令，根据需要进行操作
    sendCommand(socket, 'CWD ./');
    sendCommand(socket, 'LIST');

    // 关闭连接
    socket.close();
    return [];
    try {
      await _log('Connecting to FTP ...');
      await _ftpConnect.connect();
      await _ftpConnect.setTransferType(TransferType.auto);

      // 切换到指定目录
      await _log('Changing directory to $directoryPath ...');
      await _ftpConnect.sendCustomCommand("set ftp:charset utf8");
      await _ftpConnect.changeDirectory(directoryPath);

      // 列出目录内容
      await _log('Listing directory content ...');
      //List<FTPEntry> ftpEntries = await _ftpConnect.listDirectoryContent();
      List<String> ftpEntries = await _ftpConnect.listDirectoryContentOnlyNames();
      if(kDebugMode) {
        print(ftpEntries);
      }

      // 将 FTPEntry 对象转换为文件名的列表
      List<String> directoryContents = [];
      for (var item in ftpEntries) {
        if (kDebugMode) {
          print(item);
        }
        directoryContents.add(item);
      }
      // List<String> directoryContents = ftpEntries.map((entry) => entry.name).toList();
      if (kDebugMode) {
        print("directoryContents: $directoryContents");
      }

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
