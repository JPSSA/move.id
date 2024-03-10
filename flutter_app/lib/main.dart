import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
  home: Home(),
));

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
      title: const Text(
        "Move ID ", 
        style: TextStyle(
          letterSpacing: 2.0,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          fontSize: 20,
          fontFamily: "RobotoMono",
        ),
      ),
      backgroundColor: Colors.blue[600],
      centerTitle: true,
    ),
  );
  }
}