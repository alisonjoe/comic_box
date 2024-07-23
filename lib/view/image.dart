import 'dart:convert';
import 'dart:typed_data';
import 'package:comic_box/view/storage.dart';
import 'package:flutter/material.dart';
import 'package:comic_box/ftp/ftpconnect.dart';
import '../ftp/src/ftp_reply.dart'; // 导入你的FTP处理实现

class ImageViewer extends StatefulWidget {
  final String imageUrl;

  const ImageViewer({Key? key, required this.imageUrl}) : super(key: key);

  @override
  _ImageViewerState createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  late Uint8List _imageBytes;
  bool _loading = true;

  late final ServerConfig config;
  late FTPConnect _ftpClient;
  String? _address;



  @override
  void initState() {
    super.initState();
    _initFtpClient();
    _loadImage();
  }

  void _initFtpClient() {
    config = serverConfigs[0];
    _ftpClient = FTPConnect(config.host,
        port: config.port,
        user: config.user,
        pass: config.pass);
  }

  Future<void> _loadImage() async {
    try {
      await _ftpClient.connect();

      // 发送自定义的FTP命令获取文件内容
      String command = 'RETR ${widget.imageUrl}';
      FTPReply response = await _ftpClient.sendCustomCommand(command);

      // 检查响应是否成功
      if (!response.isSuccessCode()) {
        throw Exception('FTP command $command failed: ${response.toString()}');
      }

      // 解析FTPReply中的文件内容，这里假设使用 UTF-8 编码将响应内容转换为字节流
      List<int> fileData = utf8.encode(response.message);

      // 将List<int>转换为Uint8List
      _imageBytes = Uint8List.fromList(fileData);

      // 更新UI显示图片
      setState(() {
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('加载图片失败'),
            content: Text('$e'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('确定'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('图片浏览器'),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _imageBytes.isEmpty
          ? Center(child: Text('加载图片失败'))
          : Center(
        child: Image.memory(
          _imageBytes,
          fit: BoxFit.contain,
          width: double.infinity,
        ),
      ),
    );
  }
}
