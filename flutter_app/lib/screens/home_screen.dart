import 'package:flutter/material.dart';
import 'package:move_id/screens/settings_screen.dart';
import 'package:move_id/utils/color_utils.dart';
import 'package:move_id/utils/home_controller.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';


class HomeScreen extends GetView<HomeController> {

const HomeScreen({super.key});

@override
Widget build(BuildContext context) {

  controller.getAllLocationsAndIdsAndSaveToPrefs();
  controller.getAllListenersAndSaveToPrefs();
  return FutureBuilder<List<dynamic>>(
    future:Future.wait([
    controller.getLocationNamesFromPrefs(),
    controller.getListenersInfoFromPrefs(), // Suponha que essa função retorna uma lista de dados para o ListView
    ]),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const CircularProgressIndicator();
      } else if (snapshot.hasError) {
        // Return an error message if an error occurs
        return Text('Error: ${snapshot.error}');
      } else {
        final List<dynamic> results = snapshot.data!;
        final List<String> locationNamesFuture = results[0];
        final Map<String,String> listenersIdsensorIdlocation = results[1][0];
        final Map<String,String> listenersIdlocationNamelocation = results[1][1];

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
                  controller.addNotifierRequest(location, deviceid);
                  controller.refreshData();
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
                () => SizedBox(
                  height: 320,
                  child: ListView.builder(
                    itemCount: listenersIdsensorIdlocation.entries.toList().length,
                    itemBuilder: (context, index) {
                     return Container(
                      color: Colors.white,
                      child: ListTile(
                        title: Text(listenersIdsensorIdlocation.entries.toList()[index].key),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(listenersIdlocationNamelocation[listenersIdsensorIdlocation.entries.toList()[index].value]!),
                          ],
                        ),
                        trailing: GestureDetector(
                          child: const Icon(Icons.delete, color: Colors.red),
                          onTap: () {
                            controller.removeNotifierRequest(listenersIdsensorIdlocation.entries.toList()[index].key,listenersIdsensorIdlocation.entries.toList()[index].value);
                            controller.refreshData();
                           
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
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
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


