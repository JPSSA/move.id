import 'package:flutter/material.dart';
import 'package:move_id/screens/settings_screen.dart';
import 'package:move_id/utils/color_utils.dart';
import 'package:move_id/utils/home_controller.dart';
import 'package:get/get.dart';

class HomeScreen extends GetView<HomeController> {
  
  final List<String> dropdownOptions = [
    "Hospital Santa Maria",
    "Hospital Lusíadas",
    "Hospital da Luz",
  ];

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
                String deviceID = controller.deviceIDTextEditingController.text;
                controller.addPatient(controller.selectedLocation.value, deviceID);
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
