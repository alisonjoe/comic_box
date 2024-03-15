// storage.dart

class ServerConfig {
  final String title;
  final String host;
  final int port;
  final String user;
  final String pass;

  ServerConfig({
    required this.title,
    required this.host,
    required this.port,
    required this.user,
    required this.pass,
  });
}

// 全局变量，存储所有服务器配置
List<ServerConfig> serverConfigs = [
  ServerConfig(
    title: "xnas",
    host: 'alisonjoe.tpddns.cn',
    port: 21000,
    user: 'alisonjoe',
    pass: 'Homeisu&me',
  ),
  // 其他服务器配置...
];

