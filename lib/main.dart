import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'view/directory.dart'; // 导入 directory.dart 文件

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<String> _directoryContents = []; // 存储目录内容
  final DirectoryLoader _directoryLoader = DirectoryLoader(); // 创建一个单独的DirectoryLoader实例
  bool _directoryLoaded = false; // 标志是否已加载目录内容


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (kDebugMode) {
      print('Tab index: ${_tabController.index} flag: $_directoryLoaded');
    }
    if (_tabController.index == 1 && !_directoryLoaded) { // 当点击了第二个选项卡时，加载目录内容
      if(kDebugMode) {
        print("select index");
      }
      _loadDirectory();
    }
  }

  // 加载目录内容
  Future<void> _loadDirectory() async {
    if(kDebugMode) {
      print("_loadDirectory ....");
    }
    try {
      final List<String> directoryContents = await _directoryLoader.loadDirectory("./");
      if(kDebugMode) {
        print("========_loadDirectory ....");
      }
      setState(() {
        _directoryContents = directoryContents;
        _directoryLoaded = true; // 设置目录已加载标志为true
      });
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("Error occurred in _loadDirectory: $e\n$stackTrace");
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        bottom: TabBar (
          controller: _tabController,
          tabs: const [
            Tab(text: '漫画仓库'),
            Tab(text: '目录'),
            Tab(text: '最近观看'),
            Tab(text: '书签'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 漫画仓库内容
          ListView(
            children: const [
              ListTile(title: Text('漫画1')),
              ListTile(title: Text('漫画2')),
              ListTile(title: Text('漫画3')),
              // 其他漫画
            ],
          ),
          // 目录内容
          ListView.builder(
            itemCount: _directoryContents.length,
            itemBuilder: (context, index) {
              return ListTile(title: Text(_directoryContents[index]));
            },
          ),
          const Center(child: Text('最近观看内容')),
          const Center(child: Text('书签内容')),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }
}
