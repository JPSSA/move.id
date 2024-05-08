import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:move_id/utils/api_urls.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:move_id/models/models.dart';
import 'package:get/get.dart';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:move_id/Notification/notification_controller.dart';



late MqttServerClient client;

class HomeController extends GetxController{


     Future<void> initializeMqttClient() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    const String broker = '192.168.1.78';
    const int port = 1883;
    String clientId = prefs.getString("email") ?? "";

    client = MqttServerClient(broker, clientId);
    client.port = port;
    client.secure = false;

    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    client.onSubscribed = subscribeToTopic;

    // Connect to the MQTT broker
    try {
      await client.connect();
    } catch (e) {
      print('Failed to connect to MQTT broker: $e');
    }
  }

  void onConnected() {
    print('Connected to MQTT broker');
    client.updates?.listen(onMessageReceived);
  }

  void onDisconnected() {
      print('Disconnected from MQTT broker');
  }

  void subscribeToTopic(String topic) {
      client.subscribe(topic, MqttQos.atLeastOnce);
      print('Subscribed to topic: $topic');
  }

  void unsubscribeFromTopic(String topic) {
    client.unsubscribe(topic);
    print('Unsubscribed from topic: $topic');
  }

 void onMessageReceived(List<MqttReceivedMessage<MqttMessage>> event) {
  final MqttPublishMessage receivedMessage = event[0].payload as MqttPublishMessage;
  final String message = MqttPublishPayload.bytesToStringAsString(receivedMessage.payload.message);
  
  // Parse the JSON string
  Map<String, dynamic> jsonMessage = jsonDecode(message);
  String patientFirstName = jsonMessage['patient_fname'];
  String patientLastName = jsonMessage['patient_lname'];
  String alert = jsonMessage['alert'];
  String location = jsonMessage['location'];

  // Create notification using parsed information
  String title = "Alert: $alert";
  String body = "Patient: $patientFirstName $patientLastName\nLocation: $location";
  
  // Create Awesome Notification
  AwesomeNotifications().createNotification(
  content: NotificationContent(
    id: 1, 
    channelKey: "MoveID_Notification_Channel",
    title: title,
    body: body,
  ),
);
}

  MqttServerClient getMqttClient() {
    return client;
  }

  RxString? selectedLocation = RxString('');
  Rx<List<PatientModel>> patients = Rx<List<PatientModel>>([]);
  TextEditingController deviceIDTextEditingController = TextEditingController();
  late PatientModel patientModel;
  var itemCount = 0.obs;
  @override
  void onInit() {
    super.onInit();
    initializeMqttClient();
    initializeAwesomeNotifications();

  }

  @override
  void onReady(){
    super.onReady();
  }

  @override
  void onClose(){
    super.onClose();
    deviceIDTextEditingController.dispose();
  }
  addPatient(String location, String deviceid){
    patientModel = PatientModel(deviceid: deviceid,location: RxString(location));
    patients.value.add(patientModel);
    itemCount.value = patients.value.length;
    deviceIDTextEditingController.clear();
  }

   void initializeAwesomeNotifications() async {
    // Initialize Awesome Notifications
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelGroupKey: "MoveID_channel_group",
          channelKey: "MoveID_Notification_Channel", 
          channelName: "MoveID Notification", 
          channelDescription: "MoveID Notification Channel",
          playSound: true,
        ),
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: "MoveID_channel_group", 
          channelGroupName: "MoveID Group",
        ),
      ],
    );

    // Check if the app is allowed to send notifications
    bool isAllowedToSendNotifications = await AwesomeNotifications().isNotificationAllowed();

    // If notifications are not allowed, request permission
    if(!isAllowedToSendNotifications){
      AwesomeNotifications().requestPermissionToSendNotifications();
    }
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: NotificationController.onActionReceivedMethod,
      onNotificationCreatedMethod: NotificationController.onNotificationCreatedMethod,
      onNotificationDisplayedMethod: NotificationController.OnNotificationDisplayedMethod,
      onDismissActionReceivedMethod: NotificationController.OnNotificationDisplayedMethod
    );
  }

  void addNotifierRequest(String idLocation, String deviceid) async {
  
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

void removeNotifierRequest(String deviceid, String idLocation) async {
  
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
      unsubscribeFromTopic(topic);
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






Future<void> getAllLocationsAndIdsAndSaveToPrefs() async {
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

Future<void> getAllListenersAndSaveToPrefs() async {
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
        subscribeToTopic(topic);
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



void refreshData(){
  getAllLocationsAndIdsAndSaveToPrefs();
  getAllListenersAndSaveToPrefs();

}
  
}