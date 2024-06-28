import 'package:comic_box/view/storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'common/toast.dart';
import 'view/directory.dart'; // 导入 directory.dart 文件


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

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<String> _directoryContents = [];
  DirectoryLoader? _directoryLoader;
  bool _directoryLoaded = false;
  String _currentDirectory = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 1 && !_directoryLoaded && _directoryLoader != null) {
        _loadDirectory();
      }
    });
  }

  Future<void> _loadDirectory([String directoryPath = '']) async {
    try {
      List<String> contents = await _directoryLoader!.loadDirectory(directoryPath);
      setState(() {
        _directoryContents = contents;
        _directoryLoaded = true;
        _currentDirectory = directoryPath;
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error occurred in _loadDirectory: $e");
      }
      alterShowToast("Error: $e");
    }
  }

  void _onServerTap(ServerConfig config) {
    setState(() {
      _directoryLoader = DirectoryLoader(config: config);
      _directoryLoaded = false;
      _currentDirectory = '';
    });
    _loadDirectory();
    _tabController.animateTo(1); // 切换到第二个标签页
  }

  void _navigateUp() {
    if (_currentDirectory.isNotEmpty && _currentDirectory.contains('/')) {
      // 移除最后一个 '/' 后的部分，跳转到上层目录
      String parentDirectory = _currentDirectory.substring(0, _currentDirectory.lastIndexOf('/'));
      _loadDirectory(parentDirectory);
    } else {
      // 如果已经是根目录，重置为根目录
      _loadDirectory('');
    }
  }

  @override
  Widget build(BuildContext context) {
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
          ListView.builder(
            itemCount: serverConfigs.length,
            itemBuilder: (context, index) {
              final config = serverConfigs[index];
              return ListTile(
                title: Text(config.title),
                subtitle: Text('Port: ${config.port} - User: ${config.user}'),
                onTap: () => _onServerTap(config), // 调用 _onServerTap 方法
              );
            },
          ),
          FutureBuilder<List<String>>(
            future: _directoryLoader?.loadDirectory(_currentDirectory), // 调用 _directoryLoader 加载目录
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                if (kDebugMode) {
                  print("Error: ${snapshot.error}");
                }
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                _directoryContents = snapshot.data ?? [];
                return Column(
                  children: [
                    // 固定导航栏
                    ListTile(
                      leading: const Icon(Icons.arrow_upward),
                      title: const Text('上层目录'),
                      onTap: _currentDirectory.isNotEmpty ? _navigateUp : null,
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _directoryContents.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              String selectedDirectory = _directoryContents[index];
                              if (kDebugMode) {
                                print('Clicked on $selectedDirectory');
                              }
                              String newDirectory = _currentDirectory.isEmpty
                                  ? selectedDirectory
                                  : '$_currentDirectory/$selectedDirectory';
                              _loadDirectory(newDirectory); // 进入点击的目录
                            },
                            child: ListTile(
                              title: Text(_directoryContents[index]),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }
            },
          ),
          const Center(child: Text('最近观看内容')),
          const Center(child: Text('书签内容')),
        ],
      ),
      bottomNavigationBar: kDebugMode ? Text("Total: ${_directoryContents.length}") : null,
    );
  }
}

