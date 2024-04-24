import 'package:flutter/material.dart';
import 'package:move_id/screens/settings_screen.dart';
import 'package:move_id/utils/color_utils.dart';
import 'package:move_id/utils/home_controller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:move_id/utils/api_urls.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String, String>> addNotifierRequest(String location, String deviceid, HomeController controller) async {
  
  const String url = ApiUrls.addNotifierUrl;

  try {
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

      String topic = "$location" + "\\" + "$deviceid";

      addToList(location,deviceid);

      controller.subscribeToTopic(topic);
      controller.addPatient(location,deviceid);

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
      return {};
    }
  } catch (e) {
    print('Exception occurred: $e');
    Fluttertoast.showToast(
      msg: "Failed to add Notifier with that id",
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: Colors.white,
      textColor: Colors.black
    );
    return {}; 
  }
}

Future<Map<String, String>> removeNotifierRequest(String deviceid, String location, HomeController controller, int index) async {
  
  const String url = ApiUrls.removeNotifierUrl;

  try {
    final prefs = await SharedPreferences.getInstance();
    String email = prefs.getString("email").toString();
    final Map<String, dynamic>? locationsAndIds = json.decode(prefs.getString('locations_and_ids') ?? '{}');
    final String? idLocation = locationsAndIds?[location];

    if (idLocation == null) {
      print('Location ID not found for $location');
      Fluttertoast.showToast(
        msg: "Location ID not found for $location",
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.white,
        textColor: Colors.black
      );
      return {};
    }

    final Map<String, String> userData = {
        'email': email,
        'idSensor':deviceid,
        'idLocation': idLocation,
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

      String topic = "$location" + "\\" + "$deviceid";

      removeFromList(location,deviceid);

      controller.unsubscribeFromTopic(topic);
      controller.removePatient(index);

      final Map<String, dynamic> responseBody = json.decode(response.body);
      
      final Map<String, String> responseData = {};
      responseBody.forEach((key, value) {
        responseData[key] = value.toString();
      });
      return responseData;
    } else {
      Fluttertoast.showToast(
        msg: "Failed to remove the Notifier with that id",
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.white,
        textColor: Colors.black
      );
      print(response);
      return {}; 
    }
  } catch (e) {
    print('Exception occurred: $e');
    Fluttertoast.showToast(
      msg: "Failed to remove the Notifier with that id",
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: Colors.white,
      textColor: Colors.black
    );
    return {};
  }
}

Future<void> fetchStoredItems(HomeController controller) async {
  final prefs = await SharedPreferences.getInstance();
  final itemList = prefs.getStringList('itemList') ?? [];
  itemList.forEach((item) {
    final itemData = item.split(',');
    final deviceid = itemData[0];
    final location = itemData[1];
    // Subscribe to MQTT topic corresponding to the stored item
    controller.subscribeToTopic('$location\\$deviceid');
    // Add item to the list
    controller.addPatient(location, deviceid);
  });
}

Future<void> addToList(String location, String deviceid) async {
  final prefs = await SharedPreferences.getInstance();
  final itemList = prefs.getStringList('itemList') ?? [];
  final newItem = '$deviceid,$location';
  itemList.add(newItem);
  await prefs.setStringList('itemList', itemList);
}

Future<void> removeFromList(String location, String deviceid) async {
  final prefs = await SharedPreferences.getInstance();
  final itemList = prefs.getStringList('itemList') ?? [];
  final itemToRemove = '$deviceid,$location';
  itemList.remove(itemToRemove);
  await prefs.setStringList('itemList', itemList);
}

final List<String> dropdownOptions = [];

Future<List<String>> getLocationNamesFromPrefs(dropdownOptions) async {
  final prefs = await SharedPreferences.getInstance();
  dropdownOptions = prefs.getStringList('location_names');
  if (dropdownOptions != null) {
      print('Location names retrieved from SharedPreferences.');
      return dropdownOptions;
    } else {
      print('Location names not found in SharedPreferences.');
      return []; // or throw an error, depending on your requirement
    }
}




Future<void> getAllLocationsAndIdsAndSaveToPrefs() async {
  const String url = ApiUrls.locationGetterUrl; // Replace 'YOUR_API_URL_HERE' with your actual API endpoint for fetching locations and IDs
  
  try {
    final http.Response response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);

      // Assuming the response body is in the format { "locations": [{ "name": "Location1", "id": "ID1" }, { "name": "Location2", "id": "ID2" }, ... ]}
      final List<dynamic> locationsData = responseBody['locations'];

      final Map<String, String> locationsAndIds = {};
      final List<String> locationNames = [];

      for (final locationData in locationsData) {
        final String locationName = locationData['name'];
        final String locationId = locationData['id'];
        locationsAndIds[locationName] = locationId;
        locationNames.add(locationName);
      }

      // Store the locations and IDs dictionary in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('locations_and_ids', json.encode(locationsAndIds));
      prefs.setStringList('location_names', locationNames); // Store the list of location names
      
      print('Locations and IDs saved to SharedPreferences.');
    } else {
      print('Failed to fetch locations and IDs. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Exception occurred: $e');
  }
}





























































class HomeScreen extends GetView<HomeController> {

  
  

  HomeScreen({super.key});

   

  @override
  Widget build(BuildContext context) {

    getAllLocationsAndIdsAndSaveToPrefs();
    getLocationNamesFromPrefs(dropdownOptions);
    fetchStoredItems(controller);
    
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
                  addNotifierRequest(location, deviceid,controller);
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
                            removeNotifierRequest(controller.patients.value[index].deviceid.toString(),controller.patients.value[index].location.toString(),controller, index);
                           
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
