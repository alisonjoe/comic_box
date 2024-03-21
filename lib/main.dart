import 'package:comic_box/view/storage.dart';
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
  late DirectoryLoader _directoryLoader; // 声明_directoryLoader字段
  bool _directoryLoaded = false; // 标志是否已加载目录内容

  @override
  void initState() {
    if (kDebugMode) {
      print("===========main initState init");
    }
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _directoryLoader = DirectoryLoader(config: serverConfigs[0]); // 初始化_directoryLoader字段
    // _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController.index == 1 && !_directoryLoaded) {
      _directoryLoader = DirectoryLoader(config: serverConfigs[0]);
      _loadDirectory();
    }
  }

  // 加载目录内容
  Future<void> _loadDirectory() async {
    try {
      final List<String> directoryContents = await _directoryLoader.loadDirectory();
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
            onTap: (index) {
              if (index == 1 && !_directoryLoaded) { // 点击了第二个标签页且目录尚未加载
                _loadDirectory();
              }
            },
          ),
        ),
    body: TabBarView(
      controller: _tabController,
      children: [
        ListView.builder (
          itemCount: serverConfigs.length,
          itemBuilder: (context, index) {
            final config = serverConfigs[index];
            return ListTile(
              title: Text(config.title),
              onTap: () {
                // 处理点击事件，例如导航到特定页面或执行其他操作
                if (kDebugMode) {
                  print('Clicked on ${config.host}');
                }
              },
            );
          },
        ),
        // 第二个标签页的内容
        _directoryContents.isEmpty
            ? const Center(child: CircularProgressIndicator()) // 加载中
            : ListView.builder(
          itemCount: _directoryContents.length,
          itemBuilder: (context, index) {
            return ListTile(title: Text(_directoryContents[index]));
          },
        ),
        // 第二个Tab对应的页面
        // FutureBuilder(
        //   future: _loadDirectory(), // 执行加载目录内容的方法
        //   builder: (context, snapshot) {
        //     if (snapshot.connectionState == ConnectionState.waiting) {
        //       // 加载中，显示加载指示器
        //       return const Center(child: CircularProgressIndicator());
        //     } else if (snapshot.hasError) {
        //       // 加载出错，显示错误信息
        //       if (kDebugMode) {
        //         print("Error: ${snapshot.error}");
        //       }
        //       return Center(child: Text('Error: ${snapshot.error}'));
        //     } else {
        //       // 加载完成，显示目录内容
        //       return ListView.builder(
        //         itemCount: _directoryContents.length,
        //         itemBuilder: (context, index) {
        //           return GestureDetector(
        //             onTap: () {
        //               // 处理点击事件，例如导航到特定页面或执行其他操作
        //               if (kDebugMode) {
        //                 print('Clicked on ${_directoryContents[index]}');
        //               }
        //             },
        //             child: ListTile(
        //               title: Text(_directoryContents[index]),
        //             ),
        //           );
        //         },
        //       );
        //     }
        //   },
        // ),
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