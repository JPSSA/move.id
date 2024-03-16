import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    // Your background task logic goes here
    print("Background task executed!");
    return Future.value(true);
  });
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(callbackDispatcher);
  runApp(MyApp());
}

void scheduleTask() {
  Workmanager().registerOneOffTask(
    'myTask',
    'simpleTask',
    inputData: <String, dynamic>{'key': 'value'},
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WorkManager Test',
      home: Scaffold(
        appBar: AppBar(
          title: Text('WorkManager Test'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              scheduleTask();
              print("Task scheduled!");
            },
            child: Text('Schedule Task'),
          ),
        ),
      ),
    );
  }
}
