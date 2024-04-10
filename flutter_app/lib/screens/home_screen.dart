import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:move_id/screens/settings_screen.dart';
import 'package:move_id/utils/color_utils.dart';
import 'package:move_id/utils/home_controller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:move_id/utils/api_urls.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String, String>> addNotifierRequest(String location, String deviceid) async {
  
  const String url = ApiUrls.addNotifierUrl;


  final prefs = await SharedPreferences.getInstance();
  String email = prefs.getString("email").toString();
  prefs.setString('location', location);

  final Map<String, String> userData = {
      'email': email,
      'idSensor': deviceid,
      'location': location,
    };

  final http.Response response = await http.post(
    Uri.parse(url),
    body: json.encode(userData),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );

  if (response.statusCode == 200) {
    Fluttertoast.showToast(
      msg: "Notifier added successfully",
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: Colors.white,
      textColor: Colors.black
    );

    final Map<String, dynamic> responseBody = json.decode(response.body);
    
    final Map<String, String> responseData = {};
    responseBody.forEach((key, value) {
      responseData[key] = value.toString();
    });
    return responseData;
  } else {
    Fluttertoast.showToast(
      msg: "Failed to add Notifier with that id",
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: Colors.white,
      textColor: Colors.black
    );
    throw Exception('Failed to add Notifier');
  }
}


Future<Map<String, String>> removeNotifierRequest(String deviceid) async {
  
  const String url = ApiUrls.removeNotifierUrl;

  final prefs = await SharedPreferences.getInstance();
  String email = prefs.getString("email").toString();

  final Map<String, String> userData = {
      'email': email,
      'idSensor': deviceid,
    };

  final http.Response response = await http.delete(
    Uri.parse(url),
    body: json.encode(userData),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );

  if (response.statusCode == 200) {
    Fluttertoast.showToast(
      msg: "Notifier removed successfully",
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: Colors.white,
      textColor: Colors.black
    );

    final Map<String, dynamic> responseBody = json.decode(response.body);
    
    final Map<String, String> responseData = {};
    responseBody.forEach((key, value) {
      responseData[key] = value.toString();
    });
    return responseData;
  } else {
    Fluttertoast.showToast(
      msg: "Failed to remvove the Notifier with that id",
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: Colors.white,
      textColor: Colors.black
    );
    throw Exception('Failed to remove Notifier');
  }
}




















class HomeScreen extends GetView<HomeController> {
  
  final List<String> dropdownOptions = [
    "Hospital Santa Maria",
    "Hospital Lusíadas",
    "Hospital da Luz",
  ];

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print("Dropdown Options: $dropdownOptions");
    print("Selected Hospital: ${controller.selectedLocation.value}");
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                hexStringToColor("#3b75d7"),
                hexStringToColor("#4f5eff"),
                hexStringToColor("#8b31b1"),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 90),
              TextField(
                controller: controller.deviceIDTextEditingController,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Device ID",
                  labelText: "Device ID",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              DropdownButtonFormField<String>(
                value: controller.selectedLocation.value,
                onChanged: (String? value) {
                  controller.selectedLocation.value = value!;
                },
                items: dropdownOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Select a hospital",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 60),
             ElevatedButton(
              onPressed: () {
                String deviceid = controller.deviceIDTextEditingController.text;
                String location = controller.selectedLocation.value.toString();
                if(deviceid.isNotEmpty){
                  print(controller.selectedLocation.value.toString());
                  print(deviceid);
                  controller.addPatient(location,deviceid);
                  addNotifierRequest(location, deviceid);
                }else{
                  Fluttertoast.showToast(
                    msg: "Fill all the device id",
                    toastLength: Toast.LENGTH_SHORT,
                    backgroundColor: Colors.white,
                    textColor: Colors.black
                  );
                }
              },
              child: const Text(
                "Add Notifier",
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'RobotoMono',
                ),
              ),
            ),
              Obx(
                () => Container(
                  height: 320,
                  child: ListView.builder(
                    itemCount: controller.itemCount.value,
                    itemBuilder: (context, index) {
                     return Container(
                      color: Colors.white,
                      child: ListTile(
                        title: Text(controller.patients.value[index].deviceid!),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(controller.patients.value[index].location.toString()),
                          ],
                        ),
                        trailing: GestureDetector(
                          child: const Icon(Icons.delete, color: Colors.red),
                          onTap: () {
                            print(controller.patients.value[index].location);
                            print(controller.patients.value[index].deviceid);
                            removeNotifierRequest(controller.patients.value[index].deviceid.toString());
                            controller.removePatient(index);
                          },
                        ),
                      ),
                    );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home,color: Colors.purple),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: 0, // Set the current index of the selected item
        onTap: (index) {
          // Handle navigation when a tab is tapped
          switch (index) {
            case 0:
              // Navigate to HomeScreen
              break;
            case 1:
              Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsScreen()),
                  );
              break;
          }
        },
      ),
    );
  }
}
