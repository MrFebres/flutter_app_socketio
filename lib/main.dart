import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:socketio_app/pages/index.dart';
import 'package:socketio_app/services/socket.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SocketService(),
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: 'home',
        routes: {
          'home': (_) => const HomePage(),
          'status': (_) => const StatusPage(),
        },
        title: 'Material App',
      ),
    );
  }
}
