import 'dart:convert';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_client/flappy_game.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  runApp(GameWidget(game: FlappyGame()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TCG Kaizer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), // Perbaikan di sini
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Inisialisasi channel
  final channel = WebSocketChannel.connect(Uri.parse('ws://192.168.220.176:8080'));
  Map players = {};

  @override
  void initState() {
    super.initState();
    channel.stream.listen((data) {
      final msg = jsonDecode(data);
      if (msg['type'] == 'state') { 
        setState(() {
          players = msg['players'];
        });
      }
    });
  }

  // Fungsi untuk mengirim pergerakan ke server
  void sendMove(double dx, double dy) {
    channel.sink.add(jsonEncode({
      'type': 'move',
      'dx': dx,
      'dy': dy,
    }));
  }

  @override
  void dispose() {
    channel.sink.close(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('TCG Kaizer'),
      ),
      body: Stack(
        children: players.values.map((p) {
          return Positioned(
            left: (p['x'] ?? 0).toDouble(),
            top: (p['y'] ?? 0).toDouble(),
            child: Container(
              width: 20.0,
              height: 20.0,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.rectangle,
              ),
            ),
          );
        }).toList(),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(onPressed: () => sendMove(0, -10), icon: const Icon(Icons.arrow_upward)),
            IconButton(onPressed: () => sendMove(0, 10), icon: const Icon(Icons.arrow_downward)),
            IconButton(onPressed: () => sendMove(-10, 0), icon: const Icon(Icons.arrow_back)),
            IconButton(onPressed: () => sendMove(10, 0), icon: const Icon(Icons.arrow_forward)),
          ],
        ),
      ),
    );
  }
}