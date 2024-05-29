import 'package:flutter/material.dart';
import 'package:move_id/screens/signin_screen.dart';
import 'package:move_id/utils/color_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _groupNotifications = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _groupNotifications = prefs.getBool('groupNotifications') ?? false;
    });
  }

  Future<void> _savePreferences(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('groupNotifications', value);
  }

  void _onSwitchChanged(bool value) {
    setState(() {
      _groupNotifications = value;
    });
    _savePreferences(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: hexStringToColor('#D8F3DC'),
        surfaceTintColor: hexStringToColor('#D8F3DC'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              hexStringToColor("#D8F3DC"),
              hexStringToColor("#B7E4C7"),
              hexStringToColor("#95D5B2"),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    title: const Text(
                      'Logout',
                      style: TextStyle(fontFamily: 'RobotoMono'),
                    ),
                    onTap: () async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      await prefs.remove('email');
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignInScreen()),
                      );
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Group Notifications'),
                    value: _groupNotifications,
                    onChanged: _onSwitchChanged,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
