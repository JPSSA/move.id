
import 'package:flutter/cupertino.dart';
import 'package:move_id/models/patient_model.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:move_id/Notification/notification_controller.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'dart:convert';


late MqttServerClient client;

class HomeController extends GetxController{


     Future<void> initializeMqttClient() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    const String broker = '10.11.69.120';
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

  RxString selectedLocation = RxString("Hospital Santa Maria");
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
    patientModel = PatientModel(deviceid: deviceid,location: selectedLocation);
    patients.value.add(patientModel);
    itemCount.value = patients.value.length;
    selectedLocation.value = "Hospital Santa Maria"; 
    deviceIDTextEditingController.clear();
  }

  removePatient(int index){
    patients.value.removeAt(index);
    itemCount.value = patients.value.length;
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
  
}