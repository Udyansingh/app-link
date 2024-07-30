import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class Server {
  late final Isolate _isolate;
  late final ReceivePort _receivePort;
  late final SendPort _sendPort;

  Future<void> open() async {
    _receivePort = ReceivePort();
    final rootIsolateToken = RootIsolateToken.instance!;
    _isolate = await Isolate.spawn(
      isolateFunction,
      (_receivePort.sendPort, rootIsolateToken),
    );
    _receivePort.listen(
      (message) {
        if (message is SendPort) {
          _sendPort = message;
          _sendPort.send('START_SERVER');
        } else if (message == 'SERVER_CLOSED') {
          debugPrint(message.toString());
          _isolate.kill(priority: Isolate.immediate);
          _receivePort.close();
        } else {
          debugPrint(message.toString());
        }
      },
    );
  }

  void close() {
    _sendPort.send('CLOSE_SERVER');
  }

  static void isolateFunction((SendPort, RootIsolateToken) params) {
    final SendPort mainSendPort = params.$1;
    final RootIsolateToken rootIsolateToken = params.$2;

    BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
    final receivePort = ReceivePort();
    mainSendPort.send(receivePort.sendPort);
    ServerSocket? serverSocket;
    receivePort.listen(
      (message) async {
        if (message == 'START_SERVER') {
          serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, 0);
          mainSendPort.send(
              'SERVER_STARTED | ${serverSocket?.address.host}:${serverSocket?.port}');
        } else if (message == 'CLOSE_SERVER') {
          await serverSocket?.close();
          mainSendPort.send('SERVER_CLOSED');
        }
      },
    );
  }
}
