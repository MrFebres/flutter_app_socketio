import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';

enum ServerStatus {
  connecting,
  offline,
  online,
}

class SocketService with ChangeNotifier {
  late ServerStatus _serverStatus = ServerStatus.connecting;
  late Socket _socket;

  SocketService() {
    _initConfig();
  }

  Function get emit => _socket.emit;
  ServerStatus get serverStatus => _serverStatus;
  Socket get socket => _socket;

  void _initConfig() {
    _socket = io(
        'http://localhost:3000',
        OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .enableAutoConnect() // disable auto-connection
            .build());

    _socket.onConnect((_) {
      _serverStatus = ServerStatus.online;
      notifyListeners();
    });

    _socket.onDisconnect((_) {
      _serverStatus = ServerStatus.offline;
      notifyListeners();
    });

    _socket.on('nuevo-mensaje', (payload) {
      print('${payload['nombre']}');
      print('${payload['mensaje']}');
      print(payload.containsKey('mensaje2')
          ? payload['mensaje2']
          : 'No hay mensaje2');
    });
  }
}
