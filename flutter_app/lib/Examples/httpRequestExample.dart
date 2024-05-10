import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Django Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<Map<String, String>> sendData() async {
  const url = 'http://192.168.1.75:8000/basic/';
  final data = {"first_name": "John", "last_name": "Doe"};

  final response = await http.post(
    Uri.parse(url),
    body: json.encode(data),
    headers: {'Content-Type': 'application/json'},
  );

  if (response.statusCode == 200) {
    // Parse the response body as a Map<String, dynamic>
    final Map<String, dynamic> responseBody = json.decode(response.body);

    // Convert the dynamic values to String
    final Map<String, String> parsedResponse = responseBody.map(
      (key, value) => MapEntry(key, value.toString()),
    );

    return parsedResponse;
  } else {
    throw Exception('Failed to load data');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Django Test'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            sendData().then((response) {
              final message =
                  'POST request successful: First Name: ${response["first_name"]}, Last Name: ${response["last_name"]}';
              print(message);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  duration: const Duration(seconds: 2),
                ),
              );
            }).catchError((error) {
              print('Error: $error');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Failed to send POST request'),
                  duration: Duration(seconds: 2),
                ),
              );
            });
          },
          child: const Text('Send Data'),
        ),
      ),
    );
  }
}
