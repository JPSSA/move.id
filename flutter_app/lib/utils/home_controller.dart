
import 'package:flutter/cupertino.dart';
import 'package:move_id/models/patient_model.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:convert';


late MqttServerClient client;

class HomeController extends GetxController{


     Future<void> initializeMqttClient() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    const String broker = 'broker.emqx.io';
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
    print('Received message: $message');
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
  
}