import 'package:flutter/material.dart';
import 'package:move_id/screens/home_screen.dart';
import 'package:move_id/screens/signin_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  title: const Text('Logout',
                  style: TextStyle(fontFamily: 'RobotoMono'),),
                  onTap: () async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    prefs.remove('email');
                    Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignInScreen()),
                  );
                  },
                ),
              ],
            ),
          ),
        
        ],
      ),
    );
  }
}
