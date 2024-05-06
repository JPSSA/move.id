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

void addNotifierRequest(String idLocation, String deviceid, HomeController controller) async {
  
  const String url = ApiUrls.addNotifierUrl;

  try {
    final prefs = await SharedPreferences.getInstance();
    String email = prefs.getString("email").toString();
    

    final Map<String, String> userData = {
        'email': email,
        'idSensor': deviceid,
        'idLocation': idLocation,
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
      
    } else {
      Fluttertoast.showToast(
        msg: "Failed to add Notifier with that id",
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.white,
        textColor: Colors.black
      );
    }
  } catch (e) {
    print('Exception occurred: $e');
    Fluttertoast.showToast(
      msg: "Failed to add Notifier with that id",
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: Colors.white,
      textColor: Colors.black
    );
  }
}

void removeNotifierRequest(String deviceid, String idLocation, HomeController controller) async {
  
  const String url = ApiUrls.removeNotifierUrl;

  try {
    final prefs = await SharedPreferences.getInstance();
    String email = prefs.getString("email").toString();
    

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
      String topic =  "moveID/notification/" + "$idLocation" + "/" + "$deviceid";
      controller.unsubscribeFromTopic(topic);
      Fluttertoast.showToast(
        msg: "Notifier removed successfully",
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.white,
        textColor: Colors.black
      );

    } else {
      Fluttertoast.showToast(
        msg: "Failed to remove the Notifier with that id",
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.white,
        textColor: Colors.black
      );



    }
  } catch (e) {
    print('Exception occurred: $e');
    Fluttertoast.showToast(
      msg: "Failed to remove the Notifier with that id",
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: Colors.white,
      textColor: Colors.black
    );
    
  }
}

Future<void> fetchStoredItems(HomeController controller) async {
  final prefs = await SharedPreferences.getInstance();
  final itemList = prefs.getStringList('itemList') ?? [];
  itemList.forEach((item) {
    final itemData = item.split(',');
    final deviceid = itemData[0];
    final location = itemData[1];

    //TO DO 
    // Subscribe to MQTT topic corresponding to the stored item
    //controller.subscribeToTopic('$location\\$deviceid');
    // Add item to the list
    //controller.addPatient(location, deviceid);
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

Future<List<String>> getLocationNamesFromPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  final List<String>? locationNames = prefs.getStringList('location_names');
  if (locationNames != null) {
    print('Location names retrieved from SharedPreferences.');
    return locationNames;
  } else {
    print('Location names not found in SharedPreferences.');
    return []; // or throw an error, depending on your requirement
  }
}

Future<List<Map>> getListenersInfoFromPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  final String? idSensor_idLocation_json = prefs.getString('idSensor_idLocation');
  final String? idLocation_nameLocation_json = prefs.getString('idLocation_nameLocation');
  if (idSensor_idLocation_json != null && idLocation_nameLocation_json != null) {
    Map<String, String> idSensor_idLocation = json.decode(idSensor_idLocation_json);
    Map<String, String> idLocation_nameLocation = json.decode(idLocation_nameLocation_json);
    print('Location names retrieved from SharedPreferences.');
    return [idSensor_idLocation, idLocation_nameLocation];
  } else {
    print('Listeners Info not found in SharedPreferences.');
    return []; // or throw an error, depending on your requirement
  }
}






void getAllLocationsAndIdsAndSaveToPrefs() async {
  const String url = ApiUrls.locationGetterUrl; // Replace 'YOUR_API_URL_HERE' with your actual API endpoint for fetching locations and IDs
  
  try {
    final http.Response response = await http.get(Uri.parse(url));

   

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);
       print(responseBody);

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

      print("lista de localizacoes " + locationNames.toString());

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

void getAllListenersAndSaveToPrefs(HomeController controller) async {
  const String url = ApiUrls.addNotifierUrl; // Replace 'YOUR_API_URL_HERE' with your actual API endpoint for fetching locations and IDs
  
  try {
    final http.Response response = await http.get(Uri.parse(url));

   

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);
       print(responseBody);

      // Assuming the response body is in the format { "locations": [{ "name": "Location1", "id": "ID1" }, { "name": "Location2", "id": "ID2" }, ... ]}
      final List<dynamic> data = responseBody['listeners'];

      final Map<String, String> idSensor_idLocation = {};
      final Map<String, String> idLocation_nameLocation = {};

      for (final dt in data) {
        final String id = dt['id_sensor'];
        final String locationId = dt['id_location'];
        final String location = dt['name_location'];
        idLocation_nameLocation[locationId] = location;
        idSensor_idLocation[id] = locationId;
        String topic =  "moveID/notification/" + "$locationId" + "/" + "$id";
        controller.subscribeToTopic(topic);
      }

      //print("lista de localizacoes " + locationNames.toString());

      // Store the locations and IDs dictionary in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('idSensor_idLocation', json.encode(idSensor_idLocation));
      prefs.setString('idLocation_nameLocation', json.encode(idLocation_nameLocation)); // Store the list of location names
      
      print('Locations and IDs saved to SharedPreferences.');
    } else {
      print('Failed to fetch locations and IDs. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Exception occurred: $e');
  }
}



void refreshData(HomeController ctrl){
  getAllLocationsAndIdsAndSaveToPrefs();
  getAllListenersAndSaveToPrefs(ctrl);


}























































class HomeScreen extends GetView<HomeController> {

HomeScreen({super.key});

@override
Widget build(BuildContext context) {

  getAllLocationsAndIdsAndSaveToPrefs();
  getAllListenersAndSaveToPrefs(controller);
  return FutureBuilder<List<dynamic>>(
    future:Future.wait([
    getLocationNamesFromPrefs(),
    getListenersInfoFromPrefs(), // Suponha que essa função retorna uma lista de dados para o ListView
    ]),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return CircularProgressIndicator();
      } else if (snapshot.hasError) {
        // Return an error message if an error occurs
        return Text('Error: ${snapshot.error}');
      } else {
        final List<dynamic> results = snapshot.data!;
        final List<String> locationNamesFuture = results[0];
        final Map<String,String> listeners_idSensor_idLocation = results[1][0];
        final Map<String,String> listeners_idLocation_nameLocation = results[1][1];

        // If data is successfully fetched, build the widget tree
        final List<String> dropdownOptions = locationNamesFuture;
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
                
                onChanged: (String? value) {
                  controller.selectedLocation = RxString(value!);
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
                String location = controller.selectedLocation!.value.toString();
                if(deviceid.isNotEmpty){
                  print(controller.selectedLocation!.value.toString());
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
                    itemCount: listeners_idSensor_idLocation.entries.toList().length,
                    itemBuilder: (context, index) {
                     return Container(
                      color: Colors.white,
                      child: ListTile(
                        title: Text(listeners_idSensor_idLocation.entries.toList()[index].key),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(listeners_idLocation_nameLocation[listeners_idSensor_idLocation.entries.toList()[index].value]!),
                          ],
                        ),
                        trailing: GestureDetector(
                          child: const Icon(Icons.delete, color: Colors.red),
                          onTap: () {
                            removeNotifierRequest(controller.patients.value[index].deviceid.toString(),controller.patients.value[index].location.toString(),controller);
                           
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
    },
  );
}
}


