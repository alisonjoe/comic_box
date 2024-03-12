import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'ftp_client.dart';
import 'ftp_exceptions.dart';
import 'ftp_reply.dart';


class FTPSocket {
  final String host;
  final int port;
  final int timeout;
  final SecurityType securityType;
  late Socket _socket;
  TransferMode transferMode = TransferMode.passive;
  TransferType _transferType = TransferType.auto;
  ListCommand listCommand = ListCommand.MLSD;
  bool supportIPV6 = false;

  FTPSocket(this.host, this.port, this.securityType,  this.timeout);

  /// Set current transfer type of socket
  ///
  /// Supported types are: [TransferType.auto], [TransferType.ascii], [TransferType.binary],
  TransferType get transferType => _transferType;

  /// Send a command [cmd] to the FTP Server
  /// if [waitResponse] the function waits for the reply, other wise return ''
  void sendCommandWithoutWaitingResponse(String cmd) async {
    _socket.write(const Utf8Codec().encode('$cmd\r\n'));
  }


  Future<FTPReply> openDataTransferChannel() async {
    FTPReply res = FTPReply(200, "");
    if (transferMode == TransferMode.active) {
      //todo later
    } else {
      res = await sendCommand(supportIPV6 ? 'EPSV' : 'PASV');
      if (!res.isSuccessCode()) {
        throw FTPConnectException('Could not start Passive Mode', res.message);
      }
    }

    return res;
  }

  /// Set the Transfer mode on [socket] to [mode]
  Future<void> setTransferType(TransferType pTransferType) async {
    //if we already in the same transfer type we do nothing
    if (_transferType == pTransferType) return;
    switch (pTransferType) {
      case TransferType.auto:
      // Set to ASCII mode
        await sendCommand('TYPE A');
        break;
      case TransferType.ascii:
      // Set to ASCII mode
        await sendCommand('TYPE A');
        break;
      case TransferType.binary:
      // Set to BINARY mode
        await sendCommand('TYPE I');
        break;
      default:
        break;
    }
    _transferType = pTransferType;
  }

  // Disconnect from the FTP Server
  Future<bool> disconnect() async {
    try {
      await sendCommand('QUIT');
    } catch (ignored) {
      // Ignore
    } finally {
      // await _socket.close();
      // _socket.shutdown(SocketDirection.both);
    }

    return true;
  }

  Future<FTPReply> readResponse() async {
    Completer<FTPReply> completer = Completer<FTPReply>();
    StringBuffer res = StringBuffer();

    _socket.listen(
          (List<int> data) {
        res.write(utf8.decode(data).trim());
        if (kDebugMode) {
          print("=========res: $res");
        }
      },
      onDone: () {
            if (kDebugMode) {
              print("=============onDone");
            }
        String r = res.toString();
        if (r.startsWith("\n")) {
          r = r.replaceFirst("\n", "");
        }

        if (r.length < 3) {
          completer.completeError(FTPConnectException("Illegal Reply Exception", r));
          return;
        }

        int? code;
        List<String> lines = r.split('\n');
        String? line;
        for (line in lines) {
          if (line.length >= 3) code = int.tryParse(line.substring(0, 3)) ?? code;
        }
        //multiline response
        if (line != null && line.length >= 4 && line[3] == '-') {
          completer.completeError(FTPConnectException("Multiline response not supported", r));
          return;
        }

        if (code == null) {
          completer.completeError(FTPConnectException("Illegal Reply Exception", r));
          return;
        }

        FTPReply reply = FTPReply(code, r);
        completer.complete(reply);
      },
      onError: (error) {
        completer.completeError(error);
      },
      cancelOnError: true,
    );

    return completer.future;
  }




  Future<FTPReply> readResponse2() async {
    StringBuffer res = StringBuffer();
    _socket.listen(
          (List<int> data) {
        res.write(utf8.decode(data).trim());
        if (kDebugMode) {
          print("====================readResponse: $res");
        }
      },
      onDone: () {
        if (kDebugMode) {
          print("=========res: $res");
        }
      },
      onError: (error) {
        if (kDebugMode) {
          print("=========error: $error");
        }
      },
      cancelOnError: true, // 一旦发生错误，立即取消监听
    );

    String r = res.toString();
    if (kDebugMode) {
      print("=============res: $res, r: $r");
    }

    if (r.startsWith("\n")) {
      r = r.replaceFirst("\n", "");
    }

    if (r.length < 3) {
      throw FTPConnectException("Illegal Reply Exception", r);
    }

    int? code;
    List<String> lines = r.split('\n');
    //get last code
    String? line;
    for (line in lines) {
      if (line.length >= 3) code = int.tryParse(line.substring(0, 3)) ?? code;
    }
    //multiline response
    if (line != null && line.length >= 4 && line[3] == '-') {
      return await readResponse();
    }

    if (code == null) throw FTPConnectException("Illegal Reply Exception", r);

    FTPReply reply = FTPReply(code, r);
    if (kDebugMode) {
      print('< ${reply.toString()}');
    }
    return reply;
  }


  Future<FTPReply> sendCommand(String cmd) {
    _socket.write(const Utf8Codec().encode('$cmd\r\n'));

    return readResponse();
  }

  /// Connect to the FTP Server and Login with [user] and [pass]
  Future<bool> connect(String user, String pass, {String? account}) async {
    if (kDebugMode) {
      print('Connecting...$user@$pass');
    }

    final timeout = Duration(seconds: this.timeout);

    try {
      // FTPS starts secure
      if (securityType == SecurityType.FTPS) {
        _socket = (await Socket.connect(
          host,
          port,
          timeout: timeout,
        ));
      } else {
        _socket = (await Socket.connect(
          host,
          port,
          timeout: timeout,
        ));
      }
    } catch (e) {
      throw FTPConnectException(
          'Could not connect to $host ($port)', e.toString());
    }

    if (kDebugMode) {
      print('Connection established, waiting for welcome message...');
    }
    await readResponse();
    if (kDebugMode) {
      print("==========next send username");
    }

    // FTPES needs to be upgraded prior to getting a welcome
    if (securityType == SecurityType.FTPES) {
      FTPReply lResp = await sendCommand('AUTH TLS');
      if (!lResp.isSuccessCode()) {
        lResp = await sendCommand('AUTH SSL');
        if (!lResp.isSuccessCode()) {
          throw FTPConnectException(
              'FTPES cannot be applied: the server refused both AUTH TLS and AUTH SSL commands',
              lResp.message);
        }
      }

      // _socket = await Socket.secure(_socket,
      //     onBadCertificate: (certificate) => true);
    }

    if ([SecurityType.FTPES, SecurityType.FTPS].contains(securityType)) {
      await sendCommand('PBSZ 0');
      await sendCommand('PROT P');
    }

    if (kDebugMode) {
      print("===========begin sendCommand USER $user");
    }
    // Send Username
    FTPReply lResp = await sendCommand('USER $user');

    //password required
    if (lResp.code == 331) {
      lResp = await sendCommand('PASS $pass');
      if (lResp.code == 332) {
        if (account == null) throw FTPConnectException('Account required');
        lResp = await sendCommand('ACCT $account');
        if (!lResp.isSuccessCode()) {
          throw FTPConnectException('Wrong Account', lResp.message);
        }
      } else if (!lResp.isSuccessCode()) {
        throw FTPConnectException('Wrong Username/password', lResp.message);
      }
      //account required
    } else if (lResp.code == 332) {
      if (account == null) throw FTPConnectException('Account required');
      lResp = await sendCommand('ACCT $account');
      if (!lResp.isSuccessCode()) {
        throw FTPConnectException('Wrong Account', lResp.message);
      }
    } else if (!lResp.isSuccessCode()) {
      throw FTPConnectException('Wrong username $user', lResp.message);
    }

    if (kDebugMode) {
      print('Connected!');
    }
    return true;
  }
}
