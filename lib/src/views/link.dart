import 'package:flutter/material.dart';
import 'package:link/src/socket/server.dart';

class Link extends StatefulWidget {
  const Link({super.key});

  @override
  State<Link> createState() => _LinkState();
}

class _LinkState extends State<Link> {
  Server? _server;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            style: IconButton.styleFrom(backgroundColor: Colors.greenAccent),
            onPressed: () async {
              _server = Server();
              await _server?.open();
            },
            icon: const Icon(Icons.play_arrow_rounded),
          ),
          IconButton(
            style: IconButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              if (_server != null) {
                _server?.close();
              }
            },
            icon: const Icon(Icons.stop_rounded),
          ),
        ],
      ),
    );
  }
}
