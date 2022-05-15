import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';

enum ServerStatus {
  Connecting,
  Offline,
  Online,
}

class SocketService with ChangeNotifier {
  late ServerStatus _serverStatus = ServerStatus.Connecting;

  SocketService() {
    _initConfig();
  }

  get serverStatus => _serverStatus;

  void _initConfig() {
    Socket socket = io(
        'http://localhost:3000',
        OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .enableAutoConnect() // disable auto-connection
            .build());

    socket.onConnect((_) {
      _serverStatus = ServerStatus.Online;
      notifyListeners();
    });

    socket.onDisconnect((_) {
      _serverStatus = ServerStatus.Offline;
      notifyListeners();
    });
  }
}
