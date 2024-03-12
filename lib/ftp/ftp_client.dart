import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'ftp_exceptions.dart';
import 'ftp_reply.dart';
import 'ftp_socket.dart';

enum ListCommand { NLST, LIST, MLSD }

enum TransferType { auto, ascii, binary }

enum TransferMode { active, passive }

enum SecurityType { FTP, FTPS, FTPES }

extension CommandListTypeEnum on ListCommand {
  String get describeEnum =>
      toString().substring(toString().indexOf('.') + 1);
}

class FTPClient {
  late FTPSocket _socket;
  final String _user;
  final String _pass;

  FTPClient (
      String host, {
        int? port,
        String user = 'anonymous',
        String pass = '',
        SecurityType securityType = SecurityType.FTP,
        int timeout = 30,
      }): _user = user,
        _pass = pass {
    port ??= securityType == SecurityType.FTPS ? 990:21;
    _socket = FTPSocket (
      host,
      port,
      securityType,
      timeout,
    );
  }

  Future<bool> connect() {
   return _socket.connect(_user, _pass);
  }

}