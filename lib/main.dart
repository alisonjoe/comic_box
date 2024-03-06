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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController.index == 1) { // 当点击了第二个选项卡时，加载目录内容
      if(kDebugMode) {
        print("select index");
      }
      _loadDirectory();
    }
  }

  // 加载目录内容
  Future<void> _loadDirectory() async {
    final List<String> directoryContents = await DirectoryLoader.loadDirectory("113.90.239.20", 21000, "alisonjoe", "Homeisu&me", "./");
    setState(() {
      _directoryContents = directoryContents;
    });
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
