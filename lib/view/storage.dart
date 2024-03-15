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
    host: 'xxxx',
    port: 21,
    user: 'xxx',
    pass: 'xxxx',
  ),
  // 其他服务器配置...
];

