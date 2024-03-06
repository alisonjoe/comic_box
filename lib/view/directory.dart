import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

class DirectoryLoader {
  static Socket? socket; // 在类的作用域内声明套接字变量

  static Future<List<String>> loadDirectory(String host, int port, String username, String password, String directoryPath) async {
    if (kDebugMode) {
      print('loadDirectory begin...');
    }
    try {
      if (kDebugMode) {
        print("loadDirectory begin $host, $port, $username, $password, $directoryPath");
      }
      // 连接到 FTP 服务器
      if (socket == null || socket!.closed) {
        // 如果套接字为空或已关闭，则重新连接
        socket = await Socket.connect(host, port);
        if (kDebugMode) {
          print('Connected to FTP server');
        }
      }


      // 登录到 FTP 服务器
      await _sendCommand(socket, 'USER $username');
      await _readResponse(socket);
      await _sendCommand(socket, 'PASS $password');
      await _readResponse(socket);
      if (kDebugMode) {
        print('Logged in to FTP server');
      }

      // 切换到指定目录
      await _sendCommand(socket, 'CD $directoryPath');
      await _readResponse(socket);
      if (kDebugMode) {
        print("_sendCommand CWD $directoryPath");
      }

      // 列出目录内容
      await _sendCommand(socket, 'DIR');
      String directoryListing = (await _readResponse(socket)) as String;

      // 解析目录内容并返回
      List<String> fileList = directoryListing.trim().split('\r\n');
      // 重置套接字为非阻塞模式
      socket.setOption(SocketOption.tcpNoDelay, true);

      if (kDebugMode) {
        print('Directory listing received');
        print(directoryListing);
      }

      return fileList;
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
      return [];
    }
  }

  static Future<void> _sendCommand(Socket socket, String command) async {
    if (kDebugMode) {
      print('Sending command: $command');
    }
    socket.writeln(command);
    await socket.flush();
  }

  static Future<List<String>> _readResponse(Socket socket) async {
    List<String> responseLines = [];
    try {
      await socket.listen((data) {
        var line = utf8.decode(data);
        if (kDebugMode) {
          print("Received response line: $line");
        }
        responseLines.add(line);
        if (line.endsWith('\r\n')) {
          // 结束监听
          socket.close();
        }
      }).asFuture();
    } on StateError catch (e) {
      // 如果发生了流已经被监听的错误，我们可以忽略它
      if (kDebugMode) {
        print("Error: $e");
      }
    }
    if (kDebugMode) {
      print('Complete response: $responseLines');
    }
    return responseLines;
  }
}
