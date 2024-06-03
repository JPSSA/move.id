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
  final TextEditingController _startHourController = TextEditingController();
  final TextEditingController _endHourController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _groupNotifications = prefs.getBool('groupNotifications') ?? false;
      _startHourController.text = prefs.getString('startHour') ?? '';
      _endHourController.text = prefs.getString('endHour') ?? '';
      _nameController.text = prefs.getString('nameFilter') ?? '';
    });
  }

  Future<void> _savePreferences(bool groupNotifications, String startHour, String endHour, String nameFilter) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('groupNotifications', groupNotifications);
    if (startHour.isNotEmpty) {
      await prefs.setString('startHour', startHour);
    } else {
      await prefs.remove('startHour');
    }
    if (endHour.isNotEmpty) {
      await prefs.setString('endHour', endHour);
    } else {
      await prefs.remove('endHour');
    }
    if (nameFilter.isNotEmpty) {
      await prefs.setString('nameFilter', nameFilter);
    } else {
      await prefs.remove('nameFilter');
    }
  }

  void _onSwitchChanged(bool value) {
    setState(() {
      _groupNotifications = value;
    });
    _savePreferences(_groupNotifications, _startHourController.text, _endHourController.text, _nameController.text);
  }

  void _onSaveTimePreferences() {
    _savePreferences(_groupNotifications, _startHourController.text, _endHourController.text, _nameController.text);
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
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Notification Filter',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'RobotoMono',
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _startHourController,
                          decoration: InputDecoration(
                            labelText: 'Start Hour (HH:MM)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.datetime,
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _endHourController,
                          decoration: InputDecoration(
                            labelText: 'End Hour (HH:MM)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.datetime,
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Name Filter',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _onSaveTimePreferences,
                          child: const Text('Save Preferences'),
                        ),
                      ],
                    ),
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
