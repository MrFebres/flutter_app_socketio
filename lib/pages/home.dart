import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:socketio_app/models/band.dart';
import 'package:socketio_app/services/socket.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);

    socketService.socket.on('active-bands', _handleActiveBands);

    super.initState();
  }

  _handleActiveBands(dynamic payload) {
    bands = (payload as List)
        .map(
          (band) => Band.fromMap(band),
        )
        .toList();

    setState(() {});
  }

  @override
  void dispose() {
    // final socketService = Provider.of<SocketService>(context, listen: false);
    // socketService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: (socketService.serverStatus == ServerStatus.online)
                ? Icon(
                    Icons.check_circle,
                    color: Colors.blue[300],
                  )
                : const Icon(
                    Icons.offline_bolt,
                    color: Colors.red,
                  ),
          )
        ],
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'BandNames',
          style: TextStyle(color: Colors.black87),
        ),
      ),
      body: ListView.builder(
        itemBuilder: (_, i) => _bandTile(bands[i]),
        itemCount: bands.length,
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 1,
        onPressed: _addNewBand,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _bandTile(Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      background: Container(
        alignment: Alignment.centerLeft,
        color: Colors.red,
        padding: const EdgeInsets.only(left: 8.0),
        child: const Text(
          'Delete band',
          style: TextStyle(color: Colors.white),
        ),
      ),
      direction: DismissDirection.startToEnd,
      key: Key(band.id),
      onDismissed: (_) => socketService.emit('delete-band', {'id': band.id}),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Text(
            band.name.substring(0, 2),
          ),
        ),
        title: Text(band.name),
        trailing: Text(
          '${band.votes}',
          style: const TextStyle(fontSize: 20),
        ),
        onTap: () {
          socketService.emit('vote-band', {'id': band.id});
        },
      ),
    );
  }

  _addNewBand() {
    final textControler = TextEditingController();

    if (Platform.isAndroid) {
      return showDialog(
        context: context,
        builder: (context) => AlertDialog(
          actions: [
            MaterialButton(
              elevation: 1,
              onPressed: () => addBandToList(textControler.text),
              textColor: Colors.blue,
              child: const Text('Add'),
            ),
          ],
          content: TextField(
            controller: textControler,
          ),
          title: const Text('New band name'),
        ),
      );
    }
    if (Platform.isIOS) {
      return showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                addBandToList(textControler.text);
              },
              child: const Text('Add'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.pop(context),
              child: const Text('Dismiss'),
            ),
          ],
          content: CupertinoTextField(
            controller: textControler,
          ),
          title: const Text('New band name'),
        ),
      );
    }
  }

  void addBandToList(String name) {
    final socketService = Provider.of<SocketService>(context, listen: false);

    if (name.length > 1) {
      socketService.emit('add-band', {'name': name});
    }

    Navigator.pop(context);
  }
}
