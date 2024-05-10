import 'package:flutter/material.dart';
import 'package:move_id/screens/home_screen.dart';
import 'package:move_id/screens/notification_history_screen.dart';
import 'package:move_id/screens/settings_screen.dart';
import 'package:move_id/screens/splash_screen.dart';
import 'package:move_id/utils/color_utils.dart';
import 'package:move_id/utils/home_controller.dart';
import 'package:get/get.dart';
import 'package:move_id/utils/notification_history_controller.dart';


void main() {
  // Initialize HomeController
  Get.put(HomeController());
  Get.put(NotificationHistoryController());

  // Run the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Move ID",
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder: (BuildContext context) {
          
          return DefaultTabController(
            length: 3,
            child: Scaffold(
              appBar: AppBar(
                title: const Text("Move ID"),
                backgroundColor: hexStringToColor("#F0EAD2"),
                bottom: const TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.home)),
                    Tab(icon: Icon(Icons.assignment)),
                    Tab(icon: Icon(Icons.settings)),
                  ],
                ),
              ),
              body: const TabBarView(
                children: <Widget>[
                  HomeScreen(),
                  NotificationHistoryScreen(),
                  SettingsScreen(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
