import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'dart:convert';
import 'dart:io';

class DirectoryLoader {
  static Socket? _socket;
  StreamSubscription? _subscription;

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

  static Future<Socket> get ftpSocket async {
    if (_socket == null || await _socket!.done) {
      if (kDebugMode) {
        print("create new connect");
      }
      // 如果Socket为空或已关闭，则创建一个新的Socket
      try {
        _socket = await Socket.connect("113.110.164.38", 21000); // 使用正确的主机和端口
      } catch (e) {
        // 连接失败，抛出异常
        throw Exception('Failed to connect to FTP server: $e');
      }
    }
    if (kDebugMode) {
      print("coonect succ.");
    }
    return _socket!;
  }

  Future<List<String>> sendAndHandleCommand(Socket socket, String message) async {
    try {
      // 发送消息
      socket.writeln(message);
      if (kDebugMode) {
        print("writeln succ: $message");
      }

      // 定义一个Completer来控制异步处理完成
      Completer<List<String>> completer = Completer<List<String>>();

      _subscription?.cancel(); // 取消之前的监听器

      // 接收消息反馈
      List<String> responseLines = [];
      _subscription = socket.listen((List<int> bytes) {
        String responseString = utf8.decode(bytes);
        if (kDebugMode) {
          print("=================responseString:$responseString");
        }
        List<String> lines = responseString.split('\r\n');
        if (kDebugMode) {
          print("=================lines:$lines");
        }
        for (String line in lines) {
          if (line.trim().isNotEmpty) {
            responseLines.add(line.trim());
            if (kDebugMode) {
              print("Received response: $line");
            }
          }
        }
      }, onError: (error) {
        // 处理错误情况
        if (kDebugMode) {
          print("Error occurred during listening: $error");
        }
        completer.completeError(error); // 将异常传递给Completer
      }, onDone: () {
        // 当流关闭时，表示响应接收完成
        if (kDebugMode) {
          print("=========== onDone.");
        }
        completer.complete(responseLines);
      });

      if (kDebugMode) {
        print("============= return: ${await completer.future}");
      }
      // 返回Completer的Future
      return completer.future;
    } catch (e) {
      // 处理异常
      throw Exception("Failed to handle command: $e");
    }
  }





  Future<List<String>> loadDirectory(String directoryPath) async {
    if (kDebugMode) {
      print("========loadDirectory begin...");
    }
    // 连接到FTP服务器
    // final socket = await DirectoryLoader.socket;
    final socket = await ftpSocket;

    if (kDebugMode) {
      print("==========loadDirectory step 1.");
    }
    // 发送用户名和密码
    List<String> response = await sendAndHandleCommand(socket, "USER alisonjoe");
    if (kDebugMode) {
      print("==========loadDirectory step 1 response:$response, next step 2.");
    }

    if (kDebugMode) {
      print('send username response: $response');
    }

    response = await sendAndHandleCommand(socket, 'PASS Homeisu&me');
    if (kDebugMode) {
      print("==========loadDirectory step 3.");
    }
    // 读取并解析服务器响应
    if (kDebugMode) {
      print('Authentication response: $response');
    }

    // 发送其他FTP命令，根据需要进行操作
    sendAndHandleCommand(socket, 'CWD ./');
    if (kDebugMode) {
      print("==========loadDirectory step 4.");
    }
    sendAndHandleCommand(socket, 'LIST');
    if (kDebugMode) {
      print("==========loadDirectory step 5.");
    }

    // 关闭连接
    socket.close();
    if (kDebugMode) {
      print("==========loadDirectory end.");
    }
    return [];
  }
}
