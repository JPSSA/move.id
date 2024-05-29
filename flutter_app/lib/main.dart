import 'package:flutter/material.dart';
import 'package:move_id/screens/home_screen.dart';
import 'package:move_id/screens/notification_history_screen.dart';
import 'package:move_id/screens/settings_screen.dart';
import 'package:move_id/screens/signin_screen.dart';
import 'package:move_id/screens/splash_screen.dart';
import 'package:move_id/utils/color_utils.dart';
import 'package:move_id/utils/home_controller.dart';
import 'package:get/get.dart';
import 'package:move_id/utils/notification_history_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize controllers
  Get.put(HomeController());
  Get.put(NotificationHistoryController());
  

  // Run the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkEmail(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            title: "Move ID",
            debugShowCheckedModeBanner: false,
            home: SplashScreen(),
          );
        } else {
          if (snapshot.data == true) {
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
                        backgroundColor: hexStringToColor("#eff1ed"),
                        bottom: const TabBar(
                          tabs: [
                            Tab(icon: Icon(Icons.home)),
                            Tab(icon: Icon(Icons.assignment)),
                            Tab(icon: Icon(Icons.settings)),
                          ],
                          indicatorColor: Color.fromARGB(255, 183, 228, 199),
                          labelColor: Color.fromARGB(255, 183, 228, 199),
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
          } else {
            return const MaterialApp(
              title: "Move ID",
              debugShowCheckedModeBanner: false,
              home: SignInScreen(),
            );
          }
        }
      },
    );
  }

  Future<bool> _checkEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('email');
  }
}
