import 'dart:io';

import 'package:dnsolve/dnsolve.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'view/directory.dart'; // 导入 directory.dart 文件


class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  List<String> _directoryContents = []; // 存储目录内容
  late final DirectoryLoader _directoryLoader;

  // final FTPConnect ftpClient = FTPConnect("113.110.167.133",
  //     port: 21000, user: "alisonjoe", pass: "Homeisu&me");
  bool _directoryLoaded = false; // 标志是否已加载目录内容

  @override
  void initState() {
    if (kDebugMode) {
      print("===========main initState init");
    }
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabSelection);
    String host = "xxx.cn";
    int port = 21;
    String user = "axxx";
    String pass = "xxx";
    _directoryLoader = DirectoryLoader(host, port, user, pass);
  }

  void _handleTabSelection() {
    if (_tabController.index == 1 && !_directoryLoaded) {
      _loadDirectory();
    }
  }

  // 加载目录内容
  Future<void> _loadDirectory() async {
    try {
      final List<String> directoryContents = await _directoryLoader.loadDirectory("./");
      if (kDebugMode) {
        print("==============directoryContents:$_directoryContents");
      }
      setState(() {
        _directoryContents = directoryContents;
        _directoryLoaded = true;
      });
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("Error occurred in _loadDirectory: $e\n$stackTrace");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '源'),
            Tab(text: '目录'),
            Tab(text: '最近观看'),
            Tab(text: '书签'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ListView(
            children: const [
              ListTile(title: Text('漫画1')),
              ListTile(title: Text('漫画2')),
              ListTile(title: Text('漫画3')),
            ],
          ),
          ListView.builder(
            itemCount: _directoryContents.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  // 处理点击事件，例如导航到特定页面或执行其他操作
                  if (kDebugMode) {
                    print('Clicked on ${_directoryContents[index]}');
                  }
                },
                child: ListTile(
                  title: Text(_directoryContents[index]),
                ),
              );
            },
          ),
          const Center(child: Text('最近观看内容')),
          const Center(child: Text('书签内容')),
        ],
      ),
      bottomNavigationBar: kDebugMode ? Text("Total: ${_directoryContents.length}") : null,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}


Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '漫画箱',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: '漫画箱'),
    );
  }
}